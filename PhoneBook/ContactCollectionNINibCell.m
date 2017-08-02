//
//  ContactCollectionNINibCell.m
//  PhoneBook
//
//  Created by chuonghm on 8/1/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactCollectionNINibCell.h"

@implementation ContactCollectionNINibCellObject

+ (instancetype)objectWithContact:(Contact *)contact {
    ContactCollectionNINibCellObject *collectionCellObject = [[ContactCollectionNINibCellObject alloc] init];
    collectionCellObject.contact = contact;
    return collectionCellObject;
}

- (UINib *)collectionViewCellNib {
    return [UINib nibWithNibName:NSStringFromClass([ContactCollectionNINibCell class]) bundle:nil];
}

+ (NSArray *)genterateCellArrayFromContactArray:(NSArray *)contacts {
    NSMutableArray *cellArray = [[NSMutableArray alloc] init];
    for (Contact *contact in contacts) {
        [cellArray addObject:[ContactCollectionNINibCellObject objectWithContact:contact]];
    }
    return cellArray;
}


@end

@implementation ContactCollectionNINibCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (BOOL)shouldUpdateCellWithObject:(ContactCollectionNINibCellObject *)object {
    [_avatar setImage:[object.contact avatar]];
    [_avatar.layer setCornerRadius:self.frame.size.width/2];
    _avatar.clipsToBounds = YES;
    return YES;
}

@end
