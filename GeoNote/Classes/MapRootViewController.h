//
//  MapViewController.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import "MapAnnotation.h"
#import "GPS.h"


@class AddNoteViewController;
@class GeoNoteAppDelegate;
@class Note;

@interface MapRootViewController : UIViewController <GPSDelegate, MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *mapViewContainer;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, assign) double curMapRegionSpan;
@property (nonatomic, retain) MapAnnotation *userAnnotation;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) GPS *gps;
@property (nonatomic, assign) GeoNoteAppDelegate *appDelegate;
@property (nonatomic, assign) BOOL comingFromAddNoteVC;
@property (nonatomic, retain) NSMutableArray *notesArray;
@property (nonatomic, retain) NSMutableArray *savedNoteAnnotations;
@property (nonatomic, assign) BOOL showOnlyCurrentNote;
@property (nonatomic, retain) Note *currentNote;

-(void)refreshMap;
-(void)resetMap;
-(void)updateMapView:(CLLocation *)location isFinalLocation:(BOOL)final;
-(void)zoomMap:(CLLocation *)location isFinalLocation:(BOOL)final;
-(IBAction)btnRefreshClick:(UIBarButtonItem *)sender;
-(void)addUserAnnotation:(CLLocation *)location;
-(void)addNewNoteAtLocation:(CLLocation *)location;
-(void)editNote:(Note *)note;
-(void)addTempAnnotation:(CLLocation *)location;
-(void)addSavedNoteAnnotation:(Note *)note;

-(void)initAndStartGPSLookup;
-(void)setLocationAndUpdateMap:(CLLocation *)location isFinalLocation:(BOOL)final;
-(void)loadNoteLocations;
-(void)showCurrentNoteOnMap;

// GPSDelegate methods
-(void)locationUpdated:(CLLocation *)location;
-(void)locationUpdatedAndStoppedAfterHorizontalAccuracyReached:(CLLocation *)location;
-(void)locationLookupTimedOut:(CLLocation *)location;

@end