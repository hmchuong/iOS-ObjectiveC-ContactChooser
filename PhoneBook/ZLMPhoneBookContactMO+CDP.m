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
    if ([[ZLMPhoneBookContactMO privateManagedObjectContext] hasChanges] && ![[ZLMPhoneBookContactMO privateManagedObjectContext]save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
}

/**
 Construct a default ZLMPhoneBookContactMO object

 @return default object to store in database
 */
+ (instancetype)defaultObject {
    
    ZLMPhoneBookContactMO *contact = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[ZLMPhoneBookContactMO privateManagedObjectContext]];
    
    return contact;
}

#pragma mark - Public static

+ (NSArray<ZLMPhoneBookContactMO *> *)getAllRecords {
    
    NSError *__block error = nil;
    NSArray *__block contacts = nil;

    dispatch_sync([ZLMPhoneBookContactMO getQueue], ^{
        contacts = [[ZLMPhoneBookContactMO privateManagedObjectContext] executeFetchRequest:[ZLMPhoneBookContactMO fetchRequest]
                                                                                 error:&error];
    });
    
    if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
    return contacts;
}

+ (void)deleteAllRecords {
    
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[ZLMPhoneBookContactMO fetchRequest]];
    
    NSError *__block deleteError = nil;
    
    dispatch_sync([ZLMPhoneBookContactMO getQueue], ^{
        [[ZLMPhoneBookContactMO persistentStoreCoordinator] executeRequest:delete
                                                          withContext:[ZLMPhoneBookContactMO privateManagedObjectContext]
                                                                error:&deleteError];
    });
    if (deleteError != nil) {
        NSLog(@"Unresolved error %@, %@", deleteError, deleteError.userInfo);
    }
}

+ (NSFetchRequest<ZLMPhoneBookContactMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName: ENTITY_NAME];
}

+ (instancetype)insertWithCNContact:(CNContact *)cnContact {
    
    ZLMPhoneBookContactMO *__block contact = nil;
    
    dispatch_sync([ZLMPhoneBookContactMO getQueue], ^{
        contact = [ZLMPhoneBookContactMO defaultObject];
        
        contact.firstName = cnContact.givenName;
        contact.middleName = cnContact.middleName;
        contact.lastName = cnContact.familyName;
        contact.identifier = cnContact.identifier;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *avatar = [UIImage imageWithData:[cnContact imageData]];
            
            // if has avatar -> store to cache
            if (avatar != nil) {
                [ZLMImageCache.sharedInstance storeImage:avatar
                                              withKey:contact.identifier];
            }
        });
        [ZLMPhoneBookContactMO saveContext];
    });
    
    return contact;
}

+ (instancetype)insertWithABRecordRef:(ABRecordRef)aBRecordRef {
    
    ZLMPhoneBookContactMO *__block contact;
    dispatch_sync([ZLMPhoneBookContactMO getQueue], ^{
        contact = [ZLMPhoneBookContactMO defaultObject];
        
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
            [ZLMImageCache.sharedInstance storeImage:avatar
                                          withKey:contact.identifier];
        }
        
        [ZLMPhoneBookContactMO saveContext];
    });
    
    return contact;
}

@end
