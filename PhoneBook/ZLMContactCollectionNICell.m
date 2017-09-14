//
//  ZLMContactCollectionNICell.m
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ZLMContactNIO.h"
#import "ZLMContactCollectionNICell.h"


@implementation ZLMContactCollectionNICell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self setUpView];
    
    return self;
}

/**
 Setup UI
 */
- (void)setUpView {
    
    // Set up avatar
    _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatar.contentMode = UIViewContentModeScaleToFill;
    _avatar.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar.layer.cornerRadius = AVATAR_SMALL_SIZE/2;
    _avatar.clipsToBounds = YES;
    [self.contentView addSubview:_avatar];
    
    // Horizontal constraints
    NSString *vfHorizontalConstraint = [NSString stringWithFormat:@"H:|[avatar(%f)]",AVATAR_SMALL_SIZE];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfHorizontalConstraint options:0 metrics:nil views:@{@"avatar":_avatar}]];
    
    // Avatar height constraint
    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:AVATAR_SMALL_SIZE]];
    
    // Avatar center verical constraint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1
                                                         constant:0]];
    
    [self setNeedsUpdateConstraints];
}

- (BOOL)shouldUpdateCellWithObject:(ZLMContactNIO *)object {
    
    // Update image of cell
    [_avatar setImage:[object getAvatarImage]];
    
    // Update UI fixes state of cell
    if ([object isHighlighted]) {
        self.alpha = [object alphaOfHighlightedCollectionCell];
    } else {
        self.alpha = 1;
    }
    return YES;
}

@end
