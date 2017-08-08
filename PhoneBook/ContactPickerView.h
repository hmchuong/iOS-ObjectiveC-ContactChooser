//
//  ContactPickerView.h
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>

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

/**
 Get sectioned data

 @param contactPicker - ContactPickerView want to get
 @param contacts - contacts to section
 @return - NSArray of sectioned data
 */
- (NSArray *)sectionedDataOfContactPicker:(ContactPickerView *)contactPicker
                              withContacts:(NSArray<ContactModelObject *> *) contacts;

@end


/**
 Contact picker view
 */
IB_DESIGNABLE
@interface ContactPickerView : UIView<NIMutableTableViewModelDelegate, UITableViewDelegate, NICollectionViewModelDelegate, UICollectionViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) id<ContactPickerDelegate> delegate;                     // ContactPicker delegate
@property (strong, nonatomic) NSArray<ContactModelObject *> *contacts;              // Contacts data
@property (strong, nonatomic) IBInspectable NSString *noResultSearchingMessage;                   // Message show when no data appear


@end
