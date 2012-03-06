//
//  MapTabViewController.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/24/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "MapViewController.h"
#import "MapRootViewController.h"


@implementation MapViewController
@synthesize mapNavigationController = _mapNavigationController;

-(void)dealloc {
    DLog(@"");
    
    [self.mapNavigationController.view removeFromSuperview];
    self.mapNavigationController = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    DLog(@"");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tab_map" ofType:@"png"]]; 
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    DLog(@"");
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Called when app delegate receives low memory warning and notes view controller
// isn't currently visible.
-(void)memoryWarningCleanup {
    DLog(@"");

    // For proper cleanup of MapRootViewController
    for (UIViewController *curVC in self.mapNavigationController.viewControllers) {
        [curVC release];
    }
    self.mapNavigationController.viewControllers = nil;
    
    [self.mapNavigationController.view removeFromSuperview];
    self.mapNavigationController = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    DLog(@"");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(!self.mapNavigationController) {
        
        MapRootViewController *mapRootViewController = [[MapRootViewController alloc] initWithNibName:@"MapRootViewController" bundle:nil];
        
        UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:mapRootViewController];
        self.mapNavigationController = aNavigationController;
        
        [self.view addSubview:[self.mapNavigationController view]];
        
        [mapRootViewController release];
        [aNavigationController release];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
