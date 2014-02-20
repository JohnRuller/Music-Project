//
//  AppDelegate.h
//  Music Project
//
//  Created by John Ruller on 2013-11-07.
//  Copyright (c) 2013 John Ruller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPCConnection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) MPCConnection *mpcController;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end
