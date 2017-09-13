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
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation PhoneBookContact (CoreDataProperties)

@dynamic firstName;
@dynamic identifier;
@dynamic lastName;
@dynamic middleName;

+ (NSArray<PhoneBookContact *> *)getAllRecords {
    
    NSError *__block error = nil;
    NSArray *__block contacts = nil;

    dispatch_sync(kBgQueue, ^{
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
    
    dispatch_sync(kBgQueue, ^{
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

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    id delegate = [[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *coordinator = nil;
    
    if ([delegate respondsToSelector:@selector(persistentStoreCoordinator)]) {
        coordinator = [delegate persistentStoreCoordinator];
    }
    return coordinator;
}

+ (NSManagedObjectContext *)privateManagedObjectContext {
    
    NSManagedObjectContext *context;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

+ (void)saveContext {
    NSError *error = nil;
    if ([[PhoneBookContact privateManagedObjectContext] hasChanges] && ![[PhoneBookContact privateManagedObjectContext]save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }

}

+ (instancetype)init {
    
    PhoneBookContact *contact = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME inManagedObjectContext:[PhoneBookContact privateManagedObjectContext]];
    
    return contact;
}

+ (instancetype)insertWithCNContact:(CNContact *)cnContact {
    
    PhoneBookContact *__block contact = nil;
    
    dispatch_sync(kBgQueue, ^{
        contact = [PhoneBookContact init];
        
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
    dispatch_sync(kBgQueue, ^{
        contact = [PhoneBookContact init];
        
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
