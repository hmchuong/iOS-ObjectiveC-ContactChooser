//
//  Contact.m
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "Contact.h"

/**
 Macro for get UIColor from hex value

 @param hexValue - hex value
 @return - UIColor representing rgbValue
 */
#define UIColorFromHex(hexValue) \
    [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
                    green:((float)((hexValue & 0x00FF00) >>  8))/255.0 \
                     blue:((float)((hexValue & 0x0000FF) >>  0))/255.0 \
                    alpha:1.0]

@implementation Contact

#pragma mark - getters

/**
 Getter of avatar

 @return - avatar UIImage
 */
- (UIImage*)avatar {
    
    if (_avatar == nil) {
        // Make avatar from represented name's characters
        // Split fullname to tokens
        NSArray *tokensOfFullname = [self.fullname componentsSeparatedByString:@" "];
        
        NSString *representName;
        
        if ([tokensOfFullname count] > 1) {   // fullname has more than 1 word.
            // Get first characters of first and last word.
            NSString *firstToken = [tokensOfFullname objectAtIndex:0];
            NSString *lastToken = [tokensOfFullname objectAtIndex:[tokensOfFullname count]-1];
            
            // Link the two characters.
            representName = [[NSString alloc] initWithFormat:@"%c%c",[firstToken characterAtIndex:0],[lastToken characterAtIndex:0]];
        } else {
            // Get only the first character of the only word for representing name.
            NSString *firstToken = [tokensOfFullname objectAtIndex:0];
            representName = [[NSString alloc] initWithFormat:@"%c",[firstToken characterAtIndex:0]];
        }
        
        // Make UIImage from representing name
        _avatar = [self imageFromText:representName];
    }
    
    return _avatar;
}

/**
 Getter of fullname

 @return - fullname: lastname + middlename + firstname
 */
- (NSString*)fullname {
    NSMutableString *showingName = [[NSMutableString alloc] init];
    
    if (_lastname != nil && [_lastname length] > 0) {
        [showingName appendString:_lastname];
    }
    if (_middlename != nil && [_middlename length] > 0) {
        [showingName appendFormat:@" %@",_middlename];
    }
    if (_firstname != nil && [_firstname length] > 0) {
        [showingName appendFormat:@" %@",_firstname];
    }
    
    // Trim space and endline at beginning and ending of name
    NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
    return [showingName stringByTrimmingCharactersInSet:charsToTrim];
}

#pragma mark - utilities

/**
 Make image from text

 @param text - text to draw image
 @return - UIImage with text inside
 */
-(UIImage *)imageFromText:(NSString *)text {
    // Create label contains text
    UILabel *lblNameInitialize = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    lblNameInitialize.textColor = [UIColor whiteColor];
    [lblNameInitialize setFont:[UIFont fontWithName:@"Helvetica" size:40]];
    lblNameInitialize.text = text;
    lblNameInitialize.textAlignment = NSTextAlignmentCenter;
    lblNameInitialize.backgroundColor = UIColorFromHex(0x49BA96);
    
    // Render label to image
    UIGraphicsBeginImageContext(lblNameInitialize.frame.size);
    [lblNameInitialize.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

@end
