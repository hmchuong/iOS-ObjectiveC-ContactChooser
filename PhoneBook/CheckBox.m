//
//  CheckBox.m
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox

#pragma mark - Life cycle

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // In checked state
    if ( self.checked ) {
        [self drawRectChecked:rect];
    } else {    // In unchecked state
        if ( self.checkMarkStyle == CheckMarkStyleOpenCircle )
            [self drawRectOpenCircle:rect];
        else if ( self.checkMarkStyle == CheckMarkStyleGrayedOut )
            [self drawRectGrayedOut:rect];
    }
    
}

#pragma mark - setters

- (void)setChecked:(bool)checked {
    _checked = checked;
    [self setNeedsDisplay];
}

- (void)setCheckMarkStyle:(CheckMarkStyle)checkMarkStyle {
    _checkMarkStyle = checkMarkStyle;
    [self setNeedsDisplay];
}

#pragma mark - utilities

/**
 Draw checked state

 @param rect - rect to draw
 */
- (void)drawRectChecked:(CGRect)rect {
    // Set background of check box to checked color
    [self setBackgroundColor: CHECKED_COLOR];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    // Hide border of check box
    self.layer.borderWidth = 0;
    
    // Frame of checkbox
    CGRect frame = self.bounds;
    
    // Make frame of check mark
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6);
    
    
    // Bezier Drawing check mark
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    // Set color of check mark
    [[UIColor whiteColor] setStroke];
    bezierPath.lineWidth = CHECK_MARK_WIDTH;
    [bezierPath stroke];
}

/**
 Draw unchecked state in CheckMarkStyleGrayedOut

 @param rect - rect to draw
 */
- (void)drawRectGrayedOut:(CGRect)rect {
    // Set border and corner radius of check box
    self.layer.cornerRadius = self.frame.size.width/2;
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:UNCHECKED_COLOR.CGColor];
    self.clipsToBounds = YES;
    
    // Set background of check box
    [self setBackgroundColor:UNCHECKED_COLOR];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    // Frame of checkbox
    CGRect frame = self.bounds;
    
    // Make frame of check mark
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6);
    
    
    // Bezier Drawing check mark
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    // Set color of check mark
    [[UIColor whiteColor] setStroke];
    bezierPath.lineWidth = CHECK_MARK_WIDTH;
    [bezierPath stroke];
}

/**
 Draw unchecked state in CheckMarkStyleOpenCircle

 @param rect - rect to draw
 */
- (void)drawRectOpenCircle:(CGRect)rect {
    // Set border and corner radius of check box
    self.layer.cornerRadius = self.frame.size.width/2;
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:UNCHECKED_COLOR.CGColor];
    self.clipsToBounds = YES;
    
    // Set background of check box
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end
