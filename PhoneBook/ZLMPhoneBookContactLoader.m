//
//  ZLMPhoneBookContactLoader.m
//  PhoneBook
//
//  Created by chuonghm on 8/3/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ZLMPhoneBookContactLoader.h"
#import "UIKit/UIKit.h"
#import "AppDelegate.h"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation ZLMPhoneBookContactLoader

#pragma mark - Constructors

- (instancetype)init {
    
    self = [super init];
    
    return self;
}

+ (instancetype)sharedInstance {
    
    static ZLMPhoneBookContactLoader *sharedImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageCache = [[self alloc] init];
    });
    return sharedImageCache;
}

#pragma mark - Private methods

/**
 Load phone book contacts with CNContact

 @param completion - block to return result after load
 @param queue callback queue
 */
- (void)loadPhoneBookContactsByCNContacts:(ZLMPBCLCompletionBlock)completion
                            callbackQueue:(NSOperationQueue *)queue {
    
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        if (granted) {
            
            //keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactImageDataKey, CNContactIdentifierKey];
            
            NSString *containerId = store.defaultContainerIdentifier;
            
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            for (CNContact *contact in cnContacts) {
                
                [contacts addObject:[[ZLMPhoneBookContact alloc] initWithCNContact:contact]];
                
            }
            
            // Delete all contacts in DB
            [ZLMPhoneBookContactMO deleteAllRecords];
            
            // Add to DB
            [ZLMPhoneBookContactMO insertContacts:contacts];
        } else {
            [contacts addObjectsFromArray:[ZLMPhoneBookContactMO getAllRecords]];
        }
        
        [queue addOperationWithBlock:^{
            completion(granted, contacts);
        }];
    }];
}

/**
 Load phone book contacts with AddressBook

 @param completion - block to return result after load
 @param queue callback queue
 */
- (void)loadPhoneBookContactsByAddressBook:(ZLMPBCLCompletionBlock)completion
                             callbackQueue:(NSOperationQueue *)queue {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    BOOL __block accessGranted = NO;
    
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef cfError) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    } else {        // iOS 5
        accessGranted = YES;
    }
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    if (accessGranted) {
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        for (int i = 0; i < nPeople; i ++) {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
            [contacts addObject:[[ZLMPhoneBookContact alloc] initWithABRecordRef:ref]];
        }
        
        // Delete all contacts in DB
        [ZLMPhoneBookContactMO deleteAllRecords];
        
        // Add to DB
        [ZLMPhoneBookContactMO insertContacts:contacts];
    } else {
        [contacts addObjectsFromArray:[ZLMPhoneBookContactMO getAllRecords]];
    }
    [queue addOperationWithBlock:^{
        completion(accessGranted, contacts);
    }];

}


#pragma mark - Public methods

- (void)getPhoneBookContactsWithCompletion:(ZLMPBCLCompletionBlock)completion
                             callbackQueue:(NSOperationQueue *)queue{
    
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [self loadPhoneBookContactsByAddressBook:completion callbackQueue:queue];
    } else {
        [self loadPhoneBookContactsByCNContacts:completion callbackQueue:queue];
    }
}


@end
