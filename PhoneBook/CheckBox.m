//
//  CheckBox.m
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "CheckBox.h"
#import "ImageCache.h"
#import "UIImage+Extension.h"

@interface CheckBox()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CheckBox

#pragma mark - Life cycle

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    
    // Remove subviews
    [_imageView removeFromSuperview];
    
    // Set border and corner radius of check box
    self.layer.cornerRadius = self.frame.size.width/2;
    [self.layer setBorderColor:UNCHECKED_COLOR.CGColor];
    self.clipsToBounds = YES;
    
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

#pragma mark - Setters

- (void)setChecked:(bool)checked {
    
    if (_checked != checked) {
        _checked = checked;
        [self setNeedsDisplay];
    }
}

- (void)setCheckMarkStyle:(CheckMarkStyle)checkMarkStyle {
    
    _checkMarkStyle = checkMarkStyle;
    [self setNeedsDisplay];
}

#pragma mark - Utilities

/**
 Draw checked state

 @param rect - rect to draw
 */
- (void)drawRectChecked:(CGRect)rect {
    self.layer.borderWidth = 0;
    UIImage *checkedImage = [ImageCache.sharedInstance imageFromKey:CHECKED_VIEW_KEY];
    if (checkedImage) {
        [_imageView setImage:checkedImage];
        [self addSubview:_imageView];
        return;
    }
    
    // Set background of check box to checked color
    [self setBackgroundColor: CHECKED_COLOR];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    // Hide border of check box
    
    
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
    
    // Store image after draw
    [ImageCache.sharedInstance storeImage:[UIImage imageWithView:self] withKey:CHECKED_VIEW_KEY];
}

/**
 Draw unchecked state in CheckMarkStyleGrayedOut

 @param rect - rect to draw
 */
- (void)drawRectGrayedOut:(CGRect)rect {
    
    UIImage *grayedOutImage = [ImageCache.sharedInstance imageFromKey:GRAYED_OUT_VIEW_KEY];
    if (grayedOutImage) {
        [_imageView setImage:grayedOutImage];
        [self addSubview:_imageView];
        return;
    }
    
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
    
    // Store image after draw
    [ImageCache.sharedInstance storeImage:[UIImage imageWithView:self] withKey:GRAYED_OUT_VIEW_KEY];
}

/**
 Draw unchecked state in CheckMarkStyleOpenCircle

 @param rect - rect to draw
 */
- (void)drawRectOpenCircle:(CGRect)rect {
    [self.layer setBorderWidth:1];
    
    // Set background of check box
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end
