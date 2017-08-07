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
    // Initialization code
    [_avatar.layer setCornerRadius:self.frame.size.width/2];
    _avatar.clipsToBounds = YES;
}

- (BOOL)shouldUpdateCellWithObject:(ContactModelObject<ContactModelObjectDelegate> *)object {
    [_avatar setImage:[object getAvatarImage]];
    
    if ([object isHighlighted]) {
        self.alpha = ALPHA_OF_HIGHLIGH_COLLECTION_CELL;
    } else {
        self.alpha = 1;
    }
    return YES;
}

@end
