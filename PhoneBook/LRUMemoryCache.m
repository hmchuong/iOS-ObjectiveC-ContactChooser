//
//  LRUMemoryCache.m
//  PhoneBook
//
//  Created by chuonghm on 8/14/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "LRUMemoryCache.h"
#import "ThreadSafeMutableArray.h"
#import "ThreadSafeMutableDictionary.h"
#import "LRUObject.h"

@interface LRUMemoryCache()

/**
 Dictionary to store objects
 */
@property (strong, nonatomic) ThreadSafeMutableDictionary *storedObjects;

/**
 Array stores keys in less-recently-used order
 */
@property (strong, nonatomic) ThreadSafeMutableArray *lruObjectKeys;

@property NSUInteger currentTotalCost;               // Total cost of all stored object
@property NSUInteger totalCostThreshold;             // Threshold of total cost

@end

@implementation LRUMemoryCache

#pragma mark - Constructors

- (instancetype)init {
    
    self = [super init];
    
    _storedObjects = [[ThreadSafeMutableDictionary alloc] init];
    _lruObjectKeys = [[ThreadSafeMutableArray alloc] init];
    
    _totalCostThreshold = NSUIntegerMax;
    _currentTotalCost = 0;
    
    return self;
}

- (instancetype)initWithTotalCostLimit:(NSUInteger)totalCost {
    
    self = [self init];
    
    [self setTotalCostLimit:totalCost];
    
    return self;
}

#pragma mark - Set total cost limit

- (void)setTotalCostLimit:(NSUInteger)totalCost {
    
    _totalCostThreshold = totalCost;
    
    // Free memory cache if necessary
    while (_currentTotalCost > _totalCostThreshold) {
        [self removeLRUObject];
    }
}

#pragma mark - Get object

- (id)objectForKey:(NSString *)key {
    
    LRUObject *lruObject = _storedObjects[key];
    
    if (lruObject != nil) {
        [self useObjectWithKey:key];
    }
    
    return lruObject.object;
}

#pragma mark - Set object

- (void)setObject:(id)object
           forKey:(NSString *)key
             cost:(NSUInteger)cost {
    
    // if key exist --> Get old cost and calculate changed cost
    LRUObject *lruObject = _storedObjects[key];
    
    NSUInteger oldCost = 0;
    if (lruObject != nil) {
        oldCost = lruObject.cost;
    }
    
    NSUInteger changedCost = cost - oldCost;
    
    // Change current total cost
    [self changeTotalCurrentCost:changedCost];
    
    // Store object
    _storedObjects[key] = [[LRUObject alloc] initWithObject:object
                                                       cost:cost];
    
    // Notify just use object
    [self useObjectWithKey:key];
}

#pragma mark - Remove object

- (void)removeObjectForKey:(NSString *)key {
    
    LRUObject *lruObject = _storedObjects[key];
    
    if (lruObject == nil) {
        return;
    }
    
    _currentTotalCost -= lruObject.cost;
    
    [_storedObjects removeObjectForkey:key];
    [_lruObjectKeys removeObject:key];
    
}

- (void)removeAllObjects {
    
    _currentTotalCost = 0;
    [_storedObjects removeAllObjects];
    [_lruObjectKeys removeAllObjects];
}

#pragma mark - LRU algorithm

/**
 Remove one least-recently-used object
 */
- (void)removeLRUObject {
    
    // Get last key in LRU array
    NSString *lruObjectKey = [_lruObjectKeys pop];
    
    if (lruObjectKey == nil) {
        return;
    }
    
    // Remove object with last key
    [self removeObjectForKey:lruObjectKey];
}

/**
 Notify using/creating object to adjust keys array order

 @param key - key representing object
 */
- (void)useObjectWithKey:(NSString *)key {
    
    // Find key in array
    NSInteger indexOfKey = [_lruObjectKeys indexOfObject:key];
    
    // Insert to head of array
    [_lruObjectKeys insertObject:key atIndex:0];
    
    // Done if key is not existed
    if (indexOfKey == NSNotFound) {
        return;
    }
    
    // Remove old key
    [_lruObjectKeys removeObjectAtIndex:indexOfKey];
}

/**
 Change current total cost and remove objects if out of limit

 @param changedCost - changed cost
 */
- (void)changeTotalCurrentCost:(NSInteger)changedCost {
    
    _currentTotalCost += changedCost;
    
    while (_currentTotalCost > _totalCostThreshold) {
        [self removeLRUObject];
    }
}

@end
