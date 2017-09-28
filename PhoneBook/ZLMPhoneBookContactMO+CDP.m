//
//  ZLMPhoneBookContactMO+CDP.m
//  
//
//  Created by chuonghm on 9/13/17.
//
//

#import "ZLMPhoneBookContactMO+CDP.h"
#import <UIKit/UIKit.h>
#import "ZLMImageCache.h"
#import "AppDelegate.h"

#define ENTITY_NAME @"Contacts"

@implementation ZLMPhoneBookContactMO (CoreDataProperties)

@dynamic firstName;
@dynamic identifier;
@dynamic lastName;
@dynamic middleName;

/**
 Construct a default ZLMPhoneBookContactMO object

 @return default object to store in database
 */
+ (instancetype)defaultObject {
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO managedObjectContext];
    ZLMPhoneBookContactMO *__block contact = nil;
    
    [context performBlockAndWait:^{
        contact = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                inManagedObjectContext:context];
    }];
    
    return contact;
}

#pragma mark - Public static

+ (NSArray<ZLMPhoneBookContact *> *)getAllRecords {
    
    
    NSArray *__block fetchResult = nil;
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO managedObjectContext];
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        fetchResult = [context executeFetchRequest:[ZLMPhoneBookContactMO fetchRequest]
                                          error:&error];
        if (error != nil) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        }
    }];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    if (fetchResult != nil) {
        for (ZLMPhoneBookContactMO *record in fetchResult) {
            
            ZLMPhoneBookContact *contact = [[ZLMPhoneBookContact alloc] init];
            contact.firstName = record.firstName;
            contact.lastName = record.lastName;
            contact.middleName = record.middleName;
            contact.identifier = record.identifier;
            
            [contacts addObject:contact];
        }
    }
    
    return contacts;
}

+ (void)deleteAllRecords {
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO managedObjectContext];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[ZLMPhoneBookContactMO fetchRequest]];
    
    [context performBlock:^{
        NSError *deleteError = nil;
        [[ZLMPhoneBookContactMO persistentStoreCoordinator] executeRequest:delete
                                                               withContext:context
                                                                     error:&deleteError];
        if (deleteError != nil) {
            NSLog(@"Unresolved error %@, %@", deleteError, deleteError.userInfo);
        }
    }];
    
    [ZLMPhoneBookContactMO saveContext];
    
}

+ (NSFetchRequest<ZLMPhoneBookContactMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName: ENTITY_NAME];
}

+ (void)insert:(ZLMPhoneBookContact *)contact {
    
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO managedObjectContext];
    
    [context performBlock:^{
        
        ZLMPhoneBookContactMO *contactMO = [ZLMPhoneBookContactMO defaultObject];
        contactMO.firstName = contact.firstName;
        contactMO.middleName = contact.middleName;
        contactMO.lastName = contact.lastName;
        contactMO.identifier = contact.identifier;
    }];
    
    [ZLMPhoneBookContactMO saveContext];
}

+ (void)insertContacts:(NSArray<ZLMPhoneBookContact *> *)contacts {
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO managedObjectContext];
    
    [context performBlock:^{
        for (ZLMPhoneBookContact *contact in contacts) {
            ZLMPhoneBookContactMO *contactMO = [ZLMPhoneBookContactMO defaultObject];
            contactMO.firstName = contact.firstName;
            contactMO.middleName = contact.middleName;
            contactMO.lastName = contact.lastName;
            contactMO.identifier = contact.identifier;
        }
        
        [ZLMPhoneBookContactMO saveContext];
    }];
}

#pragma mark - CoreData

/**
 Get persistent store coordinator
 
 @return persistent store coordinator
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    static NSPersistentStoreCoordinator *persistentStoreCoordinator;
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[ZLMPhoneBookContactMO applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhoneBook.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"com.vn.vng.zalo.contact.error" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

/**
 Get managed object model

 @return managed object model
 */
+ (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    static NSManagedObjectModel *managedObjectModel;
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhoneBook" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return managedObjectModel;
}

/**
 Get current managed object content

 @return manage object context
 */
+ (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    static NSManagedObjectContext *managedObjectContext;
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [ZLMPhoneBookContactMO persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
    return managedObjectContext;
}

/**
 Save context to core data
 */
+ (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = [ZLMPhoneBookContactMO managedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        BOOL hasChanges = [managedObjectContext hasChanges];
        if (hasChanges && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/**
 Get documents directory

 @return url of application document directory
 */
+ (NSURL *)applicationDocumentsDirectory {
    
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Your Bundle Indentifier" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
