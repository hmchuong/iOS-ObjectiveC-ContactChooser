//
//  ZLMContactNIO.h
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Nimbus
#import "NICellCatalog.h"
#import "NimbusCollections.h"

#define HIGHLIGHT_COLOR [UIColor colorWithRed:230.0/255 \
                                        green:230.0/255 \
                                         blue:230.0/255 \
                                        alpha:1]
#define ALPHA_OF_HIGHLIGHTED_COLLECTION_CELL 0.5

/**
 Contact object for table and collection cell
 */
@interface ZLMContactNIO : NSObject<NICellObject,NICollectionViewCellObject>

@property (strong,nonatomic) NSString *fullname;                    // Name to show on the table cell

@property BOOL isHighlighted;                                       // Highlight state
@property float alphaOfHighlightedCollectionCell;                   // Alpha of collection cell in highlight state
@property UIColor *highlightedTableCellBackgroundColor;             // Background color of table cell in highlight state

/**
 Get avatar of contact

 @return - avatar image
 */
- (UIImage *)getAvatarImage;

@end
