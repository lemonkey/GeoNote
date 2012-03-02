//
//  TableViewFormCustomCell.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "TableViewFormCustomCell.h"


@implementation TableViewFormCustomCell
@synthesize lblName = _lblName;
@synthesize txtField = _txtField;

-(void)dealloc {
    DLog(@"");

    self.lblName = nil;
    self.txtField = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    DLog(@"");
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    DLog(@"");
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
