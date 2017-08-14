//
//  ContactCollectionNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactModelObject.h"
#import "ContactCollectionNINibCell.h"


@implementation ContactCollectionNINibCell

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    CGRect frame = self.frame;
//    frame.size.height = 55;
//    frame.size.width = 40;
//    
//    self.frame = frame;
//    
//    _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
//    [_avatar.layer setCornerRadius:self.frame.size.width/2];
//    _avatar.clipsToBounds = YES;
//    
//    [self addSubview:_avatar];
//    
//    // Add leading and trailing
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[avatar]|" options:0 metrics:nil views:@{@"avatar":_avatar}]];
//    
//    // Add height constraint
//    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
//                                                        attribute:NSLayoutAttributeHeight
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:nil
//                                                        attribute:NSLayoutAttributeNotAnAttribute
//                                                       multiplier:1
//                                                         constant:40]];
//    
//    // Add center verical constraint
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
//                                                        attribute:NSLayoutAttributeCenterY
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self
//                                                        attribute:NSLayoutAttributeCenterY
//                                                       multiplier:1
//                                                         constant:0]];
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Make rounded avatar
    
}

- (BOOL)shouldUpdateCellWithObject:(ContactModelObject *)object {
    
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
