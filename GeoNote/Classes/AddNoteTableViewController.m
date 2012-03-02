//
//  AddNoteTableViewController.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/29/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "AddNoteTableViewController.h"
#import "TableViewFormCustomCell.h"
#import "AddNoteCustomHeader.h"
#import "AddNoteCustomFooter.h"
#import "GeoNoteAppDelegate.h"
#import "Note.h"


@implementation AddNoteTableViewController
@synthesize location = _location;
@synthesize fieldLabels = _fieldLabels;
@synthesize tempValues = _tempValues;
@synthesize textFieldBeingEdited = _textFieldBeingEdited;
@synthesize headerHeight = _headerHeight;
@synthesize footerHeight = _footerHeight;

-(void)dealloc {
    DLog(@"");
    
    self.location = nil;    
    self.fieldLabels = nil;
    self.tempValues = nil;
    self.textFieldBeingEdited = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    self.navigationItem.title = @"Add Note";

    // Adding login button to top nav instead of on the view
    UIBarButtonItem *btnNavAdd = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(btnAddClick:)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = btnNavAdd;
    [btnNavAdd release];
    
    // Define the form fields
	NSArray *array = [[NSArray alloc] initWithObjects:@"Title", @"Text", nil];
	self.fieldLabels = array;
	[array release];
    
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	self.tempValues = dict;
	[dict release];
	
	[self.tableView setBackgroundColor:[UIColor whiteColor]];
	
	self.headerHeight = kDefaultAddNoteHeaderHeight;
	self.footerHeight = kDefaultAddNoteFooterHeight;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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

-(IBAction)btnAddClick:(id)sender {
	DLog(@"");
    
	[self hideKeyboard];
	
	// Get values out of text fields...
	NSString *title = @"";
    NSString *text = @"";
    
	if (self.textFieldBeingEdited != nil)
	{
		NSNumber *tfKey = [[NSNumber alloc] initWithInt:self.textFieldBeingEdited.tag];
		[self.tempValues setObject:self.textFieldBeingEdited.text forKey:tfKey];
		[tfKey release];		
	}
	
    for (NSNumber *key in [self.tempValues allKeys])
    {
        switch ([key intValue]) {
            case kAddNoteTitleRowIndex:
                title = [self.tempValues objectForKey:key];
                break;
            case kAddNoteTextRowIndex:
                text = [self.tempValues objectForKey:key];
                break;
            default:
                break;
        }
    }
    
	NSString *trimmedTitle;
	NSString *trimmedText;
	trimmedTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
    if([trimmedTitle isEqualToString:@""]) {
		[Utility showGeneralAlertMsg:@"Note title is required" withTitle:@"Error"];		
	} else {
		if([trimmedText isEqualToString:@""]) {
			[Utility showGeneralAlertMsg:@"Note text is required" withTitle:@"Error"];			
		} else {
			
            DLog(@"Saving note to location: %@", self.location);
            
            GeoNoteAppDelegate *appDelegate = (GeoNoteAppDelegate *)[[UIApplication sharedApplication] delegate];

            // Create and configure a new instance of the Note entity.
            Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:appDelegate.managedObjectContext];
            
            [note setNoteId:[[Utility instance] getNextNoteIndex]];
            [note setCreateDate:[NSDate date]];
            [note setUpdateDate:[NSDate date]];
            [note setLongitude:[NSNumber numberWithDouble:self.location.coordinate.longitude]];
            [note setLatitude:[NSNumber numberWithDouble:self.location.coordinate.latitude]];
            [note setTitle:trimmedTitle];
            [note setText:trimmedText];
            
            NSError *error = nil;
            if (![appDelegate.managedObjectContext save:&error]) {
               
                [Utility showGeneralAlertMsg:[NSString stringWithFormat:@"There was a problem saving your note: \r\n%@", error] withTitle:@"Error"];
                
            } else {            
                // Add to local store and then return to map which will refresh and show new pin
                // associated with note.
                [self.navigationController popViewControllerAnimated:YES];                
            }
		}
	}
}

-(void)hideKeyboard {
	DLog(@"self.textFieldBeingEdited: %@", self.textFieldBeingEdited);
    
	if(self.textFieldBeingEdited != nil) {
		[self.textFieldBeingEdited resignFirstResponder];
	}
}


#pragma mark -
#pragma mark Table View Form Methods

-(IBAction)textFieldDone:(id)sender {
    DLog(@"");
    
	// Calculate what the next field is and become first responder
	// for it so that user is able to edit one after another.
	//
	// If more than kNumberOfEditableRows rows, if user gets to the bottom
	// of the listing of rows, when we loop back to the top, the
	// table view must scroll into position.
	
	UITableViewCell *cell = (UITableViewCell *)[[(UIView *)sender superview] superview];
	UITableView *table = (UITableView *)[cell superview];
	NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
	
	NSUInteger row = [textFieldIndexPath row];
	row++;
	
	BOOL isLastField = NO;
	if (row >= kAddNoteNumberOfEditableRows)
	{
		isLastField = YES;
		row = 0;
	}
	
	NSUInteger newIndex[] = {0, row};
	
	NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
	
	UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
	
	UITextField *nextField = nil;
	
	for (UIView *oneView in nextCell.contentView.subviews)
	{
		if ([oneView isMemberOfClass:[UITextField class]])
			nextField = (UITextField *)oneView;
	}
	
	// If on the last row in the form, remove responder so we can see whatever
	// might be below it...
	if(!isLastField) {
		
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
		
		// Warning: if header is a certain height, this auto-scroll may not be scrolling
		// all of the way to the top of the page...
		
		[nextField becomeFirstResponder];
	}
}

#pragma mark -
#pragma mark Table Data Source Methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kDefaultTableViewFormCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return kAddNoteNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"TableViewFormCustomCell";
	TableViewFormCustomCell *cell = (TableViewFormCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		DLog(@"New TableViewFormCustomCell");
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TableViewFormCustomCell" owner:nil options:nil];
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[TableViewFormCustomCell class]])
			{
				cell = (TableViewFormCustomCell *)currentObject;
				break;
			}
		}
	}
	
	[[cell lblName] setTag:kLabelTag];
	
	[[cell txtField] setClearsOnBeginEditing:NO];
	[[cell txtField] setDelegate:self];
	[[cell txtField] setReturnKeyType:UIReturnKeyNext];
	[[cell txtField] addTarget:self 
						action:@selector(textFieldDone:) 
			  forControlEvents:UIControlEventEditingDidEndOnExit];
	
	
	NSUInteger row = [indexPath row];
	
	// Set values for both label and textfield depending on which row we're in
	////////////////////////////////////////////////////////////////////////////////
	
	UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
	UITextField *textField = nil;
	for (UIView *oneView in cell.contentView.subviews)
	{
		// Warning: Assumes 1 textfield exists in TableViewFormCustomCell
		
		if ([oneView isMemberOfClass:[UITextField class]])
			textField = (UITextField *)oneView;
	}
	
	label.text = [self.fieldLabels objectAtIndex:row];
	
	NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
	switch (row) {
		case kAddNoteTitleRowIndex:
        {
			if ([[self.tempValues allKeys] containsObject:rowAsNum])
				textField.text = [self.tempValues objectForKey:rowAsNum];
			else {				
			}
			
			[textField setKeyboardType:UIKeyboardTypeDefault];
			[textField setSecureTextEntry:NO];
			[textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [textField becomeFirstResponder];
			
			break;
        }
		case kAddNoteTextRowIndex:
        {
			if ([[self.tempValues allKeys] containsObject:rowAsNum])
				textField.text = [self.tempValues objectForKey:rowAsNum];
			else {				
			}
			
			[textField setKeyboardType:UIKeyboardTypeDefault];
			[textField setSecureTextEntry:NO];
			[textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            
			break;
        }
		default:
			break;
	}
	
	if (self.textFieldBeingEdited == textField)
		self.textFieldBeingEdited = nil;
	
	textField.tag = row;
	[rowAsNum release];
	
	return cell;
}

#pragma mark -
#pragma mark UITableView Header and Footer

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return self.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{        
	AddNoteCustomHeader *headerView = nil;
	
	if (headerView == nil) {
		DLog(@"New AddNoteCustomHeader");
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddNoteCustomHeader" owner:nil options:nil];
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[AddNoteCustomHeader class]])
			{
				headerView = (AddNoteCustomHeader *)currentObject;
				break;
			}
		}
	}
	
	// TODO: Set text here if text is dynamic and we need to resize height of header
	//[self setHeaderTextAndAdjustHeight:@"Some text for the header that can wrap onto two lines, etc." headerView:headerView];
    
	// Detect taps to hide keyboard
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	[headerView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
	
	return headerView;
}

-(void)setHeaderTextAndAdjustHeight:(NSString *)text headerView:(AddNoteCustomHeader *)headerView {
	DLog(@"");
	
	//int headerYDelta = 0;
	int headerHeightBefore = headerView.frame.size.height;
	
	DLog(@"height before: %d", headerHeightBefore);
	
	int headerHeightAfter = 0;
	
	// Add text
	[[headerView lblHeader] setText:text];
	
	// Adjust height of header and set header height
	[Utility verticallyAlignLabel:[headerView lblHeader]];
	
	// Get after height
	headerHeightAfter = [headerView lblHeader].frame.size.height;
	
	DLog(@"height before: %d", headerHeightAfter);
	
	//headerYDelta = headerHeightAfter - headerHeightBefore;
	
	self.headerHeight = headerHeightAfter + kAddNoteHeaderHeightOffset;
}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return self.footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	AddNoteCustomFooter *footerView = nil;
	
	if (footerView == nil) {
		
		DLog(@"New AddNoteCustomFooter");
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddNoteCustomFooter" owner:nil options:nil];
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[AddNoteCustomFooter class]])
			{
				footerView = (AddNoteCustomFooter *)currentObject;
				break;
			}
		}
	}
	
	// TODO: assign actions to elements in footer as necessary
	
	// Detect taps to hide keyboard
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	[footerView addGestureRecognizer:gestureRecognizer];
	[gestureRecognizer release];
    
	return footerView;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark -
#pragma mark Text Field Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textFieldBeingEdited = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
	[self.tempValues setObject:textField.text forKey:tagAsNum];
	[tagAsNum release];		
}

@end