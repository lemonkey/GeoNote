//
//  NotesRootTableViewController.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#define kAlertNoData    0

@class GeoNoteAppDelegate;

@interface NotesRootTableViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *notesArray;
@property (nonatomic, retain) UIBarButtonItem *btnRefresh;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign) GeoNoteAppDelegate *appDelegate;

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
-(IBAction)btnRefresh:(UIBarButtonItem *)sender;
-(void)refreshView;
-(void)loadData;

@end
