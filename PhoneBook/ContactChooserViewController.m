//
//  ContactChooserViewController.m
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactChooserViewController.h"
#import <Contacts/Contacts.h>
#import "ThreadSafeMutableArray.h"
#import "Contact.h"
#import "ContactTableViewCell.h"
#import "MBProgressHUD.h"
#import "ChosenContactCollectionViewCell.h"

@interface ContactChooserViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chosenContactsViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSArray *filteredContacts;
@property (strong, nonatomic) NSDictionary *contactsInSections;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) ThreadSafeMutableArray *chosenContacts;
@property (strong, nonatomic) NSIndexPath *highlightedIndex;
@property BOOL isSearching;

@end

@implementation ContactChooserViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _contactsInSections = [[NSMutableDictionary alloc] init];
    _chosenContacts = [[ThreadSafeMutableArray alloc] init];
    [_chosenContactsViewHeight setConstant:0];
    //[_searchBar setBackgroundImage:[[UIImage alloc] init]];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self loadContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearching) {
        return 1;
    } else {
        return [_sectionTitles count];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (_isSearching) {
        return nil;
    } else {
        return _sectionTitles;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_isSearching) {
        return nil;
    }
    return [_sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result;
    if (_isSearching) {
        result = [_filteredContacts count];
    } else {
    NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:section]];
    result = [sectionArray count];
    }
    if (result > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    } else {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height/3)];
        noDataLabel.text             = @"Không tìm thấy kết quả phù hợp";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        [backgroundView addSubview:noDataLabel];
        self.tableView.backgroundView = backgroundView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactTableViewCell";
    ContactTableViewCell *contactCell;
    
    @try {
        contactCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        NSLog(@"The dequeued cell is not an instance of %@",cellIdentifier);
    }
    
    
    
    Contact *contact;
    if (_isSearching) {
        NSLog(@"%d-%d",[_filteredContacts count],[indexPath row]);
        contact = [_filteredContacts objectAtIndex:[indexPath row]];
    } else {
        NSLog(@"notsearching");
        NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
        contact = [sectionArray objectAtIndex:[indexPath row]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        contactCell.contact = contact;
    });
    
    if (_highlightedIndex != nil && !_isSearching &&
        _highlightedIndex.row == indexPath.row &&
        _highlightedIndex.section == indexPath.section) {
            contactCell.backgroundColor = [UIColor colorWithRed:230.0/255
                                                          green:230.0/255
                                                           blue:230.0/255
                                                          alpha:1];
    } else {
        contactCell.backgroundColor = [UIColor clearColor];

    }
   
    return contactCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Contact *contact;
    if (_isSearching) {
        NSLog(@"%d-%d",[_filteredContacts count],[indexPath row]);
        contact = [_filteredContacts objectAtIndex:[indexPath row]];
    } else {
        NSLog(@"notsearching");
        NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
        contact = [sectionArray objectAtIndex:[indexPath row]];
    }
    if ([_chosenContacts containsObject:contact]) {
        [cell setSelected:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray;
    if (_isSearching) {
        sectionArray = _filteredContacts;
    } else {
        sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
    }
    [_chosenContacts addObject:[sectionArray objectAtIndex:[indexPath row]]];
    NSIndexPath *indexInCollectionView = [NSIndexPath indexPathForRow:[_chosenContacts count]-1
                                                            inSection: 0];
    [self.collectionView performBatchUpdates:^ {
        [self.collectionView insertItemsAtIndexPaths:@[indexInCollectionView]];
    } completion:^(BOOL success){
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView.collectionViewLayout prepareLayout];
    }];
   
    
    if ([_chosenContacts count] == 1) {
        [UIView animateWithDuration:0.2
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _chosenContactsViewHeight.constant = 55;
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];

    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
    NSObject *uncheckedContact;
    if (_isSearching) {
        uncheckedContact = [_filteredContacts objectAtIndex:[indexPath row]];
    } else {
        uncheckedContact = [sectionArray objectAtIndex:[indexPath row]];
    }
    NSIndexPath *indexInCollectionView = [NSIndexPath indexPathForRow:[_chosenContacts indexOfObject:uncheckedContact]
                                                            inSection: 0];
    _highlightedIndex = nil;
    [[self.tableView cellForRowAtIndexPath:indexPath] setBackgroundColor: [UIColor clearColor]];
    [_chosenContacts removeObject:uncheckedContact];
    [self.collectionView performBatchUpdates:^ {
        [self.collectionView deleteItemsAtIndexPaths:@[indexInCollectionView]];
    } completion:nil];

    if ([_chosenContacts count] == 0) {
        [UIView animateWithDuration:0.2
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _chosenContactsViewHeight.constant = 0;
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_isSearching) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.3)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [view addSubview:seperator];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setTextColor:[UIColor grayColor]];
    NSString *string =[_sectionTitles objectAtIndex:section];
    
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:1
                                             green:1
                                              blue:1
                                             alpha:0.9]];
    return view;
}

#pragma mark - CollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_chosenContacts count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ChosenContactCollectionViewCell";
    ChosenContactCollectionViewCell *chosenCell;
    @try {
        chosenCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        NSLog(@"The dequeued cell is not an instance of %@",cellIdentifier);
    }
    
    Contact *contact = [_chosenContacts objectAtIndex:[indexPath row]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [chosenCell.avatar setImage:[contact avatar]];
    });
    
    return chosenCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearching) {
        _isSearching = NO;
        [self.searchBar setText:nil];
        [self.searchBar resignFirstResponder];
        [self.tableView reloadData];
    }
    UICollectionViewCell *selectedCell =
    [collectionView cellForItemAtIndexPath:indexPath];
    _highlightedIndex = nil;
    Contact *chosenContact = [_chosenContacts objectAtIndex:[indexPath row]];
    NSIndexPath *indexPathOfChosenContact = [self getTableViewIndexPathFromContact:chosenContact];
    
    if ([selectedCell alpha] < 1) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        selectedCell.alpha = 1;
        [[self.tableView cellForRowAtIndexPath:indexPathOfChosenContact] setBackgroundColor: [UIColor clearColor]];
        return;
    }
    
    selectedCell.alpha = 0.5;
    
    
    // Scroll to selected contact
    [self.tableView selectRowAtIndexPath:indexPathOfChosenContact animated:YES scrollPosition:UITableViewScrollPositionTop];
    _highlightedIndex = indexPathOfChosenContact;
    [[self.tableView cellForRowAtIndexPath:indexPathOfChosenContact] setBackgroundColor: [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_isSearching) {
        _isSearching = NO;
        [self.searchBar setText:nil];
        [self.searchBar resignFirstResponder];
        [self.tableView reloadData];
    }
    UICollectionViewCell *deselectedCell =
    [collectionView cellForItemAtIndexPath:indexPath];
    deselectedCell.alpha = 1;
    _highlightedIndex = nil;
    Contact *chosenContact = [_chosenContacts objectAtIndex:[indexPath row]];
    NSIndexPath *indexPathOfChosenContact = [self getTableViewIndexPathFromContact:chosenContact];
    [[self.tableView cellForRowAtIndexPath:indexPathOfChosenContact] setBackgroundColor: [UIColor clearColor]];
}

#pragma mark - UISearchbarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //_isSearching = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //_isSearching = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _isSearching = NO;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _isSearching = YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _isSearching = NO;
        [self.tableView reloadData];
    } else {
        _isSearching = YES;
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"SELF.fullname CONTAINS[cd] %@",
                                        searchText];
        _filteredContacts = [_contacts filteredArrayUsingPredicate:resultPredicate];
        [self.tableView reloadData];
    }
}

#pragma mark - Utilities

- (NSIndexPath *)getTableViewIndexPathFromContact: (Contact *)contact {
    // Get section title & section index
    NSString *sectionTitle = [NSString stringWithFormat:@"%c",[[contact fullname] characterAtIndex:0]];
    
    if(![_sectionTitles containsObject:sectionTitle]) {
        sectionTitle = @"#";
    }
    int sectionIndexOfSelectedContact = [_sectionTitles indexOfObject:sectionTitle];
    
    // Get row index
    NSArray *sectionArray = [_contactsInSections objectForKey:sectionTitle];
    int rowIndexOfSelectedContact = [sectionArray indexOfObject:contact];
    return [NSIndexPath indexPathForRow:rowIndexOfSelectedContact inSection:sectionIndexOfSelectedContact];
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
                NSMutableArray *contacts = [[NSMutableArray alloc] init];
                for (CNContact *contact in cnContacts) {
                    // copy data to my custom Contacts class.
                    Contact *newContact = [[Contact alloc] init];
                    newContact.firstname = [contact givenName];
                    newContact.lastname = [contact familyName];
                    newContact.middlename = [contact middleName];
                    newContact.avatar = [UIImage imageWithData:[contact imageData]];
                    if ([newContact.fullname length] == 0) {
                        continue;
                    }
                    [contacts addObject:newContact];
                }
                _contacts = [[NSArray alloc] initWithArray:contacts];
                
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
