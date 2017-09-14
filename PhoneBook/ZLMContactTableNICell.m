//
//  ContactRowNICell.m
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ZLMContactTableNICell.h"
#import "ZLMContactNIO.h"

@interface ZLMContactTableNICell()

@property BOOL isDraw;

@end

@implementation ZLMContactTableNICell

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
    
    
    
    // Avatar
    _avatar = [[UIImageView alloc] init];
    _avatar.contentMode = UIViewContentModeScaleToFill;
    _avatar.translatesAutoresizingMaskIntoConstraints = NO;
    _avatar.layer.cornerRadius = AVATAR_SIZE/2;
    _avatar.clipsToBounds = YES;
    [self.contentView addSubview:_avatar];
    
    
    
    // Checkbox
    _checkBox = [[ZLMCheckBox alloc] init];
    _checkBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_checkBox];
    
    
    
    // Name label
    _name = [[UILabel alloc] init];
    _name.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_name];
    
    
    
    // ----- CONSTRAINTS -----
    // 1. Horizontal layout
    NSString *vfHorizontalContraint = [NSString stringWithFormat:@"H:|-%f-[checkBox(%f)]-%f-[avatar(%f)]-%f-[name]",CONTENTVIEW_CHECKBOX,CHECKBOX_SIZE,CHECKBOX_AVATAR,AVATAR_SIZE,AVATAR_NAME];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfHorizontalContraint
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"avatar":_avatar,
                                                                                       @"checkBox":_checkBox,
                                                                                       @"name":_name}]];
    
    
    
    // 2. Checkbox
    //      a. Height
    [_checkBox addConstraint:[NSLayoutConstraint constraintWithItem:_checkBox
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:CHECKBOX_SIZE]];
    
    //      b. Center vertical alignment
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkBox
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    
    
    // 3. Avatar
    //      a. Height
    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:AVATAR_SIZE]];
    
    //      b. Center vertical alignment
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_avatar
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    
    
    
    // 4. Name
    //      a. Center vertical alignment
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_name
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
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

- (BOOL)shouldUpdateCellWithObject:(ZLMContactNIO *)object {
    
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
