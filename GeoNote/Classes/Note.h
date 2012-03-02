//
//  Note.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) NSDate *updateDate;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *noteId;

@end
