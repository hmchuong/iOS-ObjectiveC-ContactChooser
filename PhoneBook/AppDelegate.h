//
//  AppDelegate.h
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)           UIWindow                        *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;
@property (readonly, strong)            NSPersistentContainer           *persistentContainer;

/**
 Save Core Data context
 */
- (void)saveContext;

/**
 Get document directory

 @return document directory url
 */
- (NSURL *)applicationDocumentsDirectory;
@end

