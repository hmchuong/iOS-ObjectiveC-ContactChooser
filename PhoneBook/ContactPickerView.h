//
//  ContactPickerView.h
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ContactModelObject.h"

// Nimbus
#import "NIMutableTableViewModel.h"
#include "NIMutableCollectionViewModel.h"


#define HEIGHT_OF_COLLECTION_VIEW 55
#define DEFAULT_NO_DATA_MESSAGE @"Không tìm thấy kết quả phù hợp"
#define DEFAULT_SEARCH_PLACEHOLDER @"Nhập tên bạn bè"

@class ContactPickerView;


/**
 Contact picker view
 */
IB_DESIGNABLE
@interface ContactPickerView : UIView<NIMutableTableViewModelDelegate, UITableViewDelegate, NICollectionViewModelDelegate, UICollectionViewDelegate, UISearchBarDelegate>


@property (strong, readonly, nonatomic) NSArray<ContactModelObject *> *contacts;    // Contacts data
@property (strong, nonatomic) IBInspectable NSString *noResultSearchingMessage;     // Message show when no data appear
@property (strong, nonatomic) IBInspectable NSString *searchPlaceholder;            // Placeholder for search bar

/**
 Set sectioned contacts

 @param contacts - Array of sectioned contacts
 */
- (void)setSectionedContacts:(NSArray *)contacts;

@end
