//
//  ContactRowNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactTableNINibCell.h"
#import "ContactModelObject.h"

@interface ContactTableNINibCell()

@property BOOL isDraw;

@end

@implementation ContactTableNINibCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _avatar = [[UIImageView alloc] init];
    _avatar.contentMode = UIViewContentModeScaleToFill;
    
    [_avatar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    _checkBox = [[CheckBox alloc] init];
    [_checkBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    _name = [[UILabel alloc] init];
    [_name setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:_avatar];
    [self.contentView addSubview:_checkBox];
    [self.contentView addSubview:_name];
    [self setUpView];
    
    return self;
}

- (void)setUpView {
    
    
    // Horizontal layout
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[checkBox(25)]-20-[avatar(50)]-10-[name]" options:0 metrics:nil views:@{@"avatar":_avatar,@"checkBox":_checkBox,@"name":_name}]];
    
    // Checkbox
    
    [_checkBox addConstraint:[NSLayoutConstraint constraintWithItem:_checkBox
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:25]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkBox
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    // Avatar
    
    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:50]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    // Name
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_name
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _avatar.clipsToBounds = YES;
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
    
    [self setNeedsDisplay];
    
    return YES;
}

@end
