//
//  SearchBarView.m
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "SearchBarView.h"

@implementation SearchBarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if (![subview isUserInteractionEnabled]){
            continue;
        }
        
        CGPoint newPoint = [subview convertPoint:point fromView:self];
        if (CGRectContainsPoint([subview bounds], newPoint)) {
            return [subview hitTest:newPoint withEvent:event];
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
