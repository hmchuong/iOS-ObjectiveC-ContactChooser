//
//  ContactChooserViewController.h
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactPhoneBook.h"
#import "NIMutableTableViewModel.h"
#include "NIMutableCollectionViewModel.h"
#import "ContactPhoneBookLoader.h"

#define TEXT_COLOR [UIColor blackColor]
#define HIGHLIGHT_COLOR [UIColor colorWithRed:230.0/255 \
                                        green:230.0/255 \
                                         blue:230.0/255 \
                                        alpha:1]
#define HEIGHT_OF_COLLECTION_VIEW 55
#define ALPHA_OF_HIGHLIGH_COLLECTION_CELL 0.5
#define NO_DATA_MESSAGE @"Không tìm thấy kết quả phù hợp"

@interface ContactPickerViewController : UIViewController<NIMutableTableViewModelDelegate, UITableViewDelegate, NICollectionViewModelDelegate, UICollectionViewDelegate, UISearchBarDelegate,ContactPhoneBookLoaderDelegate>

@end
