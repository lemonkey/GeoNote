//
//  AddNoteTableViewController.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kAddNoteNumberOfEditableRows		2
#define kAddNoteTitleRowIndex				0
#define kAddNoteTextRowIndex				1

#define kLabelTag							4096

#define kDefaultAddNoteHeaderHeight         50
#define kAddNoteHeaderHeightOffset          20
#define kDefaultAddNoteFooterHeight         60


@class AddNoteTableViewCustomHeader;

@interface AddNoteTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, assign) int headerHeight;
@property (nonatomic, assign) int footerHeight;

-(IBAction)btnAddClick:(id)sender;
-(void)hideKeyboard;
-(IBAction)textFieldDone:(id)sender;
-(void)setHeaderTextAndAdjustHeight:(NSString *)text headerView:(AddNoteTableViewCustomHeader *)headerView;

@end
