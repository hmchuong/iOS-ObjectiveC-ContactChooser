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

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;                               // Search bar
@property (weak, nonatomic) IBOutlet UICollectionView *selectedContactsCollectionView;     // Collection view contains selected contacts
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactsViewHeight;       // Height of selected contacts view
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;                       // Table view contains contacts

#pragma mark - Contacts Container
@property (strong, nonatomic) NSArray *contacts;                                           // All contacts
@property (strong, nonatomic) NSArray *filteredContacts;                                   // Result contacts of searching
@property (strong, nonatomic) NSDictionary *contactsInSections;                            // Alphabetically group contacts
@property (strong, nonatomic) NSArray *sectionTitles;                                      // Title of sections
@property (strong, nonatomic) ThreadSafeMutableArray *selectedContacts;                    // Selected contacts
@property (strong, nonatomic) NSIndexPath *highlightedIndex;                               // Index of higlighted contact in selected contacts

#pragma mark - Properties
@property BOOL isSearching;                                                                // YES - searching state, NO - non searching state

@end

@implementation ContactChooserViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init arrays
    _contactsInSections = [[NSMutableDictionary alloc] init];
    _selectedContacts = [[ThreadSafeMutableArray alloc] init];
    
    // Hide selected contacts view
    [_selectedContactsViewHeight setConstant:0];
    
    // Set background of section index to clear
    self.contactsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    // Load contacts from phone book
    [self loadContacts];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Hide search bar keyboard when scroll
    [self.searchBar resignFirstResponder];
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // If searching, all results in 1 section
    if (_isSearching) {
        return 1;
    }
    
    // Return #sections
    return [_sectionTitles count];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    // If searching, return no section index
    if (_isSearching) {
        return nil;
    }
    
    // Return section
    return _sectionTitles;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // If searching, return no section title
    if (_isSearching) {
        return nil;
    }
    // Return section title
    return [_sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    
    if (_isSearching) {     // Number of rows is number of filtered contacts
        numberOfRows = [_filteredContacts count];
    } else {                // Number of rows is number of contacts in section
        NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:section]];
        numberOfRows = [sectionArray count];
    }
    
    // If there is no row, show 'no result' message
    if (numberOfRows == 0) {
        // Make a view with message inside
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contactsTableView.bounds.size.width, self.contactsTableView.bounds.size.height/3)];
        noDataLabel.text             = NO_DATA_MESSAGE;
        noDataLabel.textColor        = TEXT_COLOR;
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contactsTableView.bounds.size.width, self.contactsTableView.bounds.size.height)];
        [backgroundView addSubview:noDataLabel];
        
        // Add to table view background
        self.contactsTableView.backgroundView = backgroundView;
        self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        // Remove table view background
        self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.contactsTableView.backgroundView = nil;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get Contact view cell to render
    NSString *cellIdentifier = @"ContactTableViewCell";
    ContactTableViewCell *contactCell;
    
    @try {
        contactCell = [self.contactsTableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        NSLog(@"The dequeued cell is not an instance of %@",cellIdentifier);
    }
    
    // Get contact data at indexPath
    Contact *contact;
    if (_isSearching) {
        contact = [_filteredContacts objectAtIndex:[indexPath row]];
    } else {
        NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
        contact = [sectionArray objectAtIndex:[indexPath row]];
    }
    
    // Update UI of contact view cell
    dispatch_async(dispatch_get_main_queue(), ^{
        contactCell.contact = contact;
    });
    
    // Highlight cell if needed
    if (_highlightedIndex != nil && !_isSearching &&
        _highlightedIndex.row == indexPath.row &&
        _highlightedIndex.section == indexPath.section) {
            contactCell.backgroundColor = HIGHLIGHT_COLOR;
    } else {        // Unhighlight cell
        contactCell.backgroundColor = [UIColor clearColor];
    }
   
    return contactCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get contact at indexPath
    Contact *contact;
    if (_isSearching) {
        contact = [_filteredContacts objectAtIndex:[indexPath row]];
    } else {
        NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
        contact = [sectionArray objectAtIndex:[indexPath row]];
    }
    
    // Set selected cell after reload table view
    if ([_selectedContacts containsObject:contact]) {
        [cell setSelected:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get section array
    NSArray *sectionArray;
    if (_isSearching) {
        sectionArray = _filteredContacts;
    } else {
        sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
    }
    
    // Add object to selected contacts
    [_selectedContacts addObject:[sectionArray objectAtIndex:[indexPath row]]];
    
    // Get index of just added contact in collection view
    NSIndexPath *indexInCollectionView = [NSIndexPath indexPathForRow:[_selectedContacts count]-1
                                                            inSection: 0];
    
    // Perform animation for adding new selected contact in collection view
    [self.selectedContactsCollectionView performBatchUpdates:^ {
        [self.selectedContactsCollectionView insertItemsAtIndexPaths:@[indexInCollectionView]];
    } completion:^(BOOL success){
        [self.selectedContactsCollectionView.collectionViewLayout invalidateLayout];
        [self.selectedContactsCollectionView.collectionViewLayout prepareLayout];
    }];
   
    // Animation for showing collection view if the first contact has been added
    if ([_selectedContacts count] == 1) {
        [UIView animateWithDuration:0.2
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             // Change height of collection view
                             _selectedContactsViewHeight.constant = HEIGHT_OF_COLLECTION_VIEW;
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get deselected contact
    NSObject *deselectedContact;
    if (_isSearching) {
        deselectedContact = [_filteredContacts objectAtIndex:[indexPath row]];
    } else {
        NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
        deselectedContact = [sectionArray objectAtIndex:[indexPath row]];
    }
    
    // Remove highlighted index
    _highlightedIndex = nil;
    [[self.contactsTableView cellForRowAtIndexPath:indexPath] setBackgroundColor: [UIColor clearColor]];
    
    // Get indexPath in collection view
    NSIndexPath *indexInCollectionView = [NSIndexPath indexPathForRow:[_selectedContacts indexOfObject:deselectedContact]
                                                            inSection: 0];
    
    // Remove the contact from selected contacts
    [_selectedContacts removeObject:deselectedContact];
    
    // Perform animation for remove contact in collection view
    [self.selectedContactsCollectionView performBatchUpdates:^ {
        [self.selectedContactsCollectionView deleteItemsAtIndexPaths:@[indexInCollectionView]];
    } completion:nil];
    
    // Animation for hiding collection view if the last contact has been removed
    if ([_selectedContacts count] == 0) {
        [UIView animateWithDuration:0.2
                              delay:0.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             // Change height of collection view
                             _selectedContactsViewHeight.constant = 0;
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // No section view if searching
    if (_isSearching) {
        return nil;
    }
    
    // View contains seperator line + section title below
    UIView *viewForHeaderInSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.3)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [viewForHeaderInSection addSubview:seperator];
    
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [sectionTitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [sectionTitleLabel setTextColor:[UIColor grayColor]];
    NSString *string =[_sectionTitles objectAtIndex:section];
    [sectionTitleLabel setText:string];
    
    [viewForHeaderInSection addSubview:sectionTitleLabel];
    [viewForHeaderInSection setBackgroundColor:[UIColor colorWithRed:1
                                             green:1
                                              blue:1
                                             alpha:0.9]];
    return viewForHeaderInSection;
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_selectedContacts count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Get ContactCollectionViewCell
    NSString *cellIdentifier = @"ChosenContactCollectionViewCell";
    ChosenContactCollectionViewCell *selectedCell;
    @try {
        selectedCell = [self.selectedContactsCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    } @catch (NSException *exception) {
        NSLog(@"The dequeued cell is not an instance of %@",cellIdentifier);
    }
    
    // Get contact at indexPath
    Contact *contact = [_selectedContacts objectAtIndex:[indexPath row]];
    
    // Update UI of ContactCollectionViewCell
    dispatch_async(dispatch_get_main_queue(), ^{
        [selectedCell.avatar setImage:[contact avatar]];
    });
    
    return selectedCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Disable searching
    if (_isSearching) {
        [self disableSearching];
    }
    
    // Remove highlighted index
    _highlightedIndex = nil;
    
    // Get selected collection cell
    Contact *selectedContact = [_selectedContacts objectAtIndex:[indexPath row]];
    NSIndexPath *indexPathInTableViewOfSelectedContact = [self getTableViewIndexPathFromContact:selectedContact];
    
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    
    // If selectedCell has been selected -> deselect when select again
    if ([selectedCell alpha] < 1) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
        // Update UI of deselect cell
        selectedCell.alpha = 1;
        
        // Update UI of deselect table cell
        [[self.contactsTableView cellForRowAtIndexPath:indexPathInTableViewOfSelectedContact] setBackgroundColor: [UIColor clearColor]];
        
        return;
    }
    
    // Update UI of selected collection cell
    selectedCell.alpha = ALPHA_OF_HIGHLIGH_COLLECTION_CELL;
    
    
    // Scroll to selected contact in table view
    [self.contactsTableView selectRowAtIndexPath:indexPathInTableViewOfSelectedContact animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    // Update highlighted index
    _highlightedIndex = indexPathInTableViewOfSelectedContact;
    
    // Highlight cell in table
    [[self.contactsTableView cellForRowAtIndexPath:_highlightedIndex] setBackgroundColor: HIGHLIGHT_COLOR];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Disable searching
    if (_isSearching) {
        [self disableSearching];
    }
    
    // Update UI of deselect collection cell
    UICollectionViewCell *deselectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    deselectedCell.alpha = 1;
    
    // Remove highlighted index
    _highlightedIndex = nil;
    
    // Unhighlight deselected table cell
    Contact *deselectedContact = [_selectedContacts objectAtIndex:[indexPath row]];
    NSIndexPath *indexPathOfChosenContact = [self getTableViewIndexPathFromContact:deselectedContact];
    [[self.contactsTableView cellForRowAtIndexPath:indexPathOfChosenContact] setBackgroundColor: [UIColor clearColor]];
}

#pragma mark - UISearchbarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _isSearching = NO;
    [self.contactsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {       // Emty searchText --> non searching state
        _isSearching = NO;
    } else {
        _isSearching = YES;
        
        // Filter data with searchText
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"SELF.fullname CONTAINS[cd] %@",
                                        searchText];
        _filteredContacts = [_contacts filteredArrayUsingPredicate:resultPredicate];
    }
    
    [self.contactsTableView reloadData];
}

#pragma mark - Utilities

/**
 Get index path in table view of contact

 @param contact - Contact to get index
 @return - index path of contact
 */
- (NSIndexPath *)getTableViewIndexPathFromContact: (Contact *)contact {
    // Get section title & section index
    NSString *sectionTitle = [NSString stringWithFormat:@"%c",[[contact fullname] characterAtIndex:0]];
    
    if(![_sectionTitles containsObject:sectionTitle]) {
        sectionTitle = @"#";
    }
    
    NSUInteger sectionIndexOfSelectedContact = [_sectionTitles indexOfObject:sectionTitle];
    
    // Get row index
    NSArray *sectionArray = [_contactsInSections objectForKey:sectionTitle];
    NSUInteger rowIndexOfSelectedContact = [sectionArray indexOfObject:contact];
    
    return [NSIndexPath indexPathForRow:rowIndexOfSelectedContact inSection:sectionIndexOfSelectedContact];
}

/**
 Load contacts from phone book
 */
- (void)loadContacts {
    // Show progress indicator
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
                
                [self groupContacts];
                
                // Reload table view + hide progress indicator
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.contactsTableView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }
        }
    }];
    
}

/**
 Group contacts to alphabetical sections
 */
- (void)groupContacts {
    // Add alphabetical sections
    for (unichar c = 'A'; c <= 'Z'; c++) {
        NSArray *sectionArray;
        sectionArray = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname beginswith[c] %@", [NSString stringWithFormat:@"%c",c]]];
        
        // Add to section array
        if ([sectionArray count] > 0) {
            [_contactsInSections setValue:sectionArray forKey:[NSString stringWithFormat:@"%c",c]];
        }
    }
    
    // Add "#" section
    NSString *format = @"[^a-zA-Z]+.*";
    NSArray *sectionArray;
    sectionArray = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname MATCHES %@",format]];
    
    // Add to section array
    if ([sectionArray count] > 0) {
        [_contactsInSections setValue:sectionArray forKey:@"#"];
    }
    
    // Sort section titles
    NSArray *keys = [_contactsInSections allKeys];
    _sectionTitles = [keys sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSNumericSearch];
    }];
}

/**
 Disbale searching state
 */
- (void)disableSearching {
    _isSearching = NO;
    [self.searchBar setText:nil];
    [self.searchBar resignFirstResponder];
    [self.contactsTableView reloadData];
}

@end
