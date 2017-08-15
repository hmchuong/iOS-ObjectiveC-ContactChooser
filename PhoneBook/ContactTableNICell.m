//
//  ContactRowNICell.m
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactTableNICell.h"
#import "ContactModelObject.h"

@interface ContactTableNICell()

@property BOOL isDraw;

@end

@implementation ContactTableNICell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self setUpView];
    
    return self;
}

/**
 Setup UI of view
 */
- (void)setUpView {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Separator insets
    UIEdgeInsets separatorInsets = self.separatorInset;
    separatorInsets.left = LEFT_INSET;
    self.separatorInset = separatorInsets;
    
    // Add avatar
    _avatar = [[UIImageView alloc] init];
    _avatar.contentMode = UIViewContentModeScaleToFill;
    [_avatar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_avatar.layer setCornerRadius:AVATAR_SIZE/2];
    _avatar.clipsToBounds = YES;
    [self.contentView addSubview:_avatar];
    
    // Add checkbox
    _checkBox = [[CheckBox alloc] init];
    [_checkBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:_checkBox];
    
    // Add name
    _name = [[UILabel alloc] init];
    [_name setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:_name];
    
    // ----- Setup constraints -----
    // Horizontal layout
    NSString *vfHorizontalContraint = [NSString stringWithFormat:@"H:|-%f-[checkBox(%f)]-%f-[avatar(%f)]-%f-[name]",CONTENTVIEW_CHECKBOX,CHECKBOX_SIZE,CHECKBOX_AVATAR,AVATAR_SIZE,AVATAR_NAME];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfHorizontalContraint options:0 metrics:nil views:@{@"avatar":_avatar,@"checkBox":_checkBox,@"name":_name}]];
    
    // Checkbox
    // Height
    [_checkBox addConstraint:[NSLayoutConstraint constraintWithItem:_checkBox
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:CHECKBOX_SIZE]];
    
    // Center vertical alignment
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkBox
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    // Avatar
    // Height
    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:AVATAR_SIZE]];
    
    // Center vertical alignment
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    
    // Name
    // Center vertical alignment
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_name
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    [self setNeedsUpdateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Update checkbox view
    [_checkBox setChecked:selected];
}

- (BOOL)shouldUpdateCellWithObject:(ContactModelObject *)object {
    
    // Set avatar
    [_avatar setImage:[object getAvatarImage]];
    
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
