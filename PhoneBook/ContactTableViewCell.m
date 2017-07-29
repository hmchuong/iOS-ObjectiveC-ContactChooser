//
//  ContactTableViewCell.m
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "ContactChooserViewController.h"
#import "CheckBox.h"

@interface ContactTableViewCell()

@property (weak, nonatomic) IBOutlet CheckBox *checkBox;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation ContactTableViewCell

#pragma mark - setters

- (void)setContact:(Contact *)contact {
    _contact = contact;
    
    // Set avatar + fullname
    [_avatar setImage:[contact avatar]];
    [_name setText:[contact fullname]];
}

- (void)drawRect:(CGRect)rect {
    
    // Make circle avatar
    [_avatar.layer setCornerRadius:_avatar.frame.size.width/2];
    _avatar.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Set checked for check box
    [_checkBox setChecked:selected];
}

@end
