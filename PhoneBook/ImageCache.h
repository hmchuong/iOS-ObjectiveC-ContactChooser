//
//  ImageCache.h
//  PhoneBook
//
//  Created by chuonghm on 8/2/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TOTAL_COST_LIMIT 500
#define EXPIRATION_DAYS 30

@interface ImageCache : NSObject

/**
 Singleton instance

 @return ImageCache instance
 */
+ (id)sharedInstance;

/**
 Store image to disk

 @param image - image to store
 @param key - key to store
 */
- (void)storeImage:(UIImage *)image
           withKey:(NSString *)key;

/**
 Get image from cache with key

 @param key - key of image
 @return image stored in cache
 */
- (UIImage *)imageFromKey:(NSString *)key;

/**
 Remove image with key from cache

 @param key - key of image
 */
- (void)removeImageForKey:(NSString *)key;

/**
 Remove all cache
 */
- (void)removeAllCache;

@end
