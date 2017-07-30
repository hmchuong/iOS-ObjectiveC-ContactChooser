//
//  CheckBox.h
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UNCHECKED_COLOR [UIColor lightGrayColor]
#define CHECKED_COLOR [UIColor colorWithRed: 73.0/255 green: 149.0/255 blue: 249.0/255 alpha: 1]
#define CHECK_MARK_WIDTH 1.3

/**
 Checkbox style

 - CheckMarkStyleOpenCircle: empty circle in unchecked state
 - CheckMarkStyleGrayedOut: grayout check mark in unchecked state
 */
typedef NS_ENUM( NSUInteger, CheckMarkStyle) {
    CheckMarkStyleOpenCircle,
    CheckMarkStyleGrayedOut
};

@interface CheckBox : UIView

@property (readwrite, nonatomic) bool checked;
@property (readwrite, nonatomic) CheckMarkStyle checkMarkStyle;

@end
