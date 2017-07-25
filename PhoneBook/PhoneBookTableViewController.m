//
//  ViewController.m
//  PhoneBook
//
//  Created by chuonghm on 7/25/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "PhoneBookTableViewController.h"
#import <Contacts/Contacts.h>
#import "SearchBarView.h"

@interface PhoneBookTableViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation PhoneBookTableViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect rect = _searchBar.frame;
    rect.origin.y = MAX(0, scrollView.contentOffset.y);
    _searchBar.frame = rect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [_searchBar sizeToFit];
    SearchBarView *searchBarView = [[SearchBarView alloc] initWithFrame:[_searchBar bounds]];
    [searchBarView addSubview:_searchBar];
    self.tableView.tableHeaderView = searchBarView;
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
            NSError *error;
            int __block count = 0;
            int __block imageCount = 0;
            BOOL success = [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop) {
                if (error) {
                    NSLog(@"error fetching contacts %@", error);
                } else {
                    // copy data to my custom Contact class.
                    NSLog(@"%@", contact.givenName);
                    UIImage *image = [UIImage imageWithData:contact.imageData];
                    count ++;
                    if (image != nil) {
                        imageCount ++;
                    }
                    // etc.
                }
            }];
            NSLog(@"Number of phone: %d", count);
            NSLog(@"Number of image: %d", imageCount);
        }        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
