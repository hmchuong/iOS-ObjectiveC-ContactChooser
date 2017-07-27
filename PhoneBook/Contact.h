//
//  Contact.h
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Contact object - store data of each phone book contact
 */
@interface Contact : NSObject

@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *middlename;
@property (strong, nonatomic) NSString *lastname;
@property (strong, readonly, nonatomic) NSString *fullname;

@end
