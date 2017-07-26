//
//  CheckBox.m
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if ( self.checked )
        [self drawRectChecked:rect];
    else
    {
        if ( self.checkMarkStyle == SSCheckMarkStyleOpenCircle )
            [self drawRectOpenCircle:rect];
        else if ( self.checkMarkStyle == SSCheckMarkStyleGrayedOut )
            [self drawRectGrayedOut:rect];
    }
    
}

- (void)setChecked:(bool)checked
{
    _checked = checked;
    [self setNeedsDisplay];
}

- (void)setCheckMarkStyle:(SSCheckMarkStyle)checkMarkStyle
{
    _checkMarkStyle = checkMarkStyle;
    [self setNeedsDisplay];
}

- (void) drawRectChecked: (CGRect) rect
{
    [self setBackgroundColor:[UIColor colorWithRed: 73.0/255 green: 149.0/255 blue: 249.0/255 alpha: 1]];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    self.layer.borderWidth = 0;
    
    //// Frames
    CGRect frame = self.bounds;
    
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6);
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    [[UIColor whiteColor] setStroke];
    bezierPath.lineWidth = 1.3;
    [bezierPath stroke];
}

- (void) drawRectGrayedOut: (CGRect) rect {
    self.layer.cornerRadius = self.frame.size.width/2;
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.clipsToBounds = YES;
    
    [self setBackgroundColor:[UIColor lightGrayColor]];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    //// Frames
    CGRect frame = self.bounds;
    
    //// Subframes
    CGRect group = CGRectMake(CGRectGetMinX(frame) + 3, CGRectGetMinY(frame) + 3, CGRectGetWidth(frame) - 6, CGRectGetHeight(frame) - 6);
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
    bezierPath.lineCapStyle = kCGLineCapSquare;
    
    [[UIColor whiteColor] setStroke];
    bezierPath.lineWidth = 1.3;
    [bezierPath stroke];
}

- (void) drawRectOpenCircle: (CGRect) rect {
    self.layer.cornerRadius = self.frame.size.width/2;
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.clipsToBounds = YES;
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end
