//
//  ContactCollectionNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactCollectionNINibCell.h"
#import "ImageCache.h"
#import "ContactModelObject.h"

@implementation ContactCollectionNINibCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Make rounded avatar
    [_avatar.layer setCornerRadius:self.frame.size.width/2];
    _avatar.clipsToBounds = YES;
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
