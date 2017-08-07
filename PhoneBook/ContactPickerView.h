//
//  ContactPicker.h
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModelObject.h"
#import "NIMutableTableViewModel.h"
#include "NIMutableCollectionViewModel.h"
#import "ContactPhoneBookLoader.h"


#define HEIGHT_OF_COLLECTION_VIEW 55
#define NO_DATA_MESSAGE @"Không tìm thấy kết quả phù hợp"

@class ContactPickerView;

@protocol ContactPickerDelegate <NSObject>

@required

- (NSArray *)sectionedArrayOfContactPicker:(ContactPickerView *)contactPicker;

@end

@interface ContactPickerView : UIView<NIMutableTableViewModelDelegate, UITableViewDelegate, NICollectionViewModelDelegate, UICollectionViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) UIViewController<ContactPickerDelegate>* delegate;
@property (strong, nonatomic) NSArray<ContactModelObject<ContactModelObjectDelegate> *> *contacts;
@property (strong, nonatomic) NSString *noResultSearchingMessage;

+ (instancetype)loadToView:(UIView *)view
  inViewController:(id<ContactPickerDelegate>)viewController;


@end
