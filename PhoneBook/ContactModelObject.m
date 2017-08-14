//
//  ContactModelObject.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactModelObject.h"
#import "ContactCollectionNINibCell.h"
#import "ContactTableNINibCell.h"


@implementation ContactModelObject

#pragma mark - Constructors

- (instancetype)init {
    
    self = [super init];
    
    _alphaOfHighlightedCollectionCell = ALPHA_OF_HIGHLIGHTED_COLLECTION_CELL;
    _highlightedTableCellBackgroundColor = HIGHLIGHT_COLOR;
    _fullname = @"";
    
    return self;
}

#pragma mark - Methods

- (UIImage *)getAvatarImage {
    
    return [[UIImage alloc]init];
}

//#pragma mark - NINibCellObject
//
//- (UINib *)cellNib {
//    
//    return [UINib nibWithNibName:NSStringFromClass([ContactTableNINibCell class]) bundle:nil];
//}
//
//#pragma mark - NICollectionViewNibCellObject
//
//- (UINib *)collectionViewCellNib {
//    
//    return [UINib nibWithNibName:NSStringFromClass([ContactCollectionNINibCell class]) bundle:nil];
//}

- (Class)cellClass {
    return [ContactTableNINibCell class];
}

- (Class)collectionViewCellClass {
    return [ContactCollectionNINibCell class];
}

@end
