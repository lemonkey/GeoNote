//
//  NotesCustomCell.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kXOffset                    30
#define kLblCreateDateDefaultX      9
#define kLblUpdateDateDefaultX      9
#define kLblTitleDefaultX           9
#define kLblCoordinateDefaultX      136


@interface NotesCustomCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lblCreateDate;
@property (nonatomic, retain) IBOutlet UILabel *lblUpdateDate;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblCoordinates;

@end
