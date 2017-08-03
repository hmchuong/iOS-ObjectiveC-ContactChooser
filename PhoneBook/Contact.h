//
//  Contact.h
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NICellCatalog.h"
#import "NimbusCollections.h"
#import <Contacts/Contacts.h>

/**
 Contact object - store data of each phone book contact
 */
@interface Contact : NSObject<NINibCellObject,NICollectionViewNibCellObject>

@property (strong, nonatomic) NSString *avatarKey;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *middlename;
@property (strong, nonatomic) NSString *lastname;
@property (strong, readonly, nonatomic) NSString *fullname;
@property BOOL isHighlighted;

/**
 Init contact with CNContact object

 @param cnContact - CNContact object
 @return contact after init
 */
- (instancetype)initWithCNContact:(CNContact *)cnContact;

/**
 Get avatar image

 @return avatar of contact
 */
- (UIImage *)avatarImage;
@end
