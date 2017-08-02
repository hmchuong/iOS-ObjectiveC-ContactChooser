//
//  ContactCollectionNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactCollectionNINibCell.h"

@implementation ContactCollectionNINibCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (BOOL)shouldUpdateCellWithObject:(Contact *)object {
    [_avatar setImage:[object avatar]];
    [_avatar.layer setCornerRadius:self.frame.size.width/2];
    _avatar.clipsToBounds = YES;
    return YES;
}

@end
