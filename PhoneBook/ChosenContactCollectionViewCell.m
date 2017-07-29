//
//  ChosenContactCollectionViewCell.m
//  PhoneBook
//
//  Created by Huỳnh Minh Chương on 7/27/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ChosenContactCollectionViewCell.h"

@implementation ChosenContactCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Make circle avatar
    [_avatar.layer setCornerRadius:self.frame.size.width/2];
    _avatar.clipsToBounds = YES;
}

@end
