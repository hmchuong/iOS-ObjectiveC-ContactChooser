//
//  ContactTableNINibCell.h
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NICellFactory.h"
#import "CheckBox.h"

#define HIGHLIGHT_COLOR [UIColor colorWithRed:230.0/255 \
green:230.0/255 \
blue:230.0/255 \
alpha:1]

@interface ContactTableNINibCell : UITableViewCell<NICell>

@property (weak, nonatomic) IBOutlet CheckBox *checkBox;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
