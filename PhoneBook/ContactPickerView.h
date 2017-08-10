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
#define NO_DATA_MESSAGE @"Không tìm thấy kết quả phù hợp"

@class ContactPickerView;

/**
 Contact picker delegate protocol
 */
@protocol ContactPickerDelegate <NSObject>

@required


@end


/**
 Contact picker view
 */
IB_DESIGNABLE
@interface ContactPickerView : UIView<NIMutableTableViewModelDelegate, UITableViewDelegate, NICollectionViewModelDelegate, UICollectionViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) id delegate;                     // ContactPicker delegate
@property (strong, readonly, nonatomic) NSArray<ContactModelObject *> *contacts;              // Contacts data
@property (strong, nonatomic) IBInspectable NSString *noResultSearchingMessage;                   // Message show when no data appear

/**
 Set sectioned contacts

 @param contacts - Array of sectioned contacts
 */
- (void)setSectionedContacts:(NSArray *)contacts;

@end
