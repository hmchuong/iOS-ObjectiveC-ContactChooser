//
//  ThreadSafeMutableDictionary.h
//  PhoneBook
//
//  Created by chuonghm on 8/2/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadSafeMutableDictionary : NSObject

- (instancetype)init;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObject;

- (instancetype)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey: (NSString *)key;

@end
