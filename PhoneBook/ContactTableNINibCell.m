//
//  ContactRowNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactTableNINibCell.h"
#import "ImageCache.h"
#import "ContactModelObject.h"

@implementation ContactTableNINibCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [_checkBox setChecked:selected];
}

- (BOOL)shouldUpdateCellWithObject:(ContactModelObject<ContactModelObjectDelegate> *)object {
    // Update UI
    [_avatar setImage:[object getAvatarImage]];
    [_name setText:[object getFullname]];
    [_avatar.layer setCornerRadius:_avatar.frame.size.width/2];
    _avatar.clipsToBounds = YES;
    if ([object isHighlighted]) {
        self.backgroundColor = HIGHLIGHT_COLOR;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    return YES;
}

@end
