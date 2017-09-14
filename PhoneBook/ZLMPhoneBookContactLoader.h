//
//  ZLMPhoneBookContactLoader.h
//  PhoneBook
//
//  Created by chuonghm on 8/3/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "ZLMPhoneBookContactMO+CDP.h"

typedef void (^ZLMPBCLCompletionBlock) (BOOL granted);

/**
 Object for load contact from phone book
 */
@interface ZLMPhoneBookContactLoader : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

/**
 Get phone book contacts 

 @param completion - return result after completion
 @param queue call back queue
 */
- (void)getPhoneBookContactsWithCompletion:(ZLMPBCLCompletionBlock) completion
                             callbackQueue:(NSOperationQueue *)queue;

@end
