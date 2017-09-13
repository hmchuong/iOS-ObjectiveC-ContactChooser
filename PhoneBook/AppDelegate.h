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

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

/**
 Get persistent store coordinator

 @return persistent store coordinator
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 Get background managed object context

 @return background managed object context
 */
- (NSManagedObjectContext *)managedObjectContext;

@end

