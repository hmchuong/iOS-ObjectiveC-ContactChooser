//
//  ContactPhoneBookLoader.m
//  PhoneBook
//
//  Created by chuonghm on 8/3/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactPhoneBookLoader.h"
#import "ThreadSafeMutableArray.h"

@interface ContactPhoneBookLoader()

@property(strong, nonatomic) NSMutableSet *contactPhoneBookLoaderDelegates;     // Set of delegates
@property(strong, nonatomic) dispatch_queue_t cpblDelegateQueue;    // Queue for accessing delegates set
@property BOOL isLoaded;

@end

@implementation ContactPhoneBookLoader

#pragma mark - Constructors

- (instancetype)init {
    
    self = [super init];
    
    _contactPhoneBookLoaderDelegates = [[NSMutableSet alloc] init];
    _cpblDelegateQueue = dispatch_queue_create("com.vn.vng.zalo.ContactPhoneBookLoader", DISPATCH_QUEUE_SERIAL);
    
    // Listen when contacts change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadContacts)
                                                 name:CNContactStoreDidChangeNotification
                                               object:nil];
    return self;
}

+ (instancetype)sharedInstance {
    
    static ContactPhoneBookLoader *sharedImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageCache = [[self alloc] init];
    });
    return sharedImageCache;
}

#pragma mark - Setters

- (void)setDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate {
    
#if DEBUG
    NSAssert(delegate, @"Delegate must be non null");
#endif
    
    // Add delegate to set
    dispatch_async(_cpblDelegateQueue, ^{
        [_contactPhoneBookLoaderDelegates addObject:delegate];
    });
    
    // Load contact for delegate
    [self loadContactsForDelegate:delegate];
}

#pragma mark - Private methods

/**
 Load contacts and update for all delegates
 */
- (void)loadContacts {
    
    // Get array of delegates
    NSArray __block *delegatesArray;
    dispatch_sync(_cpblDelegateQueue, ^{
        delegatesArray = [_contactPhoneBookLoaderDelegates allObjects];
    });
    
    for (id<ContactPhoneBookLoaderDelegate> delegate in delegatesArray) {
        [self loadContactsForDelegate:delegate];
    }
}

/**
 Notify delegate for starting update contacts

 @param delegate - delegate to update
 */
- (void)notifyStartUpdateForDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate {
    
    if ([delegate respondsToSelector:@selector(contactPhoneBookLoaderStartUpdateContacts)]) {
        [delegate contactPhoneBookLoaderStartUpdateContacts];
    }
}

/**
 Notify delegate for done update contacts

 @param delegate - delegate to update
 @param contacts - contacts after update
 @param error - error for fetching
 */
- (void)notifyDoneUpdateForDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate
                           contacts:(NSArray<CNContact *> *)contacts
                          withError:(NSError *)error {
    
    if ([delegate respondsToSelector:@selector(contactPhoneBookLoaderDoneUpdateContacts:withError:)]) {
        [delegate contactPhoneBookLoaderDoneUpdateContacts:contacts withError:error];
    }
}

/**
 Notify delegate for permission denied

 @param delegate - delegate to update
 */
- (void)notifyPermissionDeniedForDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate {
    
    if ([delegate respondsToSelector:@selector(contactPhoneBookLoaderPermissionDenied)]) {
        [delegate contactPhoneBookLoaderPermissionDenied];
    }
}

/**
 Get contact properties keys for fetching

 @param delegate - delegate to get
 @return - NSArray of properties
 */
- (NSArray *)getContactPropertiesKeysFromDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate {
    
    if ([delegate respondsToSelector:@selector(contactPhoneBookLoaderGetContactPropertiesKeys)]) {
        return [delegate contactPhoneBookLoaderGetContactPropertiesKeys];
    }
    
#if DEBUG
    NSAssert(NO, @"Cannot file method 'contactPhoneBookLoaderGetContactPropertiesKeys' in %@", NSStringFromClass([delegate class]));
#endif
    
    return @[];
}

#pragma mark - Public methods

- (void)loadContactsForDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate {
    
    [self notifyStartUpdateForDelegate:delegate];
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            
            //keys with fetching properties
            NSArray *keys = [self getContactPropertiesKeysFromDelegate:delegate];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            
            [self notifyDoneUpdateForDelegate:delegate
                                     contacts:cnContacts
                                    withError:error];
        } else {
            [self notifyPermissionDeniedForDelegate:delegate];
        }
    }];
}


@end
