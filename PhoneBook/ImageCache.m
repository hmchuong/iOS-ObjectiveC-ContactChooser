//
//  ImageCache.m
//  PhoneBook
//
//  Created by chuonghm on 8/2/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache()

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSCache *memCache;

@end

@implementation ImageCache

- (instancetype)init {
    self = [super init];
    _fileManager = [NSFileManager defaultManager];
    _memCache = [[NSCache alloc]init];
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
#ifdef DEBUG
    if ([_fileManager fileExistsAtPath:filePath]) {
        NSLog(@"Key %@ has already existed",key);
    }
#endif
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filePath atomically:YES];
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
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        [_memCache setObject:image forKey:key];
    }
    return image;
}

- (UIImage *)loadFromMemCacheWithKey:(NSString *)key {
    return [_memCache objectForKey:key];
}

- (NSString *)getFilePathFromKey:(NSString *)key {
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:key]];
    return databasePath;
}

- (void)clearMemory {
    [_memCache removeAllObjects];
}

@end
