//
//  Utility.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utility : NSObject

@property (nonatomic, assign) NSNumber *lastNoteIndex;

+(Utility *)instance;
+(void)verticallyAlignLabel:(UILabel *)label;
+(void)showGeneralAlertMsg:(NSString *)msg withTitle:(NSString *)title;

-(NSNumber *)getNextNoteIndex;

@end
