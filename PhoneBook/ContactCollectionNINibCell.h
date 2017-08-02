//
//  ContactCollectionNINibCell.h
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCollections.h"
#import "Contact.h"

#define ALPHA_OF_HIGHLIGH_COLLECTION_CELL 0.5

@interface ContactCollectionNINibCell : UICollectionViewCell<NICollectionViewCell>

@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@end
