//
//  PhoneBookContact.m
//  PhoneBook
//
//  Created by chuonghm on 8/10/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

@import UIKit;
#import "PhoneBookContact.h"
#import "ImageCache.h"

@implementation PhoneBookContact

- (instancetype)init {
    
    self = [super init];
    
    _firstName = @"";
    _middleName = @"";
    _lastName = @"";
    _identifier = @"";
    
    return self;
}

- (instancetype)initWithCNContact:(CNContact *)cnContact {
    
    self = [super init];
    
    _firstName = cnContact.givenName;
    _middleName = cnContact.middleName;
    _lastName = cnContact.familyName;
    _identifier = cnContact.identifier;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *avatar = [UIImage imageWithData:[cnContact imageData]];
        if (avatar != nil) {
            [ImageCache.sharedInstance storeImage:avatar
                                          withKey:self.identifier];
        }
    });
    
    return self;
}

- (instancetype)initWithABRecordRef:(ABRecordRef)aBRecordRef {
    
    self = [super init];
    
    CFStringRef firstName, middleName, lastName;
    firstName = ABRecordCopyValue(aBRecordRef, kABPersonFirstNameProperty);
    middleName = ABRecordCopyValue(aBRecordRef, kABPersonMiddleNameProperty);
    lastName = ABRecordCopyValue(aBRecordRef, kABPersonLastNameProperty);
    _firstName = [NSString stringWithFormat:@"%@",firstName];
    _middleName = [NSString stringWithFormat:@"%@",middleName];
    _lastName = [NSString stringWithFormat:@"%@",lastName];

    ABRecordID recordID = ABRecordGetRecordID(aBRecordRef);
    _identifier = [NSString stringWithFormat:@"%d", recordID];
    
    UIImage *avatar;
    if (ABPersonHasImageData(aBRecordRef)) {
        avatar = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(aBRecordRef)];
    }
    
    if (avatar != nil) {
        [ImageCache.sharedInstance storeImage:avatar
                                      withKey:_identifier];
    }
    
    return self;
}

@end
