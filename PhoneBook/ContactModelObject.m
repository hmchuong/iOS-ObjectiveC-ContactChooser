//
//  ContactModel.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactModelObject.h"
#import "ContactCollectionNINibCell.h"
#import "ContactTableNINibCell.h"


@implementation ContactModelObject

- (instancetype)init {
    self = [super init];
    _alphaOfHighlightedCollectionCell = ALPHA_OF_HIGHLIGHTED_COLLECTION_CELL;
    _highlightedTableCellBackgroundColor = HIGHLIGHT_COLOR;
    return self;
}

- (UINib *)cellNib {
    return [UINib nibWithNibName:NSStringFromClass([ContactTableNINibCell class]) bundle:nil];
}

- (UINib *)collectionViewCellNib {
    return [UINib nibWithNibName:NSStringFromClass([ContactCollectionNINibCell class]) bundle:nil];
}

@end
