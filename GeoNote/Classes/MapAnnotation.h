//
//  MapAnnotation.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


typedef enum {
	annotationTypeCurrentLocation = 0,
    annotationTypeTempLocation = 1,
	annotationTypeSavedNote = 2
} MapAnnotationType;

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic) MapAnnotationType annotationType;
@property (nonatomic, assign) NSInteger annotationId;

-initWithCoordinate:(CLLocationCoordinate2D)inCoord;

@end
