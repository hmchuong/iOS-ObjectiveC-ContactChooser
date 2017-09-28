//
//  PhoneBookContact.h
//  PhoneBook
//
//  Created by chuonghm on 8/10/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

@import AddressBook;
@import Contacts;
#import <Foundation/Foundation.h>

/**
 Wrapper for both AddressBookContact and CNContact
 */
@interface ZLMPhoneBookContact : NSObject

@property (strong, nonatomic) NSString *firstName;      // First name
@property (strong, nonatomic) NSString *lastName;       // Last name
@property (strong, nonatomic) NSString *middleName;     // Middle name
@property (strong, nonatomic) NSString *identifier;     // ID

- (instancetype)init;

/**
 Init with CNContact object

 @param cnContact - CNContact to init
 @return PhoneBookContact object
 */
- (instancetype)initWithCNContact:(CNContact *)cnContact;

/**
 Init with AddressBookContact

 @param aBRecordRef - Contact to init
 @return PhoneBookContact object
 */
- (instancetype)initWithABRecordRef:(ABRecordRef)aBRecordRef;

@end
