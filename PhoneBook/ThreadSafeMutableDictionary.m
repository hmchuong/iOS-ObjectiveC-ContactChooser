//
//  ThreadSafeMutableDictionary.m
//  PhoneBook
//
//  Created by chuonghm on 8/9/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ThreadSafeMutableDictionary.h"

@interface ThreadSafeMutableDictionary()

@property (strong,nonatomic) NSMutableDictionary *internalDictionary;
@property (strong,nonatomic) dispatch_queue_t tsQueue;

@end

@implementation ThreadSafeMutableDictionary

- (instancetype)init {
    self = [super init];
    
    _internalDictionary = [[NSMutableDictionary alloc]init];
    _tsQueue = dispatch_queue_create("com.vn.vng.zalo.ThreadSafeMutableDictionary", NULL);
    
    return self;
}

- (id)objectForKeyedSubscript:(id)key {
    NSObject *__block result;
    dispatch_sync(_tsQueue, ^{
        result = _internalDictionary[key];
    });
    
    return result;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    dispatch_async(_tsQueue, ^{
        _internalDictionary[key] = obj;
    });
}

- (NSDictionary *)toNSDictionary {
    NSDictionary *__block result;
    dispatch_sync(_tsQueue, ^{
        result = _internalDictionary;
    });
    
    return result;
}

@end
