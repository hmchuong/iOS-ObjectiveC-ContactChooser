//
//  ZLMCheckBox.h
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UNCHECKED_COLOR [UIColor lightGrayColor]
#define CHECKED_COLOR [UIColor colorWithRed: 73.0/255 green: 149.0/255 blue: 249.0/255 alpha: 1]
#define CHECK_MARK_WIDTH 1.3

#define CHECKED_VIEW_KEY @"check_box_checked"
#define OPEN_CIRCLE_VIEW_KEY @"check_box_open_circle"
#define GRAYED_OUT_VIEW_KEY @"check_box_grayed_out"

/**
 Checkbox style

 - ZLMCheckMarkStyleOpenCircle: empty circle in unchecked state
 - ZLMCheckMarkStyleGrayedOut: grayout check mark in unchecked state
 */
typedef NS_ENUM( NSUInteger, ZLMCheckMarkStyle) {
    ZLMCheckMarkStyleOpenCircle,
    ZLMCheckMarkStyleGrayedOut
};

@interface ZLMCheckBox : UIView

@property (readwrite, nonatomic) bool checked;                      // checked state
@property (readwrite, nonatomic) ZLMCheckMarkStyle checkMarkStyle;     // style of check box

@end
