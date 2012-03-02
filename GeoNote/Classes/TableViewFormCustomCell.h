//
//  TableViewFormCustomCell.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewFormCustomCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lblName;
@property (nonatomic, retain) IBOutlet UITextField *txtField;

@end
