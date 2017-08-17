//
//  PBCModelObject.h
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ContactModelObject.h"
#import "PhoneBookContact.h"

/**
 Contact cell object - store data of each phone book contact cell
 */
@interface PBCModelObject : ContactModelObject

@property (strong, nonatomic) NSString *avatarKey;      // Key storing image in cache
@property (strong, nonatomic) NSString *firstname;      // first name of contact
@property (strong, nonatomic) NSString *middlename;     // middle name of contact
@property (strong, nonatomic) NSString *lastname;       // last name of contact

/**
 Init with PhoneBookContact

 @param phoneBookContact - contact to init
 @return PhoneBookContactCell object
 */
- (instancetype)initWithPhoneBookContact:(PhoneBookContact *)phoneBookContact;

@end
