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

@property (weak, nonatomic) IBOutlet UIView *contactPicker;
@property (strong, nonatomic) ContactPickerView *contactPickerModel;

@end

@implementation ContactPhoneBookPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contactPickerModel = [ContactPickerView loadToView:_contactPicker inViewController:self];
    [ContactPhoneBookLoader sharedInstance].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ContactPhoneBookLoaderDelegate

- (NSArray *)contactPhoneBookLoaderGetContactPropertiesKeys {
    
    return @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactImageDataKey, CNContactIdentifierKey];
}

- (void)contactPhoneBookLoaderPermissionDenied {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    // Request permission
    [self showContactPermissionRequest];
}

- (void)contactPhoneBookLoaderStartUpdateContacts {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
}

- (void)contactPhoneBookLoaderDoneUpdateContacts:(NSArray<CNContact *> *)cnContacts
                                       withError:(NSError *)error {
    
#if DEBUG
    NSAssert(!error, error.description);
#endif
    
    // Build datasource
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for (CNContact *cnContact in cnContacts) {
        ContactPhoneBook *contact = [[ContactPhoneBook alloc] initWithCNContact:cnContact];
        if ([[contact getFullname] length] == 0) {
            continue;
        }
        [contacts addObject:contact];
    }
    
    self.contactPickerModel.contacts = contacts;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

#pragma mark - ContactPickerDelegate

- (NSArray *)sectionedArrayOfContactPicker:(ContactPickerView *)contactPicker {
    NSMutableArray* tableContents = [[NSMutableArray alloc] init];
    
    for (unichar c = 'A'; c <= 'Z'; c++) {
        NSArray *sectionArray;
        NSString *section = [NSString stringWithFormat:@"%c",c];
        sectionArray = [self.contactPickerModel.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname beginswith[c] %@", section]];
        if ([sectionArray count] > 0) {
            [tableContents addObject:section];
            [tableContents addObjectsFromArray:sectionArray];
        }
    }
    
    NSString *format = @"[^a-zA-Z]+.*";
    NSArray *sectionArray;
    sectionArray = [self.contactPickerModel.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname MATCHES %@",format]];
    
    if ([sectionArray count] > 0) {
        [tableContents addObject:@"#"];
        [tableContents addObjectsFromArray:sectionArray];
    }
    return tableContents;
}

#pragma mark - Utilities

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
