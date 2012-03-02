//
//  NotesRootTableViewController.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "NotesRootTableViewController.h"
#import "Note.h"
#import "NotesCustomCell.h"
#import "GeoNoteAppDelegate.h"
#import "EditNoteTableViewController.h"
#import "MapRootViewController.h"


@implementation NotesRootTableViewController
@synthesize notesArray = _notesArray;
@synthesize btnRefresh = _btnRefresh;
@synthesize isFirstLoad = _isFirstLoad;
@synthesize appDelegate = _appDelegate;

-(void)dealloc {
    DLog(@"");
    
    self.notesArray = nil;
    self.btnRefresh = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.isFirstLoad = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    DLog(@"");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"");
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.appDelegate = (GeoNoteAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.title = @"Notes";
    
    // Setup edit button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(btnRefresh:)];
    self.btnRefresh.enabled = YES;
    
    self.navigationItem.rightBarButtonItem = self.btnRefresh;
    
    [self loadData];
    
    if(self.isFirstLoad && [self.notesArray count] <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"First time?" 
                                                        message:@"You haven't saved any notes yet.  Go to map?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"No" 
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = kAlertNoData;
        [alert show];
        [alert release];
    }
    
    self.isFirstLoad = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.notesArray = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    DLog(@"");

    if(!self.isFirstLoad) {
        [self refreshView];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Helper methods

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {	
	DLog(@"buttonIndex: %d, alertView cancelButtonIndex: %d", buttonIndex, [alertView cancelButtonIndex]);
	
	switch([alertView tag]) {
		case kAlertNoData: {
			if (buttonIndex == [alertView cancelButtonIndex]) {
                // Do nothing
			} else {
                // Switch to map
                [self.appDelegate switchToMap];
            }
		}
	}
}

-(IBAction)btnRefresh:(UIButton *)sender {
    DLog(@"");
    
    [self refreshView];
}

-(void)refreshView {
    DLog(@"");
    
    self.notesArray = nil;
    
    [self.tableView reloadData];
    
    [self loadData];
}

-(void)loadData {
    DLog(@"");
        
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
        [Utility showGeneralAlertMsg:[NSString stringWithFormat:@"There was a problem retrieving your notes: %@", error] withTitle:@"Error"];
    } else {
        DLog(@"Notes retrieved successfully.");
        [self setNotesArray:mutableFetchResults];
    }
    
    [mutableFetchResults release];
    [request release];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    // Return the number of rows in the section.
    return [self.notesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"");
    
    static NSString *CellIdentifier = @"NotesCustomCell";
	NotesCustomCell *cell = (NotesCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		DLog(@"New NotesCustomCell");
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NotesCustomCell" owner:nil options:nil];
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[NotesCustomCell class]])
			{
				cell = (NotesCustomCell *)currentObject;
				break;
			}
		}
	}
	
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:3];
    }
    
    Note *note = (Note *)[self.notesArray objectAtIndex:indexPath.row];
    
    cell.lblUpdateDate.text = [dateFormatter stringFromDate:[note updateDate]];
    
    NSString *coordStr = [NSString stringWithFormat:@"(%@, %@)",
                        [numberFormatter stringFromNumber:[note latitude]],
                        [numberFormatter stringFromNumber:[note longitude]]];
    cell.lblCoordinates.text = coordStr;
    
    cell.lblTitle.text = [note title];
    
    // For '>' icon
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"");
 
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object at the given index path.
        NSManagedObject *eventToDelete = [self.notesArray objectAtIndex:indexPath.row];
        [self.appDelegate.managedObjectContext deleteObject:eventToDelete];
        
        // Update the array and table view.
        [self.notesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        // Commit the change.
        NSError *error = nil;
        if (![self.appDelegate.managedObjectContext save:&error]) {
            // Handle the error.
            [Utility showGeneralAlertMsg:[NSString stringWithFormat:@"There was a problem deleting your note: %@", error] withTitle:@"Error"];
        }
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"");
    
    /*
    // Add navigation table view controller to show "add new note" view using current location
    EditNoteTableViewController *editNoteVC = [[EditNoteTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editNoteVC.currentNote = (Note *)[self.notesArray objectAtIndex:indexPath.row];
    
	// In order to override the default previous button that has the title
	// of the previous view's title, must add this here.
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel" style: UIBarButtonItemStyleBordered target: nil action: nil];
	[self.navigationItem setBackBarButtonItem: newBackButton];
	[newBackButton release];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:editNoteVC animated:YES];
	
    [editNoteVC release];
    */
    
    MapRootViewController *mapRootVC = [[MapRootViewController alloc] initWithNibName:@"MapRootViewController" bundle:nil];
    mapRootVC.showOnlyCurrentNote = YES;
    mapRootVC.currentNote = (Note *)[self.notesArray objectAtIndex:indexPath.row];
    
	// In order to override the default previous button that has the title
	// of the previous view's title, must add this here.
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
	[self.navigationItem setBackBarButtonItem: newBackButton];
	[newBackButton release];
	
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:mapRootVC animated:YES];
	
    [mapRootVC release];
}

@end
