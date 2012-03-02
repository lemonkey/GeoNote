//
//  NotesCustomCell.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "NotesCustomCell.h"


@implementation NotesCustomCell
@synthesize lblCreateDate = _lblCreateDate;
@synthesize lblUpdateDate = _lblUpdateDate;
@synthesize lblTitle = _lblTitle;
@synthesize lblCoordinates = _lblCoordinates;

-(void)dealloc {
    DLog(@"");

    self.lblCreateDate = nil;
    self.lblUpdateDate = nil;
    self.lblTitle = nil;
    self.lblCoordinates = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Slide over all elements within the cell when editing.
- (void)layoutSubviews {
    DLog(@"self.editing: %d", self.editing);
    
    CGRect cdRect = [self.lblCreateDate frame];
    CGRect udRect = [self.lblUpdateDate frame];
    CGRect tRect = [self.lblTitle frame];
    CGRect cRect = [self.lblCoordinates frame];
     
    cdRect.origin.x = (self.isEditing) ? (kLblCreateDateDefaultX + kXOffset) : kLblCreateDateDefaultX;
    udRect.origin.x = (self.isEditing) ? (kLblUpdateDateDefaultX + kXOffset) : kLblUpdateDateDefaultX;
    tRect.origin.x = (self.isEditing) ? (kLblTitleDefaultX + kXOffset) : kLblTitleDefaultX;
    cRect.origin.x = (self.isEditing) ? (kLblCoordinateDefaultX + kXOffset) : kLblCoordinateDefaultX;
    
    [self.lblCreateDate setFrame:cdRect];
    [self.lblUpdateDate setFrame:udRect];
    [self.lblTitle setFrame:tRect];
    [self.lblCoordinates setFrame:cRect];
    
    [super layoutSubviews];
}

@end