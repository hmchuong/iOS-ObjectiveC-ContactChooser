//
//  LRUObject.h
//  PhoneBook
//
//  Created by chuonghm on 8/14/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Object stored in LRU cache
 */
@interface LRUObject : NSObject

@property (strong, nonatomic) id object;
@property NSUInteger cost;                              // cost of object

- (instancetype) init;

/**
 Init with object and cost

 @param object - NSObject
 @param cost - Cost of object
 @return - LRUObject
 */
- (instancetype) initWithObject:(id)object
                           cost:(NSUInteger)cost;

@end
