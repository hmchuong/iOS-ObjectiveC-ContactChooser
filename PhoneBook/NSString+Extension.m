//
//  NSString+Extension.m
//  PhoneBook
//
//  Created by chuonghm on 8/10/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString(Unicode)

- (NSString *)toANSCI {
    return [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
}

@end
