//
//  ContactModel.h
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NICellCatalog.h"
#import "NimbusCollections.h"

#define HIGHLIGHT_COLOR [UIColor colorWithRed:230.0/255 \
                                        green:230.0/255 \
                                         blue:230.0/255 \
                                        alpha:1]
#define ALPHA_OF_HIGHLIGHTED_COLLECTION_CELL 0.5

@class ContactModelObject;

@protocol ContactModelObjectDelegate <NSObject>

@required
- (UIImage *)getAvatarImage;
- (NSString *)getFullname;

@end

@interface ContactModelObject : NSObject<NINibCellObject,NICollectionViewNibCellObject>

@property BOOL isHighlighted;
@property float alphaOfHighlightedCollectionCell;
@property UIColor *highlightedTableCellBackgroundColor;

@end
