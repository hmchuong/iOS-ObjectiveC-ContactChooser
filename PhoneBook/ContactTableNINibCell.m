//
//  ContactRowNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactTableNINibCell.h"
#import "ContactModelObject.h"

@implementation ContactTableNINibCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Update checkbox view
    [_checkBox setChecked:selected];
}

- (BOOL)shouldUpdateCellWithObject:(ContactModelObject *)object {
    
    // Set avatar
    [_avatar setImage:[object getAvatarImage]];
    [_avatar.layer setCornerRadius:_avatar.frame.size.width/2];
    _avatar.clipsToBounds = YES;
    
    // Set text
    [_name setText:[object fullname]];
    
    // Update background
    if ([object isHighlighted]) {
        self.backgroundColor = [object highlightedTableCellBackgroundColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return YES;
}

@end
