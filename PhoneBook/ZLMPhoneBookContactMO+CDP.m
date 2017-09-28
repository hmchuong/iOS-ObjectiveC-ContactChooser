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

#pragma mark - Private static

/**
 Get persistent store coordinator

 @return persistent store coordinator
 */
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *coordinator = nil;
    
    if ([delegate respondsToSelector:@selector(persistentStoreCoordinator)]) {
        coordinator = [delegate persistentStoreCoordinator];
    }
    return coordinator;
}

/**
 Get private (background) managed object context

 @return background object context
 */
+ (NSManagedObjectContext *)privateManagedObjectContext {
    
    NSManagedObjectContext *context;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

/**
 Save context to core data
 */
+ (void)saveContext {
    
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(saveContext)]) {
        [delegate saveContext];
    }
}

/**
 Construct a default ZLMPhoneBookContactMO object

 @return default object to store in database
 */
+ (instancetype)defaultObject {
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
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
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
    
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
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
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
    
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
    
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
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
    
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

@end
