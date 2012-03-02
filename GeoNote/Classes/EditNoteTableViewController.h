//
//  EditNoteTableViewController.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kEditNoteNumberOfEditableRows		4
#define kEditNoteTitleRowIndex				0
#define kEditNoteTextRowIndex				1
#define kEditNoteUpdatedDateRowIndex        2
#define kEditNoteCoordinateRowIndex         3

#define kLabelTag							4096

#define kDefaultEditNoteHeaderHeight         50
#define kEditNoteHeaderHeightOffset          20
#define kDefaultEditNoteFooterHeight         60


@class EditNoteTableViewCustomHeader;
@class Note;

@interface EditNoteTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, retain) CLLocation *location;

@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic) int headerHeight;
@property (nonatomic) int footerHeight;
@property (nonatomic, retain) Note *currentNote;

-(IBAction)btnSaveClick:(id)sender;
-(void)hideKeyboard;
-(IBAction)textFieldDone:(id)sender;
-(void)setHeaderTextAndAdjustHeight:(NSString *)text headerView:(EditNoteTableViewCustomHeader *)headerView;

@end