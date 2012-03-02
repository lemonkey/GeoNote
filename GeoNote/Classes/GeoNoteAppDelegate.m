//
//  GeoNoteAppDelegate.m
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import "GeoNoteAppDelegate.h"
#import "NotesViewController.h"
#import "MapViewController.h"
#import "MapRootViewController.h"
#import "UIApplication+Network.h"
#import "Note.h"


@implementation GeoNoteAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)dealloc {
    DLog(@"");
    
    [_window release];
    
    self.tabBarController.delegate = nil;
    [_tabBarController release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];   
        
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DLog(@"");
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
        [Utility showGeneralAlertMsg:@"Could not access core data." withTitle:@"Error"];
    } else {
        // Override point for customization after application launch.
        
        // Setup tab views
        UIViewController *notesVC = [[[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil] autorelease];
        UIViewController *mapVC = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
        
        self.tabBarController = [[[UITabBarController alloc] init] autorelease];
        self.tabBarController.viewControllers = [NSArray arrayWithObjects:notesVC, mapVC, nil];
        
        self.tabBarController.delegate = self;
        
        self.window.rootViewController = self.tabBarController;
        [self.window makeKeyAndVisible];
        
        // Check to see if a network connection exists (important if GPS cannot
        // locate user and it has to use either wifi or cell tower triangulation)
        [self checkNetworkStatus];
    }
        
    return YES;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    DLog(@"");
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

void uncaughtExceptionHandler(NSException *exception) {
	DLog(@"##### Uncaught exception: %@ ####", exception);
    
    // Log exception for later analysis...
}


#pragma mark -
#pragma mark Startup methods

// Warns user with an alert if a network connections cannot be found.
-(void)checkNetworkStatus {
    DLog(@"");
    
    [self broadcastNetworkStatus:[UIApplication hasNetworkConnection]];
}

-(void)broadcastNetworkStatus:(BOOL)found {
    DLog(@"");
    
    NSDictionary *userInfoDict;
    
    if(!found) {
        [Utility showGeneralAlertMsg:kMsgNoNetworkWarning withTitle:@"Warning"];
    }

    userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:found], kKeyNetworkFound, nil];

    // Send notification of current location coordinates to any subscribers
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNetworkStatus object:self userInfo:userInfoDict];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    DLog(@"GeoNoteAppDelegate - tabBarController:didSelectViewController:%@", viewController);

    if([viewController isKindOfClass:[MapViewController class]]) {
        DLog(@"Map view");

        // Map will automatically refresh on view
        
    } else {
        
        if([viewController isKindOfClass:[NotesViewController class]]) {
            DLog(@"Notes view");

            // Notes listing will automatically refresh on view
            
        }
    }
}

// Called by NotesViewController if user has no notes saved yet
// and it is the first time the notes view has been seen and user
// agrees to go directly to the map view from the alert.
-(void)switchToMap {
    DLog(@"");
    [self.tabBarController setSelectedIndex:kMapViewIndex];
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    DLog(@"GeoNoteAppDelegate - tabBarController:didEndCustomizingViewControllers:changed:%@", changed);
}


#pragma mark -
#pragma mark CoreData methods

-(Note *)getNoteWithId:(NSNumber *)noteId {
    DLog(@"noteId: %@", noteId);

    Note *note = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(noteId = %d)", [noteId integerValue]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil || [mutableFetchResults count] == 0) {
        [Utility showGeneralAlertMsg:[NSString stringWithFormat:@"Note was note found! %@", error] withTitle:@"Error"];
    } else {
        note = [mutableFetchResults objectAtIndex:0];
    }
    
    [mutableFetchResults release];
    [request release];
    
    return note;
}

- (void)saveContext {
    DLog(@"");
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    DLog(@"");
    
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    DLog(@"");
    
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Notes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    DLog(@"");
    
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Notes.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
