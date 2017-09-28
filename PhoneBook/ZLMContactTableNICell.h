//
//  ZLMContactTableNICell.h
//  PhoneBook
//
//  Created by chuonghm on 7/31/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NICellFactory.h"
#import "ZLMCheckBox.h"

/**
 * UI constants
 */
#define LEFT_INSET 115.0                // Left inset of separator
#define CHECKBOX_SIZE 25.0              // Size (W,H) of checkbox
#define AVATAR_SIZE 50.0                // Size (W,H) of avatar
#define CONTENTVIEW_CHECKBOX 10.0       // Space between content view - check box
#define CHECKBOX_AVATAR 20.0            // Space between check box - avatar
#define AVATAR_NAME 10.0                // Space between avatar - name

/**
 Nimbus table cell for contact picker
 */
@interface ZLMContactTableNICell : UITableViewCell<NICell>

@property (strong, nonatomic) ZLMCheckBox *checkBox;        // Check box view
@property (strong, nonatomic) UIImageView *avatar;       // Avatar of contact
@property (strong, nonatomic) UILabel *name;             // Name of contact

@end
