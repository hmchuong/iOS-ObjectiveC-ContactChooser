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

+ (NSArray<ZLMPhoneBookContactMO *> *)getAllRecords {
    
    
    NSArray *__block contacts = nil;
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        contacts = [context executeFetchRequest:[ZLMPhoneBookContactMO fetchRequest]
                                          error:&error];
        if (error != nil) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        }
    }];
    
    
    
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

+ (void)insertWithCNContact:(CNContact *)cnContact {
    
    
    NSManagedObjectContext *context = [ZLMPhoneBookContactMO privateManagedObjectContext];
    
    [context performBlock:^{
        
        ZLMPhoneBookContactMO *contact = [ZLMPhoneBookContactMO defaultObject];
        contact.firstName = cnContact.givenName;
        contact.middleName = cnContact.middleName;
        contact.lastName = cnContact.familyName;
        contact.identifier = cnContact.identifier;
    }];
    
    UIImage *avatar = [UIImage imageWithData:[cnContact imageData]];
    
    // if has avatar -> store to cache
    if (avatar != nil) {
        [ZLMImageCache.sharedInstance storeImage:avatar
                                         withKey:cnContact.identifier];
    }
    
    [ZLMPhoneBookContactMO saveContext];
}

+ (void)insertWithCNContacts

+ (void)insertWithABRecordRef:(ABRecordRef)aBRecordRef {
    
    // Name
    CFStringRef firstName, middleName, lastName;
    firstName = ABRecordCopyValue(aBRecordRef, kABPersonFirstNameProperty);
    middleName = ABRecordCopyValue(aBRecordRef, kABPersonMiddleNameProperty);
    lastName = ABRecordCopyValue(aBRecordRef, kABPersonLastNameProperty);
    
    // ID
    ABRecordID recordID = ABRecordGetRecordID(aBRecordRef);
    
    // Avatar
    UIImage *avatar;
    if (ABPersonHasImageData(aBRecordRef)) {
        avatar = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(aBRecordRef)];
    }
    
    [[ZLMPhoneBookContactMO privateManagedObjectContext] performBlock:^{
        
        ZLMPhoneBookContactMO *contact = [ZLMPhoneBookContactMO defaultObject];
        contact.firstName = [NSString stringWithFormat:@"%@",firstName];
        contact.middleName = [NSString stringWithFormat:@"%@",middleName];
        contact.lastName = [NSString stringWithFormat:@"%@",lastName];
        contact.identifier = [NSString stringWithFormat:@"%d", recordID];
    }];
    
    [ZLMPhoneBookContactMO saveContext];
    
    // Store to cache
    if (avatar != nil) {
        [ZLMImageCache.sharedInstance storeImage:avatar
                                         withKey:[NSString stringWithFormat:@"%d", recordID]];
    }
}

@end
