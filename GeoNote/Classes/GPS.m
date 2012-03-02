//
//  GPS.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "GPS.h"


// Define private members and methods
@interface GPS() 

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isGPSEnabled;
@property (nonatomic, assign) BOOL stopAfterFirstLocation;
@property (nonatomic, retain) NSTimer *gpsTimeoutTimer;

-(void)startLookup;
-(void)disableLookup:(NSString *)msg;
-(void)stopGPSTimeoutTimer;

@end

// Main implementation
@implementation GPS

@synthesize delegate = _delegate;
@synthesize currentLocation = _currentLocation;
@synthesize hasLocationBeenFound = _hasLocationBeenFound;
@synthesize locationManager = _locationManager;
@synthesize isGPSEnabled = _isGPSEnabled;
@synthesize stopAfterFirstLocation = _stopAfterFirstLocation;
@synthesize gpsTimeoutTimer = _gpsTimeoutTimer;

-(void)dealloc {
    DLog(@"");
    
    self.delegate = nil;
    
    self.currentLocation = nil;
    
    if(self.locationManager) {
        self.locationManager.delegate = nil;
        self.locationManager = nil;
    }
    
    if(self.gpsTimeoutTimer) {
        [self.gpsTimeoutTimer invalidate];
        self.gpsTimeoutTimer = nil;
    }
}

-(id)init {
    DLog(@"");
    return [self initWithStopAfterFirstLocation:NO];
}


-(id)initWithStopAfterFirstLocation:(BOOL)enabled {
    DLog(@"");
    if((self = [super init])) {
        self.isGPSEnabled = YES;
        self.hasLocationBeenFound = NO;
        self.stopAfterFirstLocation = enabled;
    }
    return self;
}

#pragma mark -
#pragma mark Public methods

-(void)findUser {
    DLog(@"");
    
    if(self.isGPSEnabled) {
        
        self.hasLocationBeenFound = NO;
        
        bool locationServicesEnabled = NO;
        
        if(self.locationManager == nil)
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.distanceFilter = kCLDistanceFilterNone; 
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // kCLLocationAccuracyBest;
            
            if([CLLocationManager locationServicesEnabled]) {
                locationServicesEnabled = YES;
            } else {
                // Location lookup already disabled by user
                [self disableLookup:nil];
            }
        }
        else
        {
            // We've already initialized the locationManager instance.
            if([CLLocationManager locationServicesEnabled]) {
                locationServicesEnabled = YES;
                
                // Stop any outstanding lookup process.
                [self.locationManager stopUpdatingLocation];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            } else {
                // Location lookup already disabled by user
                [self disableLookup:nil];
            }
        }
        
        if(locationServicesEnabled)
        {
            DLog(@"GPS lookup allowed by user.");
            self.isGPSEnabled = YES;
            
            [self startLookup];
            
        } else {
            self.isGPSEnabled = NO;
        }
        
    } else {
        // User has previously declined the request to allow GPS lookup.
        // Do NOT proceed.
        DLog(@"Error: GPS - findUser.  User has previously declined authorization for GPS lookup.");
        [Utility showGeneralAlertMsg:kMsgCannotFindLocation_UserDeniedAccess withTitle:@"Error"];
    }
}

-(void)stopLookup {
    DLog(@"");
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self stopGPSTimeoutTimer];
    
    if(self.locationManager != nil)
	{
		[self.locationManager stopUpdatingLocation];
		
		self.locationManager.delegate = nil;
		self.locationManager = nil;
	}
}

#pragma mark -
#pragma mark Private methods

-(void)startLookup {
    DLog(@"");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	self.hasLocationBeenFound = NO;
	
	[self.locationManager startUpdatingLocation];
    
    // Kick off timeout timer in case GPS is unable to find
    // user location within the maximum accuracy
    self.gpsTimeoutTimer = [[NSTimer timerWithTimeInterval:(kGPSLookupTimeoutInSeconds) target:self selector:@selector(endGPSTimeoutTimer:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:self.gpsTimeoutTimer forMode:NSDefaultRunLoopMode];	
}

-(void)stopGPSTimeoutTimer {
    DLog(@"");

    if(self.gpsTimeoutTimer) {
        [self.gpsTimeoutTimer invalidate];
        self.gpsTimeoutTimer = nil;
    }
}

- (void)endGPSTimeoutTimer:(NSTimer *)theTimer {
    DLog(@"");

    // Timeout timer ran out before we found the user's
    // location to within the maximum accuracy.

    [self.delegate locationLookupTimedOut:self.currentLocation];
    
    // Show warning...
    [Utility showGeneralAlertMsg:kMsgCannotFindLocation_Timeout withTitle:@"Error"];

    // Stop GPS lookup and timer
    [self stopLookup];
}

-(void)disableLookup:(NSString *)msg {
	DLog(@"");
    
	self.isGPSEnabled = NO;
    
	[self stopLookup];
    
    if(msg) {
        [Utility showGeneralAlertMsg:msg withTitle:@"Error"];
    }
}

#pragma mark -
#pragma mark CLLocationDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	DLog(@"");
	
	if(!self.hasLocationBeenFound)
	{
		self.hasLocationBeenFound = YES;
	}
    
	self.isGPSEnabled = YES;
	
	double latitude = newLocation.coordinate.latitude;
	double longitude = newLocation.coordinate.longitude;
    
	// Save current point for user's location on the map view (different from nearest city's deal location)
	self.currentLocation = newLocation;
    
	if(kOverrideLocation)
	{
		latitude = kDefaultLatitude;
		longitude = kDefaultLongitude;
		CLLocation *debugLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		self.currentLocation = debugLocation;
		[debugLocation release];
	}
    
    // If user signified that they only wanted the first location
    // during instantiation, stop lookup here.
    if(self.stopAfterFirstLocation) {        

        [self.delegate locationUpdated:self.currentLocation];
        
        [self stopLookup];
        
    } else {
        
        // Otherwise, stop lookup once desired accuracy has been achieved.
        double horizontalAccuracyInMeters = self.currentLocation.horizontalAccuracy;
        
        DLog(@"horizontal accuracy: %f", horizontalAccuracyInMeters);
        
        if(horizontalAccuracyInMeters <= kGPSAccuracyInMeters) {
            DLog(@"Horizontal accuracy threshold reached.  Stopping GPS.");
            
            // Now using protocol method instead of KVO broadcasting
            [self.delegate locationUpdatedAndStoppedAfterHorizontalAccuracyReached:self.currentLocation];            
            
            [self stopLookup];
            
        } else {
            
            [self.delegate locationUpdated:self.currentLocation];
            
        }
    }
}

// If user denies application's request to use location service,
// this method will report a "kCLErrorDenied" error.  Stop location service
// if this happens.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	DLog(@"");
    
	// If user denies the request to allow GPS, this method may fire more than once.
	DLog(@"location manager lookup failed! Error - %@ %@",
		 [error localizedDescription],
		 [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	if(error.code == kCLErrorDenied)
	{
		if(self.isGPSEnabled) {
			[self disableLookup:kMsgCannotFindLocation_UserDeniedAccess];
        }
	}
	else
	{        
        [self disableLookup:nil];
        
		NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
        [Utility showGeneralAlertMsg:errorType withTitle:@"Error retrieving location"];
	}
}

@end