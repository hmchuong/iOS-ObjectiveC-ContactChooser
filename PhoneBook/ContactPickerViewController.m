//
//  ContactChooserViewController.m
//  PhoneBook
//
//  Created by chuonghm on 7/26/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import "ContactPickerViewController.h"
#import <Contacts/Contacts.h>
#import "ThreadSafeMutableArray.h"
#import "ContactPhoneBook.h"
#import "MBProgressHUD.h"
#import "NIMutableTableViewModel.h"
#import "NICellCatalog.h"
#import "ContactTableNINibCell.h"
#import "NimbusCollections.h"
#import "ContactCollectionNINibCell.h"
#import "ImageCache.h"

@interface ContactPickerViewController ()

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;                               // Search bar
@property (weak, nonatomic) IBOutlet UICollectionView *selectedContactsCollectionView;     // Collection view contains selected contacts
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactsViewHeight;       // Height of selected contacts view
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;                       // Table view contains contacts

#pragma mark - Contacts container
@property (strong, nonatomic) NSArray *contacts;                                           // All contacts
@property (retain, nonatomic) NIMutableTableViewModel *contactsModel;
@property (retain, nonatomic) NIMutableTableViewModel *filteredContactsModel;
@property (retain, nonatomic) NIMutableCollectionViewModel * selectedContactsModel;

#pragma mark - Properties
@property BOOL isSearching;                                                                // YES - searching state, NO - non searching state

@end

@implementation ContactPickerViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide selected contacts view
    [_selectedContactsViewHeight setConstant:0];
    
    [ContactPhoneBookLoader sharedInstance].delegate = self;
    
    // Set background of section index to clear
    self.contactsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    _selectedContactsModel = [[NIMutableCollectionViewModel alloc] initWithDelegate:self];
    [_selectedContactsModel addSectionWithTitle:@""];
    self.selectedContactsCollectionView.dataSource = _selectedContactsModel;
    _selectedContactsCollectionView.allowsMultipleSelection = NO;
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Hide search bar keyboard when scroll
    [self.searchBar resignFirstResponder];
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get cell at indexPath
    ContactPhoneBook *cellObject;
    if (_isSearching) {
        cellObject = [_filteredContactsModel objectAtIndexPath:indexPath];
    } else {
        cellObject = [_contactsModel objectAtIndexPath:indexPath];
    }
    
    if ([_selectedContactsModel indexPathForObject:cellObject]) {
        [cell setSelected:YES animated:YES];
        [_contactsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectAllRow];
    
    // Get selected contact
    ContactPhoneBook *selectedContact;
    if (_isSearching) {
        selectedContact = [_filteredContactsModel objectAtIndexPath:indexPath];
    } else {
        selectedContact = [_contactsModel objectAtIndexPath:indexPath];
    }
    
    // Add object to selected contacts
    
    NSArray *indexPathAfterInsert = [_selectedContactsModel addObject:selectedContact];
    //[self.selectedContactsCollectionView reloadData];
    
    // Get index of just added contact in collection view
    NSIndexPath *indexInCollectionView = indexPathAfterInsert[0];
    // Perform animation for adding new selected contact in collection view
    [self.selectedContactsCollectionView performBatchUpdates:^ {
        [self.selectedContactsCollectionView insertItemsAtIndexPaths:@[indexInCollectionView]];
    } completion:^(BOOL success){
        [self.selectedContactsCollectionView.collectionViewLayout invalidateLayout];
        [self.selectedContactsCollectionView.collectionViewLayout prepareLayout];
    }];
    [self.selectedContactsCollectionView reloadData];
   
    // Animation for showing collection view if the first contact has been added
    if ([indexInCollectionView row] == 0) {
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
    
    [self deselectAllRow];
    
    // Get deselected contact
    ContactPhoneBook *deselectedContact;
    if (_isSearching) {
        deselectedContact = [_filteredContactsModel objectAtIndexPath:indexPath];
        [_filteredContactsModel removeObjectAtIndexPath:indexPath];
        deselectedContact.isHighlighted = NO;
        [_filteredContactsModel insertObject:deselectedContact atRow:indexPath.row inSection:indexPath.section];
    } else {
        deselectedContact = [_contactsModel objectAtIndexPath:indexPath];
        [_contactsModel removeObjectAtIndexPath:indexPath];
        deselectedContact.isHighlighted = NO;
        [_contactsModel insertObject:deselectedContact atRow:indexPath.row inSection:indexPath.section];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:[UIColor clearColor]];
    
    // Get indexPath in collection view
    NSIndexPath *indexInCollectionView = [_selectedContactsModel indexPathForObject:deselectedContact];
    
    // Remove the contact from selected contacts
    [_selectedContactsModel removeObjectAtIndexPath:indexInCollectionView];
    
    // Perform animation for remove contact in collection view
    [self.selectedContactsCollectionView performBatchUpdates:^ {
        [self.selectedContactsCollectionView deleteItemsAtIndexPaths:@[indexInCollectionView]];
    } completion:nil];
    
    // Animation for hiding collection view if the last contact has been removed
    if ([_selectedContactsModel collectionView:_selectedContactsCollectionView numberOfItemsInSection:0] == 0) {
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
    
    // Seperator line
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.3)];
    [seperator setBackgroundColor:[UIColor lightGrayColor]];
    [viewForHeaderInSection addSubview:seperator];
    
    // Section title
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [sectionTitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [sectionTitleLabel setTextColor:[UIColor grayColor]];
    NSString *string = [_contactsModel tableView:self.contactsTableView
                         titleForHeaderInSection:section];
    [sectionTitleLabel setText:string];
    
    [viewForHeaderInSection addSubview:sectionTitleLabel];
    [viewForHeaderInSection setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    
    return viewForHeaderInSection;
}

#pragma mark - CollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Disable searching
    if (_isSearching) {
        [self disableSearching];
    }
    ContactPhoneBook *selectedContact = [_selectedContactsModel objectAtIndexPath:indexPath];
    
    if (selectedContact.isHighlighted) {
        [_selectedContactsCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self collectionView:collectionView  didDeselectItemAtIndexPath:indexPath];
        return;
    }
    [self changeHighlightedState:YES
                    AtIndexPath:indexPath];
    
    [_selectedContactsCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Disable searching
    if (_isSearching) {
        [self disableSearching];
    }
    
    [self changeHighlightedState:NO
                     AtIndexPath:indexPath];
}

#pragma mark - UISearchbarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self disableSearching];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _isSearching = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self deselectAllRow];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length == 0) {       // Emty searchText --> non searching state
        _isSearching = NO;
        self.contactsTableView.dataSource = _contactsModel;
        self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.contactsTableView.backgroundView = nil;
    } else {
        _isSearching = YES;
        // Filter data with searchText
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"SELF.fullname CONTAINS[cd] %@",
                                        searchText];
        NSArray *filteredContacts = [_contacts filteredArrayUsingPredicate:resultPredicate];
        _filteredContactsModel = [[NIMutableTableViewModel alloc] initWithListArray:filteredContacts
                                                                    delegate:self];
        self.contactsTableView.dataSource = _filteredContactsModel;
        
        if ([filteredContacts count] == 0) {
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
            self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.contactsTableView.backgroundView = nil;
        }
        
    }
    [self.contactsTableView reloadData];
    
}

#pragma mark - NITableViewModelDelegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
    
    return [NICellFactory tableViewModel:tableViewModel
                        cellForTableView:tableView
                             atIndexPath:indexPath
                              withObject:object];
    
}

#pragma mark - NICollectionViewModelDelegate

- (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                        cellForCollectionView:(UICollectionView *)collectionView
                                  atIndexPath:(NSIndexPath *)indexPath
                                   withObject:(id)object {
    
    return [NICollectionViewCellFactory collectionViewModel:collectionViewModel
                                      cellForCollectionView:collectionView
                                                atIndexPath:indexPath
                                                 withObject:object];
    
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
        if ([contact.fullname length] == 0) {
            continue;
        }
        [contacts addObject:contact];
    }
    self.contacts = contacts;
    [self buildDatasource];
    [self reloadAll];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
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

- (void)deselectAllRow {
    NSArray *indexPaths = [_selectedContactsCollectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in indexPaths) {
        [self changeHighlightedState:NO
                         AtIndexPath:indexPath];
        [_selectedContactsCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)changeHighlightedState:(BOOL)isHighlighted
                   AtIndexPath:(NSIndexPath *)indexPath {
    // Get selected collection cell
    ContactPhoneBook *selectedContact = [_selectedContactsModel objectAtIndexPath:indexPath];
    
    NSIndexPath *indexPathInTableViewOfSelectedContact = [_contactsModel indexPathForObject:selectedContact];
    
    
    
    //Set highlight --> Update (Remove + insert + reload)
    
    selectedContact.isHighlighted = isHighlighted;
    
    // Update collection
    [_selectedContactsModel removeObjectAtIndexPath:indexPath];
    [_selectedContactsModel insertObject:selectedContact
                                   atRow:[indexPath row]
                               inSection:[indexPath section]];
    
    // Update table
    [_contactsModel removeObjectAtIndexPath:indexPathInTableViewOfSelectedContact];
    [_contactsModel insertObject:selectedContact atRow:[indexPathInTableViewOfSelectedContact row] inSection:[indexPathInTableViewOfSelectedContact section]];
    
    if (isHighlighted) {
        [[_contactsTableView cellForRowAtIndexPath:indexPathInTableViewOfSelectedContact] setBackgroundColor: HIGHLIGHT_COLOR];
        [_selectedContactsCollectionView cellForItemAtIndexPath:indexPath].alpha = ALPHA_OF_HIGHLIGH_COLLECTION_CELL;
    } else {
        [[_contactsTableView cellForRowAtIndexPath:indexPathInTableViewOfSelectedContact] setBackgroundColor: [UIColor clearColor]];
        [_selectedContactsCollectionView cellForItemAtIndexPath:indexPath].alpha = 1;
    }
    
    // Scroll to selected contact in table view
    if (selectedContact.isHighlighted) {
        [self.contactsTableView scrollToRowAtIndexPath:indexPathInTableViewOfSelectedContact atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

/**
 Group contacts to alphabetical sections
 */
- (void)buildDatasource {
    NSMutableArray* tableContents = [[NSMutableArray alloc] init];
    
    for (unichar c = 'A'; c <= 'Z'; c++) {
        NSArray *sectionArray;
        NSString *section = [NSString stringWithFormat:@"%c",c];
        sectionArray = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname beginswith[c] %@", section]];
        if ([sectionArray count] > 0) {
            [tableContents addObject:section];
            [tableContents addObjectsFromArray:sectionArray];
        }
    }
    
    NSString *format = @"[^a-zA-Z]+.*";
    NSArray *sectionArray;
    sectionArray = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullname MATCHES %@",format]];
    
    if ([sectionArray count] > 0) {
        [tableContents addObject:@"#"];
        [tableContents addObjectsFromArray:sectionArray];
    }
    _contactsModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:self];
    [_contactsModel setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:YES showsSummary:NO];
}

- (void)reloadAll {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contactsTableView.dataSource = _contactsModel;
        
        
        _selectedContactsModel = [[NIMutableCollectionViewModel alloc] initWithDelegate:self];
        [_selectedContactsModel addSectionWithTitle:@""];
        
        self.selectedContactsCollectionView.dataSource = _selectedContactsModel;

        [self.contactsTableView reloadData];
        [self.selectedContactsCollectionView reloadData];
        _selectedContactsViewHeight.constant = 0;
    });
}

/**
 Disbale searching state
 */
- (void)disableSearching {
    self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.contactsTableView.backgroundView = nil;
    _isSearching = NO;
    [self.searchBar setText:nil];
    [self.searchBar resignFirstResponder];
    self.contactsTableView.dataSource = _contactsModel;
    [self.contactsTableView reloadData];
}

@end
