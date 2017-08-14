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
        //NSLog(@"Length: %d objects",[_internalDictionary count]);
    });
    
    return result;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    dispatch_async(_tsQueue, ^{
        _internalDictionary[key] = obj;
        //NSLog(@"Length: %d objects",[_internalDictionary count]);
    });
}

- (NSDictionary *)toNSDictionary {
    NSDictionary *__block result;
    dispatch_sync(_tsQueue, ^{
        result = _internalDictionary;
    });
    
    return result;
}

- (void)removeObjectForkey:(NSString *)key {
    dispatch_async(_tsQueue, ^{
        [_internalDictionary removeObjectForKey:key];
        //NSLog(@"Length: %d objects",[_internalDictionary count]);
    });
}

- (void)removeAllObjects {
    dispatch_async(_tsQueue, ^{
        [_internalDictionary removeAllObjects];
        //NSLog(@"Length: %d objects",[_internalDictionary count]);
    });
}

@end
