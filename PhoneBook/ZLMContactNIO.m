//
//  ZLMContactNIO.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ZLMContactNIO.h"
#import "ZLMContactCollectionNICell.h"
#import "ZLMContactTableNICell.h"


@implementation ZLMContactNIO

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

- (Class)cellClass {
    return [ZLMContactTableNICell class];
}

- (Class)collectionViewCellClass {
    return [ZLMContactCollectionNICell class];
}

@end
