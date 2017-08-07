//
//  ContactPhoneBookPickerViewController.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactPhoneBookPickerViewController.h"
#import "MBProgressHUD.h"

@interface ContactPhoneBookPickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *contactPickerView;             // UIView contains ContactPickerView
@property (strong, nonatomic) ContactPickerView *contactPicker;             // Contact picker view

@end

@implementation ContactPhoneBookPickerViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _contactPicker = [ContactPickerView initWithView:_contactPickerView inViewController:self];
    [ContactPhoneBookLoader sharedInstance].delegate = self;
}


#pragma mark - ContactPhoneBookLoaderDelegate

- (NSArray *)contactPhoneBookLoaderGetContactPropertiesKeys {
    
    return @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactImageDataKey, CNContactIdentifierKey];
}

- (void)contactPhoneBookLoaderPermissionDenied {
    
    // Hide progress view
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    // Request permission
    [self showContactPermissionRequest];
}

- (void)contactPhoneBookLoaderStartUpdateContacts {
    
    // Show progress view
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
}

- (void)contactPhoneBookLoaderDoneUpdateContacts:(NSArray<CNContact *> *)cnContacts
                                       withError:(NSError *)error {
    
#if DEBUG
    NSAssert(!error, error.description);
#endif
    
    // Build custom contact object
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for (CNContact *cnContact in cnContacts) {
        ContactPhoneBook *contact = [[ContactPhoneBook alloc] initWithCNContact:cnContact];
        if ([[contact fullname] length] == 0) {
            continue;
        }
        [contacts addObject:contact];
    }
    
    // Pass contact array to contact picker
    self.contactPicker.contacts = contacts;
    
    // Hide Progress view
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

#pragma mark - ContactPickerDelegate

- (NSArray *)sectionedDataOfContactPicker:(ContactPickerView *)contactPicker withContacts:(NSArray<ContactModelObject *> *)contacts {
    NSMutableArray* tableContents = [[NSMutableArray alloc] init];
    
    // Grouping alphabetically
    for (unichar c = 'A'; c <= 'Z'; c++) {
        NSArray *sectionArray;
        NSString *section = [NSString stringWithFormat:@"%c",c];
        sectionArray = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname beginswith[c] %@", section]];
        if ([sectionArray count] > 0) {
            [tableContents addObject:section];
            [tableContents addObjectsFromArray:sectionArray];
        }
    }
    
    // Grouping another contacts to section "#"
    NSString *format = @"[^a-zA-Z]+.*";
    NSArray *sectionArray;
    sectionArray = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname MATCHES %@",format]];
    
    if ([sectionArray count] > 0) {
        [tableContents addObject:@"#"];
        [tableContents addObjectsFromArray:sectionArray];
    }
    
    // Grouping
    return tableContents;
}

#pragma mark - Utilities

/**
 Show pop up request allowing this app accesses phonebook contacts
 */
- (void)showContactPermissionRequest {
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Access phone book"
                                                                  message:@"This application request to access phone book contact for right behavior. Click 'Setting' and turn on 'Phone book' permission"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Setting"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}



@end
