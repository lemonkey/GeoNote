//
//  MapAnnotation.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "MapAnnotation.h"


@implementation MapAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize annotationType = _annotationType;
@synthesize annotationId = _annotationId;

/*
-(id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(0,0)];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoord
{
    if((self = [super init])) {
        self.annotationCoordinate = inCoord;
    }
	return self;
}
*/

-init
{
	return self;
}

-initWithCoordinate:(CLLocationCoordinate2D)inCoord
{
	self.coordinate = inCoord;
	return self;
}

-(void)dealloc {
    
    [super dealloc];
}

@end
