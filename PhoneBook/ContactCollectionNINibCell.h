//
//  ContactCollectionNINibCell.h
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCollections.h"

/**
 Nimbus collection cell for contact picker 
 */
@interface ContactCollectionNINibCell : UICollectionViewCell<NICollectionViewCell>

@property (weak, nonatomic) IBOutlet UIImageView *avatar;                   // Avatar of contact

@end
