//
//  GPS.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//
//  Purpose: A straightforward GPS lookup class.
//
//  Usage: 
//
//  Instantiate the GPS class:
//
//      GPS gps = [[GPS alloc] init]; 
//
//          OR
//
//      GPS gps = [[GPS alloc] initWithStopAfterFirstLocation:YES];
//
//
//  Set self as delegate:
//
//      gps.delegate = self;
//
//
//  Finally, initate the lookup:
//
//      [gps findUser];
//
//
//  Note: assumes you have already checked for a network connection using 
//  the current application delegate KVO broadcast methods.
//
//  Note: if stopAfterFirstLocation is NO, GPS will continue to lookup
//  the user's location until kGPSAccuracy is reached or a timeout has expired.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Protocol you need to implement in order to handle the events
@protocol GPSDelegate <NSObject>
@required
-(void)locationUpdated:(CLLocation *)location;
-(void)locationUpdatedAndStoppedAfterHorizontalAccuracyReached:(CLLocation *)location;
-(void)locationLookupTimedOut:(CLLocation *)location;
@end

@interface GPS : NSObject <CLLocationManagerDelegate>

// Protected member variables
@property (nonatomic, retain) id <GPSDelegate> delegate;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL hasLocationBeenFound;

// Public methods
-(id)initWithStopAfterFirstLocation:(BOOL)enabled;
-(void)findUser;
-(void)stopLookup;

@end
