//
//  GeoNoteAppDelegate.h
//  GeoNote
//
//  Created by Ari Braginsky on 2/23/12.
//  Copyright (c) 2012 aribraginsky.com. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kNoteViewIndex  0
#define kMapViewIndex   1

@class NotesViewController;
@class MapViewController;
@class MapTabViewController;
@class Note;

@interface GeoNoteAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (readonly, nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) UIViewController *currentViewController;

void uncaughtExceptionHandler(NSException *exception);
-(void)checkNetworkStatus;
-(void)broadcastNetworkStatus:(BOOL)found;
-(void)switchToMap;
-(void)saveContext;
-(NSURL *)applicationDocumentsDirectory;
-(Note *)getNoteWithId:(NSNumber *)noteId;

@end
