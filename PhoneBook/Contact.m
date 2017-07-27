//
//  Contact.m
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "Contact.h"
#define UIColorFromRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                     blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                    alpha:1.0]

@implementation Contact

- (UIImage*)avatar {
    if (_avatar == nil) {
        NSArray *fullnameTokens = [self.fullname componentsSeparatedByString:@" "];
        NSString *representName;
        if ([fullnameTokens count] > 1) {
            NSString *firstToken = [fullnameTokens objectAtIndex:0];
            NSString *lastToken = [fullnameTokens objectAtIndex:[fullnameTokens count]-1];
            representName = [[NSString alloc] initWithFormat:@"%c%c",[firstToken characterAtIndex:0],[lastToken characterAtIndex:0]];
        } else {
            NSString *firstToken = [fullnameTokens objectAtIndex:0];
            representName = [[NSString alloc] initWithFormat:@"%c",[firstToken characterAtIndex:0]];
        }
        return [self imageFromText:representName];
    }
    return _avatar;
}

- (NSString*)fullname {
    NSMutableString *showingName = [[NSMutableString alloc] init];
    if (_lastName != nil && [_lastName length] > 0) {
        [showingName appendString:_lastName];
    }
    if (_middleName != nil && [_middleName length] > 0) {
        [showingName appendFormat:@" %@",_middleName];
    }
    if (_firstName != nil && [_firstName length] > 0) {
        [showingName appendFormat:@" %@",_firstName];
    }
    
    NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
    return [showingName stringByTrimmingCharactersInSet:charsToTrim];
}

-(UIImage *)imageFromText:(NSString *)text {
    UILabel *lblNameInitialize = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    lblNameInitialize.textColor = [UIColor whiteColor];
    [lblNameInitialize setFont:[UIFont fontWithName:@"Helvetica" size:40]];
    lblNameInitialize.text = text;
    lblNameInitialize.textAlignment = NSTextAlignmentCenter;
    lblNameInitialize.backgroundColor = UIColorFromRGB(0x49BA96);
    
    UIGraphicsBeginImageContext(lblNameInitialize.frame.size);
    [lblNameInitialize.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

@end
