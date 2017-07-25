//
//  CheckBox.m
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "CheckBox.h"

@interface CheckBox()

@property (nonatomic) bool isChecked;

@end

@implementation CheckBox

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    // Setup border
    [[self layer] setBorderWidth:1];
    [[self layer] setBorderColor: [[UIColor grayColor] CGColor]];
    [[self layer] setCornerRadius:[self frame].size.height/2];
}

- (void)changeState {
    if (_isChecked) {
        [self setBackgroundColor:[UIColor clearColor]];
        _isChecked = NO;
    } else {
        [self setBackgroundColor:[UIColor blueColor]];
        _isChecked = YES;
    }
}

@end
