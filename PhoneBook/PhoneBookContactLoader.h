//
//  PhoneBookContactLoader.h
//  PhoneBook
//
//  Created by chuonghm on 8/3/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "PhoneBookContact+CoreDataProperties.h"

typedef void (^PhoneBookContactLoaderCompletion) (BOOL granted);

/**
 Object for load contact from phone book
 */
@interface PhoneBookContactLoader : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

/**
 Get phone book contacts 

 @param completion - return result after completion
 @param queue call back queue
 */
- (void)getPhoneBookContactsWithCompletion:(PhoneBookContactLoaderCompletion) completion
                             callbackQueue:(NSOperationQueue *)queue;

@end
