//
//  PhoneBookContact+CoreDataProperties.m
//  
//
//  Created by chuonghm on 9/13/17.
//
//

#import "PhoneBookContact+CoreDataProperties.h"
#import <UIKit/UIKit.h>
#import "ImageCache.h"
#import "AppDelegate.h"

#define ENTITY_NAME @"Contacts"

@implementation PhoneBookContact (CoreDataProperties)

@dynamic firstName;
@dynamic identifier;
@dynamic lastName;
@dynamic middleName;

#pragma mark - Private static

/**
 Get coredata interaction queue

 @return serial queue
 */
+ (dispatch_queue_t)getQueue {
    
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.vn.vng.zalo.phonebook.coredata", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

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
    
    NSError *error = nil;
    if ([[PhoneBookContact privateManagedObjectContext] hasChanges] && ![[PhoneBookContact privateManagedObjectContext]save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
}

/**
 Construct a default PhoneBookContact object

 @return default object to store in database
 */
+ (instancetype)defaultObject {
    
    PhoneBookContact *contact = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[PhoneBookContact privateManagedObjectContext]];
    
    return contact;
}

#pragma mark - Public static

+ (NSArray<PhoneBookContact *> *)getAllRecords {
    
    NSError *__block error = nil;
    NSArray *__block contacts = nil;

    dispatch_sync([PhoneBookContact getQueue], ^{
        contacts = [[PhoneBookContact privateManagedObjectContext] executeFetchRequest:[PhoneBookContact fetchRequest]
                                                                                 error:&error];
    });
    
    if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
    return contacts;
}

+ (void)deleteAllRecords {
    
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[PhoneBookContact fetchRequest]];
    
    NSError *__block deleteError = nil;
    
    dispatch_sync([PhoneBookContact getQueue], ^{
        [[PhoneBookContact persistentStoreCoordinator] executeRequest:delete
                                                          withContext:[PhoneBookContact privateManagedObjectContext]
                                                                error:&deleteError];
    });
    if (deleteError != nil) {
        NSLog(@"Unresolved error %@, %@", deleteError, deleteError.userInfo);
    }
}

+ (NSFetchRequest<PhoneBookContact *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName: ENTITY_NAME];
}

+ (instancetype)insertWithCNContact:(CNContact *)cnContact {
    
    PhoneBookContact *__block contact = nil;
    
    dispatch_sync([PhoneBookContact getQueue], ^{
        contact = [PhoneBookContact defaultObject];
        
        contact.firstName = cnContact.givenName;
        contact.middleName = cnContact.middleName;
        contact.lastName = cnContact.familyName;
        contact.identifier = cnContact.identifier;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *avatar = [UIImage imageWithData:[cnContact imageData]];
            
            // if has avatar -> store to cache
            if (avatar != nil) {
                [ImageCache.sharedInstance storeImage:avatar
                                              withKey:contact.identifier];
            }
        });
        [PhoneBookContact saveContext];
    });
    
    return contact;
}

+ (instancetype)insertWithABRecordRef:(ABRecordRef)aBRecordRef {
    
    PhoneBookContact *__block contact;
    dispatch_sync([PhoneBookContact getQueue], ^{
        contact = [PhoneBookContact defaultObject];
        
        // Name
        CFStringRef firstName, middleName, lastName;
        firstName = ABRecordCopyValue(aBRecordRef, kABPersonFirstNameProperty);
        middleName = ABRecordCopyValue(aBRecordRef, kABPersonMiddleNameProperty);
        lastName = ABRecordCopyValue(aBRecordRef, kABPersonLastNameProperty);
        
        contact.firstName = [NSString stringWithFormat:@"%@",firstName];
        contact.middleName = [NSString stringWithFormat:@"%@",middleName];
        contact.lastName = [NSString stringWithFormat:@"%@",lastName];
        
        // ID
        ABRecordID recordID = ABRecordGetRecordID(aBRecordRef);
        contact.identifier = [NSString stringWithFormat:@"%d", recordID];
        
        // Avatar
        UIImage *avatar;
        if (ABPersonHasImageData(aBRecordRef)) {
            avatar = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(aBRecordRef)];
        }
        
        // Store to cache
        if (avatar != nil) {
            [ImageCache.sharedInstance storeImage:avatar
                                          withKey:contact.identifier];
        }
        
        [PhoneBookContact saveContext];
    });
    
    return contact;
}

@end
