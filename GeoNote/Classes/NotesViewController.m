//
//  GeoNoteFirstViewController.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "NotesViewController.h"
#import "NotesRootTableViewController.h"
#import "GeoNoteAppDelegate.h"


@implementation NotesViewController
@synthesize notesNavigationController = _notesNavigationController;

-(void)dealloc {
    DLog(@"");
    
    [self.notesNavigationController.view removeFromSuperview];
    self.notesNavigationController = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    DLog(@"");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Notes", @"Notes");
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tab_notes" ofType:@"png"]]; 
    }
    return self;
}
							
- (void)didReceiveMemoryWarning {
    DLog(@"");
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"");
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if(self.notesNavigationController == nil) {
        NotesRootTableViewController *notesRootTableViewController = [[NotesRootTableViewController alloc] initWithStyle:UITableViewStylePlain];
        
        UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:notesRootTableViewController];
        self.notesNavigationController = aNavigationController;
        
        [self.view addSubview:[self.notesNavigationController view]];
        
        [notesRootTableViewController release];
        [aNavigationController release];
    }
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
