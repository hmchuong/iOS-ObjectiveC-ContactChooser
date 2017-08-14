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

/**
 Nimbus table cell for contact picker
 */
@interface ContactTableNINibCell : UITableViewCell<NICell>

@property (strong, nonatomic) CheckBox *checkBox;        // Check box view
@property (strong, nonatomic) UIImageView *avatar;       // Avatar of contact
@property (strong, nonatomic) UILabel *name;             // Name of contact

@end
