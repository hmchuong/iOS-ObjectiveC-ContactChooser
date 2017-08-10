//
//  ContactPhoneBookPickerViewController.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "CPBPickerViewController.h"
#import "MBProgressHUD.h"
#import "ThreadSafeMutableArray.h"
#import "ThreadSafeMutableDictionary.h"
#import "NSString+Extension.h"

@interface CPBPickerViewController ()

@property (weak, nonatomic) IBOutlet ContactPickerView *contactPicker;

@end

@implementation CPBPickerViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _contactPicker.delegate = self;
    [self updateContactData];
    
    // Listen when contacts change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContactData)
                                                 name:CNContactStoreDidChangeNotification
                                               object:nil];
}

#pragma mark - ContactPickerDelegate

#pragma mark - Utilities

/**
 Update phone book contacts Data
 */
- (void)updateContactData {
    
    
    // Show progress view
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    
    [PhoneBookContactLoader.sharedInstance getPhoneBookContactsWithCompletion: ^(BOOL granted, NSArray <PhoneBookContact *> *contacts) {
        
        if (granted) {
            // Build custom contact cell object
            NSDate *_operation = [NSDate date];
            NSMutableDictionary *tableContents = [[NSMutableDictionary alloc] init];
            for (PhoneBookContact *contact in contacts) {
                PhoneBookContactCell *contactCell = [[PhoneBookContactCell alloc] initWithPhoneBookContact: contact];
                if ([[contactCell fullname] length] == 0) {
                    continue;
                }
                
                unichar firstChar = [[contactCell.fullname uppercaseString] characterAtIndex:0];
                if (!(firstChar >= 'A' && firstChar <= 'Z')
                    && !(firstChar >= '0' && firstChar <= '9')) {
                    firstChar = [[[contactCell.fullname uppercaseString] toANSCI] characterAtIndex:0];
                }
                if (!(firstChar >= 'A' && firstChar <= 'Z')) {
                    firstChar = '#';
                }
                NSString *section = [NSString stringWithFormat:@"%c",firstChar];
                
                NSMutableArray *sectionArray = tableContents[section];
                if (sectionArray == nil) {
                    sectionArray = [[NSMutableArray alloc] init];
                }
                [sectionArray addObject:contactCell];
                tableContents[section] = sectionArray;
            }
            
            
            NSMutableArray *sectionedContacts = [[NSMutableArray alloc] init];
            NSArray *sortedKeys = [[tableContents allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
            for (id key in sortedKeys) {
                [sectionedContacts addObject:key];
                [sectionedContacts addObjectsFromArray:tableContents[key]];
            }
            
            [self.contactPicker setSectionedContacts:sectionedContacts];
            NSLog(@"Time: %f", -[_operation timeIntervalSinceNow]);
            
        }
        
        // Hide progress view
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        if (!granted) {
            // Request permission
            [self showContactPermissionRequest];
        }
    }];
}

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
