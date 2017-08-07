//
//  ContactPhoneBookPickerViewController.h
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ContactPhoneBookLoader.h"
#include "ContactPickerView.h"
#include "ContactPhoneBook.h"

@interface ContactPhoneBookPickerViewController : UIViewController<ContactPhoneBookLoaderDelegate, ContactPickerDelegate>

@end
