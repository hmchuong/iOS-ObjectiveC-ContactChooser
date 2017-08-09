//
//  ContactPhoneBookPickerViewController.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactPhoneBookPickerViewController.h"
#import "MBProgressHUD.h"
#import "ThreadSafeMutableArray.h"
#import "ThreadSafeMutableDictionary.h"

@interface ContactPhoneBookPickerViewController ()

@property (weak, nonatomic) IBOutlet ContactPickerView *contactPicker;
@property (strong, nonatomic) NSDate *operation;
@end

@implementation ContactPhoneBookPickerViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _contactPicker.delegate = self;
    
    ContactPhoneBookLoader.sharedInstance.delegate = self;
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
    _operation = [NSDate date];
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
        if ([[contact fullname] length] != 0) {
            [contacts addObject:contact];
        }
    }
    
    // Pass contact array to contact picker
    self.contactPicker.contacts = contacts;
    NSLog(@"Time: %f", -[_operation timeIntervalSinceNow]);
    // Hide Progress view
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

#pragma mark - ContactPickerDelegate

- (NSArray *)sectionedDataOfContactPicker:(ContactPickerView *)contactPicker withContacts:(NSArray<ContactModelObject *> *)contacts {
    
    ThreadSafeMutableDictionary *tableContents = [[ThreadSafeMutableDictionary alloc] init];
    
    dispatch_group_t initContactGroup = dispatch_group_create();
    // Grouping alphabetically
    for (unichar c = 'A'; c <= 'Z'; c++) {
        dispatch_group_async(initContactGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray *sectionArray;
            NSString *section = [NSString stringWithFormat:@"%c",c];
            sectionArray = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname beginswith[c] %@", section]];
            if ([sectionArray count] > 0) {
                tableContents[section] = sectionArray;
            }
        });
    }
    
    dispatch_group_async(initContactGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // Grouping another contacts to section "#"
        NSString *format = @"[^a-zA-Z]+.*";
        NSArray *sectionArray;
        sectionArray = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname MATCHES %@",format]];
        
        if ([sectionArray count] > 0) {
            tableContents[@"#"] = sectionArray;
        }
    });
    
    dispatch_group_wait(initContactGroup, DISPATCH_TIME_FOREVER);
    
    // Grouping
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDictionary *sectionedContactsDict = [tableContents toNSDictionary];
    NSArray *sortedKeys = [[sectionedContactsDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    for (id key in sortedKeys) {
        [result addObject:key];
        [result addObjectsFromArray:sectionedContactsDict[key]];
    }
    
    return result;
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
