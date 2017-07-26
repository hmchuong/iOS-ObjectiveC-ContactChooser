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
#import "ThreadSafeMutableArray.h"
#import "Contact.h"
#import "ContactTableViewCell.h"
#import "MBProgressHUD.h"

@interface PhoneBookTableViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) SearchBarView *searchBarView;
@property (strong, nonatomic) ThreadSafeMutableArray *contacts;
@property (strong, nonatomic) NSMutableDictionary *contactsInSections;
@property (strong, nonatomic) NSArray *sectionTitles;

@end

@implementation PhoneBookTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _contacts = [[ThreadSafeMutableArray alloc] init];
    _contactsInSections = [[NSMutableDictionary alloc] init];
    
    [self setupSearchBarView];
    [self loadContacts];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *tableHeaderView = [self.tableView tableHeaderView];
    if (tableHeaderView != nil) {
        [self.tableView bringSubviewToFront:tableHeaderView];
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Make sure search bar always on top of table view
    CGRect rect = _searchBar.frame;
    rect.origin.y = MAX(0, scrollView.contentOffset.y + scrollView.contentInset.top);
    _searchBar.frame = rect;
}

#pragma mark - Tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sectionTitles count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:section]];
    return [sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactTableViewCell";
    ContactTableViewCell *contactCell;
    @try {
        contactCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        NSLog(@"The dequeued cell is not an instance of %@",cellIdentifier);
    }

    NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
    
    Contact *contact = [sectionArray objectAtIndex:[indexPath row]];
    dispatch_async(dispatch_get_main_queue(), ^{
        contactCell.contact = contact;
    });
    return contactCell;
}

#pragma mark - Utility

/**
 Set up search bar view
 */
- (void)setupSearchBarView {
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [_searchBar sizeToFit];
    _searchBarView = [[SearchBarView alloc] initWithFrame:[_searchBar bounds]];
    [_searchBarView addSubview:_searchBar];
    self.tableView.tableHeaderView = _searchBarView;
}

/**
 Load contacts from phone book
 */
- (void)loadContacts {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            //keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactImageDataKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            } else {
                for (CNContact *contact in cnContacts) {
                    // copy data to my custom Contacts class.
                    Contact *newContact = [[Contact alloc] init];
                    newContact.firstName = [contact givenName];
                    newContact.lastName = [contact familyName];
                    newContact.middleName = [contact middleName];
                    newContact.avatar = [UIImage imageWithData:[contact imageData]];
                    if ([newContact.fullname length] == 0) {
                        continue;
                    }
                    [_contacts addObject:newContact];
                }
                
                // filter and remove unexisted sections
                NSArray *baseSections = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
                for (NSString *section in baseSections) {
                    NSArray *sectionArray;
                    if ([section isEqual: @"#"]) {
                        NSString *format = @"[^a-zA-Z]+.*";
                        sectionArray = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname MATCHES %@",format]];
                    } else {
                        sectionArray = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname beginswith[c] %@", section]];
                    }
                    if ([sectionArray count] > 0) {
                        [_contactsInSections setValue:sectionArray forKey:section];
                    }
                }
                NSArray *keys = [_contactsInSections allKeys];
                _sectionTitles = [keys sortedArrayUsingComparator:^(id a, id b) {
                    return [a compare:b options:NSNumericSearch];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
        }        
    }];

}

@end
