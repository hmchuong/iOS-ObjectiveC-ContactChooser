//
//  LRUObject.m
//  PhoneBook
//
//  Created by chuonghm on 8/14/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "LRUObject.h"

@implementation LRUObject

- (instancetype)init {
    
    self = [super init];
    
    _object = [[NSObject alloc] init];
    _cost = 0;
    
    return self;
}

- (instancetype)initWithObject:(id)object
                          cost:(NSUInteger)cost {
    
    self = [super init];
    
    _object = object;
    _cost = cost;
    
    return self;
}

@end
