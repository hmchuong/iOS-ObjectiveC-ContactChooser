//
//  ImageCache.m
//  PhoneBook
//
//  Created by chuonghm on 8/2/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ImageCache.h"

FOUNDATION_STATIC_INLINE NSUInteger UIImageCost(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}

@interface ImageCache()

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSCache *memCache;
@property (strong, nonatomic) dispatch_queue_t ioQueue;
@property (strong, nonatomic) NSString *dirPath;

@end

@implementation ImageCache

- (instancetype)init {
    self = [super init];
    _memCache = [[NSCache alloc]init];
    [_memCache setTotalCostLimit:500];
    _ioQueue = dispatch_queue_create("com.vn.zalo.ImageCache", DISPATCH_QUEUE_SERIAL);
    
    // I/O
    dispatch_async(_ioQueue, ^{
        // File manager
        _fileManager = [NSFileManager defaultManager];
        
        // Create directory path
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [dirPaths objectAtIndex:0];
        _dirPath = [docsPath stringByAppendingString:@"/com.vn.zalo.ImageCache"];
        
        // Create directory if not exist
        if (![_fileManager fileExistsAtPath:_dirPath]) {
            
            [_fileManager createDirectoryAtPath:_dirPath
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
    return self;
}

+ (id)sharedInstance {
    static ImageCache *sharedImageCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageCache = [[self alloc] init];
    });
    return sharedImageCache;
}

- (void)storeImage:(UIImage *)image withKey:(NSString *)key {
    NSString *filePath = [self getFilePathFromKey:key];
    NSData *imageData = UIImagePNGRepresentation(image);
    dispatch_async(_ioQueue, ^{
        [imageData writeToFile:filePath atomically:YES];
    });
}

- (UIImage *)imageFromKey:(NSString *)key {
    UIImage *image = [self loadFromMemCacheWithKey:key];
    if (image) {
        return image;
    }
    return [self loadFromDiskCacheWithKey:key];
}

- (UIImage *)loadFromDiskCacheWithKey:(NSString *)key {
    NSString *filePath = [self getFilePathFromKey:key];
    
    NSData __block *imageData;
    dispatch_sync(_ioQueue, ^{
        imageData = [NSData dataWithContentsOfFile:filePath];
    });
    
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        [_memCache setObject:imageData forKey:key cost:UIImageCost(image)];
    }
    return image;
}

- (UIImage *)loadFromMemCacheWithKey:(NSString *)key {
    return [_memCache objectForKey:key];
}

- (NSString *)getFilePathFromKey:(NSString *)key {
    NSString __block *databasePath;
    dispatch_sync(_ioQueue, ^{
        databasePath = [[NSString alloc] initWithString: [_dirPath stringByAppendingPathComponent:key]];
    });
    return databasePath;
}

- (void)clearMemory {
    [_memCache removeAllObjects];
}

@end
