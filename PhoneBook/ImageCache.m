//
//  ImageCache.m
//  PhoneBook
//
//  Created by chuonghm on 8/2/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ImageCache.h"
#import "NSDate+Extension.h"

/**
 Calculate image cost

 @param image - image to calculate
 @return estimated cost of image
 */
FOUNDATION_STATIC_INLINE NSUInteger icImageCost(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}

@interface ImageCache()

@property (strong, nonatomic) NSFileManager *icFileManager;
@property (strong, nonatomic) NSCache *icMemCache;
@property (strong, nonatomic) dispatch_queue_t icIOQueue;
@property (strong, nonatomic) NSString *icDirPath;

@end

@implementation ImageCache

#pragma mark - Contructors

- (instancetype)init {
    
    self = [super init];
    _icMemCache = [[NSCache alloc]init];
    [_icMemCache setTotalCostLimit:TOTAL_COST_LIMIT];
    _icIOQueue = dispatch_queue_create("com.vn.zalo.ImageCache", DISPATCH_QUEUE_SERIAL);
    
    // I/O
    dispatch_async(_icIOQueue, ^{
        // File manager
        _icFileManager = [NSFileManager defaultManager];
        
        // Create directory path
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [dirPaths objectAtIndex:0];
        _icDirPath = [docsPath stringByAppendingString:@"/com.vn.zalo.ImageCache"];
        
        // Create directory if not exist
        if (![_icFileManager fileExistsAtPath:_icDirPath]) {
            
            [_icFileManager createDirectoryAtPath:_icDirPath
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:nil];
        }
    });
    
    // clear memory cache if mem warning
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    // Delete old files when app terminated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteOldFiles)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    return self;
}

#pragma mark - Destructors

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Static methods

+ (id)sharedInstance {
    
    static ImageCache *sharedImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageCache = [[self alloc] init];
    });
    return sharedImageCache;
}

#pragma mark - Public methods

- (void)storeImage:(UIImage *)image withKey:(NSString *)key {
    
    [self storeImage2Disk:image withKey:key];
}

- (UIImage *)imageFromKey:(NSString *)key {
    
    UIImage *image = [self imageFromMemCacheWithKey:key];
    if (image) {
        return image;
    }
    return [self imageFromDiskWithKey:key];
}

- (void)removeImageForKey:(NSString *)key {
    
    [self removeImageInMemWithKey:key];
    [self removeImageOnDiskWithKey:key];
}

- (void)removeAllCache {
    
    [self removeAllCacheOnMem];
    [self removeAllCacheOnDisk];
}

#pragma mark - Private methods

/**
 Remove all image in memory cache
 */
- (void)removeAllCacheOnMem {
    
    [_icMemCache removeAllObjects];
}

/**
 Remove all image on disk
 */
- (void)removeAllCacheOnDisk {
    
    dispatch_async(_icIOQueue, ^{
        NSError *error;
        
        // Get all files in directory
        NSArray *files = [_icFileManager contentsOfDirectoryAtPath:_icDirPath
                                                             error:&error];
#if DEBUG
        NSAssert(error, error.debugDescription);
#endif
        
        for (NSString *file in files) {
            // Delete file
            BOOL success = [_icFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", _icDirPath, file] error:&error];
#if DEBUG
            NSAssert(!success || error, error.debugDescription);
#endif
            
        }
    });
}

/**
 Store image to disk

 @param image - image to store
 @param key - key of image
 */
- (void)storeImage2Disk:(UIImage *)image
                withKey:(NSString *)key {
    
    NSString *filePath = [self getFilePathFromKey:key];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // Write to file
    dispatch_async(_icIOQueue, ^{
        [imageData writeToFile:filePath
                    atomically:YES];
    });
}

/**
 Store image to memory cache

 @param image - image to store
 @param key - key of image
 */
- (void)storeImage2Mem:(UIImage *)image
               withKey:(NSString *)key {
    
    [_icMemCache setObject:image
                    forKey:key
                      cost:icImageCost(image)];
}

/**
 Load image from disk

 @param key - key of image to load
 @return image from disk
 */
- (UIImage *)imageFromDiskWithKey:(NSString *)key {
    
    NSString *filePath = [self getFilePathFromKey:key];
    
    // Read image data from disk
    NSData __block *imageData;
    dispatch_sync(_icIOQueue, ^{
        imageData = [NSData dataWithContentsOfFile:filePath];
    });
    
    // If has image fixed key, store image to mem cache
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        [self storeImage2Mem:image
                     withKey:key];
    }
    
    return image;
}

/**
 Load image from memory cache with key

 @param key - key of image to load
 @return image in memory cache
 */
- (UIImage *)imageFromMemCacheWithKey:(NSString *)key {
    
    return [_icMemCache objectForKey:key];
}

/**
 Get absolute file path from key on disk

 @param key - key to get
 @return absolute file path
 */
- (NSString *)getFilePathFromKey:(NSString *)key {
    
    NSString __block *databasePath;
    
    // Need to wait until directory is created
    dispatch_sync(_icIOQueue, ^{
        databasePath = [[NSString alloc] initWithString: [_icDirPath stringByAppendingPathComponent:key]];
    });
    
    return databasePath;
}

/**
 Remove image in memory cache

 @param key - key object to remove
 */
- (void)removeImageInMemWithKey:(NSString *)key {
    
    [_icMemCache removeObjectForKey:key];
}

/**
 Remove image on disk

 @param key - key of object to remove
 */
- (void)removeImageOnDiskWithKey:(NSString *)key {
    
    dispatch_async(_icIOQueue, ^{
        NSError *error;
        [_icFileManager removeItemAtPath:[self getFilePathFromKey:key] error:&error];
        
#if DEBUG
        NSAssert(error, error.debugDescription);
#endif
        
    });
}

/**
 Clear all memory cache
 */
- (void)clearMemory {
    
    [_icMemCache removeAllObjects];
}

/**
 Delete old files on disk
 */
- (void)deleteOldFiles {
    
    dispatch_async(_icIOQueue, ^{
        NSError *error;
        
        // Get all files on disk
        NSArray *files = [_icFileManager contentsOfDirectoryAtPath:_icDirPath error:&error];
#if DEBUG
        NSAssert(error, error.debugDescription);
#endif
        
        for (NSString *file in files) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", _icDirPath, file];
            
            // Get modifidation date
            NSDictionary *attributes = [_icFileManager attributesOfItemAtPath:path error:nil];
            NSDate *lastModifiedDate = [attributes fileModificationDate];
            
            // Skip if last modified date is in threshold
            NSDate *today = [NSDate date];
            if ([NSDate daysBetweenDate:lastModifiedDate andDate:today] <= EXPIRATION_DAYS) {
                continue;
            }
            
            // Delete file
            BOOL success = [_icFileManager removeItemAtPath:path error:&error];
            
#if DEBUG
            NSAssert(!success || error, error.debugDescription);
#endif
            
        }
    });
}

@end
