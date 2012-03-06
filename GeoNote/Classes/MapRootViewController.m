//
//  MapViewController.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "MapRootViewController.h"
#import "AddNoteTableViewController.h"
#import "EditNoteTableViewController.h"
#import "GeoNoteAppDelegate.h"
#import "Note.h"


@implementation MapRootViewController
@synthesize mapViewContainer = _mapViewContainer;
@synthesize mapView = _mapView;
@synthesize curMapRegionSpan = _curMapRegionSpan;
@synthesize userAnnotation = _userAnnotation;
@synthesize currentLocation = _currentLocation;
@synthesize gps = _gps;
@synthesize appDelegate = _appDelegate;
@synthesize comingFromAddNoteVC = _comingFromAddNoteVC;
@synthesize notesArray = _notesArray;
@synthesize savedNoteAnnotations = _savedNoteAnnotations;
@synthesize showOnlyCurrentNote = _showOnlyCurrentNote;
@synthesize currentNote = _currentNote;

- (void)dealloc {
    DLog(@"");
    
    self.mapViewContainer = nil;

    if(self.mapView) {
		[self.mapView removeFromSuperview]; 
		[self.mapView removeAnnotations:[self.mapView annotations]]; 
		self.mapView.delegate = nil; 
		self.mapView = nil;
	}

    self.userAnnotation = nil;
    
    self.currentLocation = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNetworkStatus object:nil];
        
    self.gps.delegate = nil;
    self.gps = nil;
    
    self.savedNoteAnnotations = nil;
    self.notesArray = nil;

    self.currentNote = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
							
- (void)didReceiveMemoryWarning {
    DLog(@"");
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"");
    
    [super viewDidLoad];
    
    self.appDelegate = (GeoNoteAppDelegate *)[[UIApplication sharedApplication] delegate];

    if(self.showOnlyCurrentNote) {
        self.navigationItem.title = @"Selected Note";
    } else {
        self.navigationItem.title = @"Map";
    }
    
	UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(btnRefreshClick:)];

    self.navigationController.topViewController.navigationItem.rightBarButtonItem = btnRefresh;
    
	[btnRefresh release];
    
    self.comingFromAddNoteVC = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkStatus_CB:) name:kNotificationNetworkStatus object:nil];
}

- (void)viewDidUnload {
    DLog(@"");
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"");
    
    [self refreshMap];
    
    /*
    // Don't auto-refresh map if coming from the
    // add note view controller.
    if(!self.comingFromAddNoteVC) {
        [self refreshMap];
    } else {
        self.comingFromAddNoteVC = NO;
    }
     */
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DLog(@"");
    
    // Stop GPS lookup if it is occurring.
    [self.gps stopLookup];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Startup methods

-(void)onNetworkStatus_CB:(NSNotification *)notice {
    DLog(@"notice: %@", notice);
    
    // If internet reachable...start GPS lookup
    // Otherwise, warning will be shown.
    BOOL hasNetwork = NO;
    
    NSDictionary *userInfo = [notice userInfo];
	
	if(userInfo != nil) {
       hasNetwork = [[userInfo objectForKey:kKeyNetworkFound] boolValue];
	}	
    
    if(hasNetwork) {
        DLog(@"Network detected.");
        [self initAndStartGPSLookup];
    }
}

-(void)initAndStartGPSLookup {
    DLog(@"");
    
    if(!self.gps) {
        self.gps = [[GPS alloc] initWithStopAfterFirstLocation:kStopGPSAfterFirstLocationFound];
        [self.gps setDelegate:self];
    }
    
    [self.gps findUser];
}

-(void)setLocationAndUpdateMap:(CLLocation *)location isFinalLocation:(BOOL)final {
    DLog(@"");
    
    self.currentLocation = location;
    [self updateMapView:self.currentLocation isFinalLocation:final];
}

// Retrieve notes from core data and display them on the map view.
-(void)loadNoteLocations {
    DLog(@"");

    // Delete any existing saved note annotations.
    for(MapAnnotation *savedNoteAnnotation in self.savedNoteAnnotations) {
        if(savedNoteAnnotation) {
            [self.mapView removeAnnotation:savedNoteAnnotation];
        }
    }
    
    self.savedNoteAnnotations = nil;
    self.notesArray = nil;
    self.savedNoteAnnotations = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
        [Utility showGeneralAlertMsg:[NSString stringWithFormat:@"There was a problem retrieving your notes: %@", error] withTitle:@"Error"];
    } else {
        DLog(@"Notes retrieved successfully.");
        [self setNotesArray:mutableFetchResults];
    }
    
    [mutableFetchResults release];
    [request release];
    
    if([self.notesArray count] > 0) {
        
        // Drop markers for each note
        for(Note *note in self.notesArray) {
            [self addSavedNoteAnnotation:note];
        }
    }
}


#pragma mark -
#pragma mark GPSDelegate methods

-(void)locationUpdated:(CLLocation *)location {
    DLog(@"%@", location);
    [self setLocationAndUpdateMap:location isFinalLocation:NO];
}

-(void)locationUpdatedAndStoppedAfterHorizontalAccuracyReached:(CLLocation *)location {
    DLog(@"%@", location);
    [self setLocationAndUpdateMap:location isFinalLocation:YES];
}

-(void)locationLookupTimedOut:(CLLocation *)location {
    DLog(@"%@", location);
    // Drop pin at wherever we are right now...
    [self updateMapView:self.currentLocation isFinalLocation:YES];
}


# pragma mark -
# pragma mark Main logic methods

-(void)showCurrentNoteOnMap {
    DLog(@"");

    if(self.currentNote) {
        
        [self resetMap];
        
        /*
        if(!self.mapView)
        {
            DLog(@"MapViewController - refreshMap - creating mapView");
            
            // Instance of MKMapView that shows the interactive map 
            self.mapView = [[MKMapView alloc] initWithFrame:self.mapViewContainer.frame];
            self.mapView.userLocation.title = @"Your location";
            self.mapView.scrollEnabled = YES;
            self.mapView.zoomEnabled = YES;
            self.mapView.delegate = self;
            
            [self.mapViewContainer insertSubview:self.mapView atIndex:0];
        } else {
            DLog(@"MapViewController - refreshMap - mapView already exists");

            // Remove saved note annotations
            for(MapAnnotation *savedNoteAnnotation in self.savedNoteAnnotations) {
                if(savedNoteAnnotation) {
                    [self.mapView removeAnnotation:savedNoteAnnotation];
                }
            }
        }
        */
        
        self.currentLocation = nil;
        self.currentLocation = [[CLLocation alloc] initWithLatitude:[self.currentNote.latitude doubleValue] longitude:[self.currentNote.longitude doubleValue]];

        self.savedNoteAnnotations = nil;
        self.savedNoteAnnotations = [[NSMutableArray alloc] initWithCapacity:0];

        // Place marker on map
        [self addSavedNoteAnnotation:self.currentNote];
        
        // Zoom map on marker
        [self zoomMap:self.currentLocation isFinalLocation:YES];
    }
}

-(IBAction)btnRefreshClick:(UIBarButtonItem *)sender {
    DLog(@"");
    
    [self refreshMap];
}

-(void)resetMap {
    DLog(@"");
    
    self.curMapRegionSpan = 0.00;
    
    if(self.mapView) {
		[self.mapView removeFromSuperview]; 
		[self.mapView removeAnnotations:[self.mapView annotations]]; 
		self.mapView.delegate = nil; 
		self.mapView = nil;
	}
    self.mapView = [[MKMapView alloc] initWithFrame:self.mapViewContainer.frame];
    self.mapView.userLocation.title = @"Your location";
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.delegate = self;
    
    [self.mapViewContainer insertSubview:self.mapView atIndex:0];
}

-(void)refreshMap {
    DLog(@"");
    
    // Note: this should also be called when switching tabs back..

    [self resetMap];
    
    /*
    if(!self.mapView)
	{
        DLog(@"MapViewController - refreshMap - creating mapView");
        
		// Instance of MKMapView that shows the interactive map 
		self.mapView = [[MKMapView alloc] initWithFrame:self.mapViewContainer.frame];
		self.mapView.userLocation.title = @"Your location";
		self.mapView.scrollEnabled = YES;
		self.mapView.zoomEnabled = YES;
		self.mapView.delegate = self;
		
		[self.mapViewContainer insertSubview:self.mapView atIndex:0];
	} else {
        DLog(@"MapViewController - refreshMap - mapView already exists");
    }
	*/
    
    // Remove saved note annotations.
    for(MapAnnotation *savedNoteAnnotation in self.savedNoteAnnotations) {
        if(savedNoteAnnotation) {
            [self.mapView removeAnnotation:savedNoteAnnotation];
        }
    }
    self.savedNoteAnnotations = nil;
    self.notesArray = nil;

    if(self.showOnlyCurrentNote) {
        [self showCurrentNoteOnMap];
    } else {    
        [self.gps stopLookup];
        
        // Check to see if a network connection exists (important if GPS cannot
        // locate user and it has to use either wifi or cell tower triangulation)
        // If network found, GPS lookup will start.
        // 
        // Subscription to event will call onNetworkStatus_CB.
        [self.appDelegate checkNetworkStatus];
    }
}


// Sets current user's location and zooms in on map.
-(void)updateMapView:(CLLocation *)location isFinalLocation:(BOOL)final {
	DLog(@"");
	
	self.currentLocation = location;
	
    if(final) {
        [self loadNoteLocations];
    }
    
	if(location != nil)
	{
		[self zoomMap:location isFinalLocation:final];
	}
}

// Zoom map on passed location coordinates.
-(void)zoomMap:(CLLocation *)location isFinalLocation:(BOOL)final {
	DLog(@"");
    
	// Zoom in on passed location
	MKCoordinateRegion region;
	region.center = location.coordinate;
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.005;
	span.longitudeDelta = 0.005;
	region.span = span;
	
	self.curMapRegionSpan = 0.005;
	
	[self.mapView setRegion:region animated:YES];
    
    if(!self.showOnlyCurrentNote) {
        if(final) {
            // Set current location pin
            [self addUserAnnotation:location];
        } else {
            // Add temporary pin that can't be tapped
            [self addTempAnnotation:location];
        }
    }
}

// Add pin to map at user's current location with an annotation
// that will let them add a note at this locaton.
-(void)addUserAnnotation:(CLLocation *)location {
    DLog(@"");
    
    // Remove previous annotation if one exists
    if(self.userAnnotation) {
        [self.mapView removeAnnotation:self.userAnnotation];
        self.userAnnotation = nil;
    }

    self.userAnnotation = [[MapAnnotation alloc] initWithCoordinate:location.coordinate];
    [self.userAnnotation setTitle:@"Add a note!"];
    [self.userAnnotation setAnnotationType:annotationTypeCurrentLocation];
    [self.userAnnotation setAnnotationId:0]; // Tag for button on current location annotation will always be 0
    [self.mapView addAnnotation:self.userAnnotation];	
    
    // Auto-select it for convenience
    [self.mapView selectAnnotation:self.userAnnotation animated:YES];
}

// Temporary blue dot where user's location is while we try to get a
// more accurate value.
-(void)addTempAnnotation:(CLLocation *)location {
    DLog(@"");
    
    // Remove previous annotation if one exists
    if(self.userAnnotation) {
        [self.mapView removeAnnotation:self.userAnnotation];
        self.userAnnotation = nil;
    }
    
    self.userAnnotation = [[MapAnnotation alloc] initWithCoordinate:location.coordinate];
    [self.userAnnotation setAnnotationType:annotationTypeTempLocation];
    [self.userAnnotation setAnnotationId:0];
    [self.mapView addAnnotation:self.userAnnotation];	
}

// Previously saved note location.
-(void)addSavedNoteAnnotation:(Note *)note {
    DLog(@"note: %@", note);

    CLLocation *noteLocation = [[CLLocation alloc] initWithLatitude:[note.latitude doubleValue] longitude:[note.longitude doubleValue]];
    MapAnnotation *noteAnnotation = [[MapAnnotation alloc] initWithCoordinate:noteLocation.coordinate];
    [noteLocation release];
    
    [noteAnnotation setAnnotationType:annotationTypeSavedNote];
    [noteAnnotation setTitle:note.title];
    [noteAnnotation setAnnotationId:[note.noteId integerValue]];
    [self.savedNoteAnnotations addObject:noteAnnotation];
    [self.mapView addAnnotation:noteAnnotation];
    
    // Auto-select it for convenience
    [self.mapView selectAnnotation:noteAnnotation animated:YES];
}


# pragma mark -
# pragma mark MapKit methods

// Called when annotation is created for a given placemark
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	DLog(@"");
	
	DLog(@"annotation: %@", annotation);
	DLog(@"annotation title: %@", annotation.title);
	
	MapAnnotation *myAnnotation = (MapAnnotation *)annotation;
	
    // Custom annotation
    if(myAnnotation.annotationType == annotationTypeCurrentLocation)
    {
        MKPinAnnotationView *annotationPin = [[[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation 
                                                                              reuseIdentifier:@"currentLocation"] autorelease];
        // Just a location pin (red) with a touch state that takes 
        // the user to a view that allows them to add a note
        
        [annotationPin setEnabled:YES];
        [annotationPin setCanShowCallout:YES];
        [annotationPin setPinColor:MKPinAnnotationColorRed];	
        [annotationPin setAnimatesDrop:YES];
        
        UIButton *annotationBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];		
        annotationBtn.tag = myAnnotation.annotationId;
        annotationPin.rightCalloutAccessoryView = annotationBtn;

        /*
        [annotationPin setSelected:YES animated:YES];
        [annotationPin setHighlighted:YES];
         */
        
        return annotationPin;
    }
    else if(myAnnotation.annotationType == annotationTypeTempLocation)
    {
        MKPinAnnotationView *annotationPin = [[[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation 
                                                                              reuseIdentifier:@"tempLocation"] autorelease];

        // Just a temp location dot (blue)
        [annotationPin setEnabled:NO];
		[annotationPin setCanShowCallout:NO];
		UIImage *blueDotImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blue_dot-transparent" ofType:@"png"]]; 
		[annotationPin setImage:blueDotImg];
		
        return annotationPin;        
    }
    else if(myAnnotation.annotationType == annotationTypeSavedNote)
    {
        MKPinAnnotationView *annotationPin = [[[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation 
                                                                              reuseIdentifier:@"savedNote"] autorelease];
        // Just a location pin (purple) with a touch state that takes user
        // to details for the saved note
        
        [annotationPin setEnabled:YES];
        [annotationPin setCanShowCallout:YES];
        [annotationPin setPinColor:MKPinAnnotationColorPurple];	
        [annotationPin setAnimatesDrop:YES];
        
        UIButton *annotationBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];		
        annotationBtn.tag = myAnnotation.annotationId;
        annotationPin.rightCalloutAccessoryView = annotationBtn;
        
        return annotationPin;
    }
    
    return nil;
}

// Called when user clicks on a map annotation button
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	DLog(@"view: %@, control: %@", view, control);

    if([control isKindOfClass:[UIButton class]]) {
        UIButton *annotationButton = (UIButton *)control;
        NSInteger buttonId = annotationButton.tag;
        
        MapAnnotation *annotation = view.annotation;
        if(annotation.annotationType == annotationTypeCurrentLocation) {
            DLog(@"current location tapped: %d", buttonId);
            
            [self addNewNoteAtLocation:self.currentLocation];
            
        } else {
            if(annotation.annotationType == annotationTypeSavedNote) {
                DLog("@saved note tapped: %d", buttonId);

                Note *currentNote = [self.appDelegate getNoteWithId:[NSNumber numberWithInt:buttonId]];
                
                if(currentNote) {
                    [self editNote:currentNote];
                }
            }
        }
    }
    
    // Deselect annotation pin so that when we come back it won't
    // still be selected.
    for (NSObject<MKAnnotation> *annotation in [mapView selectedAnnotations]) {
        [mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
    }
}

-(void)addNewNoteAtLocation:(CLLocation *)location {
    DLog(@"location: %@", location);
        
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Note" 
                                                    message:[NSString stringWithFormat:@"Adding a new note at this location (%f,%f)", location.coordinate.latitude, location.coordinate.longitude] 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];	
    */
    
    // Add navigation table view controller to show "add new note" view using current location
    AddNoteTableViewController *addNoteVC = [[AddNoteTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    addNoteVC.location = location;    
    
	// In order to override the default previous button that has the title
	// of the previous view's title, must add this here.
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: nil action: nil];
	[self.navigationItem setBackBarButtonItem: newBackButton];
	[newBackButton release];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:addNoteVC animated:YES];
	
    self.comingFromAddNoteVC = YES;
    
    [addNoteVC release];
}

-(void)editNote:(Note *)note {
    DLog(@"note: %@", note);
    
    // Add navigation table view controller to show "add new note" view using current location
    EditNoteTableViewController *editNoteVC = [[EditNoteTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editNoteVC.currentNote = note;
    
	// In order to override the default previous button that has the title
	// of the previous view's title, must add this here.
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: nil action: nil];
	[self.navigationItem setBackBarButtonItem: newBackButton];
	[newBackButton release];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:editNoteVC animated:YES];
	
    [editNoteVC release];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	DLog(@"");
	
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	DLog(@"");
	
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	DLog(@"");
	
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	DLog(@"");
	
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	DLog(@"");
	
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	DLog(@"");
	
}

@end