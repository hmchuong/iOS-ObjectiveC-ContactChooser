//
//  Contact.h
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "ContactModelObject.h"

/**
 Contact object - store data of each phone book contact
 */
@interface ContactPhoneBook : ContactModelObject<ContactModelObjectDelegate>

@property (strong, nonatomic) NSString *avatarKey;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *middlename;
@property (strong, nonatomic) NSString *lastname;

/**
 Init contact with CNContact object

 @param cnContact - CNContact object
 @return contact after init
 */
- (instancetype)initWithCNContact:(CNContact *)cnContact;

@end
