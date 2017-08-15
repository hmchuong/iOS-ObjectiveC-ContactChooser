//
//  ContactCollectionNICell.h
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCollections.h"

/**
 * UI Constants
 */
#define AVATAR_SMALL_SIZE 40.0

/**
 Nimbus collection cell for contact picker 
 */
@interface ContactCollectionNICell : UICollectionViewCell<NICollectionViewCell>

@property (strong, nonatomic) UIImageView *avatar;                   // Avatar of contact

@end
