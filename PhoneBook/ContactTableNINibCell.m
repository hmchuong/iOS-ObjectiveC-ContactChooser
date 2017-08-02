//
//  ContactRowNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactTableNINibCell.h"
#import "SDImageCache.h"
#import "ImageCache.h"

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

- (BOOL)shouldUpdateCellWithObject:(Contact *)object {
    // Update UI
    [_avatar setImage:[ImageCache.sharedInstance imageFromKey:[object avatarKey]]];
    [_name setText:[object fullname]];
    [_avatar.layer setCornerRadius:_avatar.frame.size.width/2];
    _avatar.clipsToBounds = YES;
    if (object.isHighlighted) {
        self.backgroundColor = HIGHLIGHT_COLOR;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    return YES;
}

@end
