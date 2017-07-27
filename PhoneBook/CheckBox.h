//
//  CheckBox.h
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>

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
