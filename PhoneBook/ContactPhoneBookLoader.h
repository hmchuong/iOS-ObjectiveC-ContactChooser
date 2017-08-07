//
//  ContactPhoneBookLoader.h
//  PhoneBook
//
//  Created by chuonghm on 8/3/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

@class ContactPhoneBookLoader;

/**
 Protocol for ContactPhoneBookLoader
 */
@protocol ContactPhoneBookLoaderDelegate <NSObject>

@required

/**
 Get CNContact properties keys for fetching

 @return NSArray contains properties keys
 */
- (NSArray *)contactPhoneBookLoaderGetContactPropertiesKeys;

@optional

/**
 Notify delegate when starting update phone book contacts
 */
- (void)contactPhoneBookLoaderStartUpdateContacts;

/**
 Return phone book contacts after fetching or updating

 @param contacts - CNContacts from phone book
 @param error - NSError while fetching
 */
- (void)contactPhoneBookLoaderDoneUpdateContacts:(NSArray<CNContact *> *)contacts
                                       withError:(NSError *)error;

/**
 Notify that this application cannot access phone book
 */
- (void)contactPhoneBookLoaderPermissionDenied;

@end

/**
 Object for load contact from phone book
 */
@interface ContactPhoneBookLoader : NSObject

@property (weak, nonatomic) id<ContactPhoneBookLoaderDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 Load contacts for delegate

 @param delegate - loading contacts from phone book for delegate
 */
- (void)loadContactsForDelegate:(id<ContactPhoneBookLoaderDelegate>)delegate;

@end
