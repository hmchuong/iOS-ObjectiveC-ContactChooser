//
//  ContactPickerView.m
//  PhoneBook
//
//  Created by chuonghm on 8/7/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Contacts/Contacts.h>

#import "ContactPickerView.h"

// Nimbus
#import "NIMutableTableViewModel.h"
#import "NICellCatalog.h"
#import "NimbusCollections.h"

// View cell
#import "ContactTableNINibCell.h"
#import "ContactCollectionNINibCell.h"

@interface ContactPickerView()

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;                               // Search bar
@property (weak, nonatomic) IBOutlet UICollectionView *selectedContactsCollectionView;     // Collection view contains selected contacts
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedContactsViewHeight;       // Height of selected contacts view
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;                       // Table view contains contacts
@property (unsafe_unretained, nonatomic) ContactPickerView * subView;

#pragma mark - Contacts Nimbus model
@property (retain, nonatomic) NIMutableCollectionViewModel * selectedContactsModel;        // Selected contacts collection view model
@property (retain, nonatomic) NIMutableTableViewModel *contactsModel;                      // Contacts collection view model
@property (retain, nonatomic) NIMutableTableViewModel *filteredContactsModel;              // Contacts when searching model


#pragma mark - Properties
@property BOOL isSearching;                                                                // YES - searching state, NO - non searching state

@end

@implementation ContactPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self= [super initWithFrame:frame]) {
        if (self.subviews.count == 0) {
            [self setupView];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        if (self.subviews.count == 0) {
            [self setupView];
        }
    }
    return self;
}

- (void)setupView {
    _subView = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([ContactPickerView class]) owner:self options:nil] firstObject];
    [_subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_subView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":_subView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":_subView}]];
}


#pragma mark - Setters

- (void)setDelegate:(id<ContactPickerDelegate>)delegate {
    
    if (_subView) {
        _subView.delegate = delegate;
        return;
    }
    
    _delegate = delegate;
}

- (void)setContacts:(NSArray *)contacts {
    
    if (_subView) {
        [_subView setContacts:contacts];
        return;
    }
    
    _contacts = contacts;
    
    // Build contacts model
    NSArray *sectionedArray;
    if ([_delegate respondsToSelector:@selector(sectionedDataOfContactPicker:withContacts:)]) {
        sectionedArray = [_delegate sectionedDataOfContactPicker:self withContacts:_contacts];
    } else {
#if DEBUG
        NSAssert(NO, @"%@ not responds to selector",NSStringFromClass([_delegate class]));
#endif
    }
    
    if (sectionedArray != nil) {
        _contactsModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:sectionedArray delegate:self];
        [_contactsModel setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:YES showsSummary:NO];
    }
#if DEBUG
    NSAssert(sectionedArray != nil, @"Sectioned array is null");
#endif
    
    [self reloadAll];
    
    
}

#pragma mark - Life cycle

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    // Init delegates
    _contactsTableView.delegate = self;
    _searchBar.delegate = self;
    _selectedContactsCollectionView.delegate = self;
    
    // Hide selected contacts view
    [_selectedContactsViewHeight setConstant:0];
    
    // Set default no data message
    _noResultSearchingMessage = NO_DATA_MESSAGE;
    
    // Set background of section index to clear
    self.contactsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    // Init selected contacts model
    _selectedContactsModel = [[NIMutableCollectionViewModel alloc] initWithDelegate:self];
    [_selectedContactsModel addSectionWithTitle:@""];
    self.selectedContactsCollectionView.dataSource = _selectedContactsModel;
    
    // Allow single selection in collection view
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
    ContactModelObject *cellObject;
    if (_isSearching) {
        cellObject = [_filteredContactsModel objectAtIndexPath:indexPath];
    } else {
        cellObject = [_contactsModel objectAtIndexPath:indexPath];
    }
    
    if ([_selectedContactsModel indexPathForObject:cellObject]) {
        // If cell is selected, update UI
        [cell setSelected:YES animated:YES];
        [_contactsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self deselectAllRow];
    
    // Get selected contact
    ContactModelObject *selectedContact;
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
                             [self layoutIfNeeded];
                         }
                         completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self deselectAllRow];
    
    ContactModelObject *deselectedContact;
    
    // Update table UI of deselected contact
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
                             [self layoutIfNeeded];
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
    
    // Add section label to view
    [viewForHeaderInSection addSubview:sectionTitleLabel];
    
    // Background of view
    [viewForHeaderInSection setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.9]];
    
    return viewForHeaderInSection;
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Disable searching
    if (_isSearching) {
        [self disableSearching];
    }
    
    // Get selected contact
    ContactModelObject *selectedContact = [_selectedContactsModel objectAtIndexPath:indexPath];
    
    // If contact is selected --> Deselect contact
    if (selectedContact.isHighlighted) {
        [_selectedContactsCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self collectionView:collectionView  didDeselectItemAtIndexPath:indexPath];
        return;
    }
    
    // Change UI of contact
    [self changeHighlightedState:YES
                     AtIndexPath:indexPath];
    
    [_selectedContactsCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Disable searching
    if (_isSearching) {
        [self disableSearching];
    }
    
    // Change UI of contact
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
    
    if (searchText.length == 0) {       // Emty searchText --> non searching state, tableModel = contactsModel
        _isSearching = NO;
        
        self.contactsTableView.dataSource = _contactsModel;
        [self hideNoDataMessage];
    } else {
        _isSearching = YES;
        
        // Filter data with searchText
        NSPredicate *resultPredicate = [NSPredicate
                                        predicateWithFormat:@"SELF.fullname CONTAINS[cd] %@",
                                        searchText];
        NSArray *filteredContacts = [_contacts filteredArrayUsingPredicate:resultPredicate];
        _filteredContactsModel = [[NIMutableTableViewModel alloc] initWithListArray:filteredContacts
                                                                           delegate:self];
        
        // Update table model to filtered contacts
        self.contactsTableView.dataSource = _filteredContactsModel;
        
        // Show/hide no data message
        if ([filteredContacts count] == 0) {
            [self showNoDataMessage];
        } else {
            [self hideNoDataMessage];
        }
    }
    
    // reload table
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

#pragma mark - Utilities

/**
 Hide no data message from table
 */
- (void)hideNoDataMessage {
    
    self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.contactsTableView.backgroundView = nil;
}

/**
 Show no data message in table
 */
- (void)showNoDataMessage {
    
    // Label of message text
    UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contactsTableView.bounds.size.width, self.contactsTableView.bounds.size.height/3)];
    noDataLabel.text             = _noResultSearchingMessage;
    noDataLabel.textColor        = [UIColor blackColor];
    noDataLabel.textAlignment    = NSTextAlignmentCenter;
    
    // Background view
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contactsTableView.bounds.size.width, self.contactsTableView.bounds.size.height)];
    [backgroundView addSubview:noDataLabel];
    
    // Add to table view background
    self.contactsTableView.backgroundView = backgroundView;
    self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/**
 Deselect all row in table and collection view
 */
- (void)deselectAllRow {
    
    NSArray *indexPaths = [_selectedContactsCollectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in indexPaths) {
        [self changeHighlightedState:NO
                         AtIndexPath:indexPath];
        [_selectedContactsCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

/**
 Change highlight state of cell at index path

 @param isHighlighted - Value of highlighted
 @param indexPath - index path of cell to change
 */
- (void)changeHighlightedState:(BOOL)isHighlighted
                   AtIndexPath:(NSIndexPath *)indexPath {
    
    // Get selected collection cell
    ContactModelObject *selectedContact = [_selectedContactsModel objectAtIndexPath:indexPath];
    
    NSIndexPath *indexPathInTableViewOfSelectedContact = [_contactsModel indexPathForObject:selectedContact];
    
    
    
    //Set highlight --> Update (Remove + insert)
    selectedContact.isHighlighted = isHighlighted;
    
    // Update collection
    [_selectedContactsModel removeObjectAtIndexPath:indexPath];
    [_selectedContactsModel insertObject:selectedContact
                                   atRow:[indexPath row]
                               inSection:[indexPath section]];
    
    // Update table
    [_contactsModel removeObjectAtIndexPath:indexPathInTableViewOfSelectedContact];
    [_contactsModel insertObject:selectedContact atRow:[indexPathInTableViewOfSelectedContact row] inSection:[indexPathInTableViewOfSelectedContact section]];
    
    // Update UI
    if (isHighlighted) {
        [[_contactsTableView cellForRowAtIndexPath:indexPathInTableViewOfSelectedContact] setBackgroundColor: selectedContact.highlightedTableCellBackgroundColor];
        [_selectedContactsCollectionView cellForItemAtIndexPath:indexPath].alpha = selectedContact.alphaOfHighlightedCollectionCell;
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
 Reload all data in collection view and table view
 */
- (void)reloadAll {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Reload table view
        self.contactsTableView.dataSource = _contactsModel;
        [self.contactsTableView reloadData];
        
        // Reload collection view
        _selectedContactsModel = [[NIMutableCollectionViewModel alloc] initWithDelegate:self];
        [_selectedContactsModel addSectionWithTitle:@""];
        
        self.selectedContactsCollectionView.dataSource = _selectedContactsModel;
        [self.selectedContactsCollectionView reloadData];
        
        // Hide collection view
        _selectedContactsViewHeight.constant = 0;
    });
}

/**
 Disbale searching state
 */
- (void)disableSearching {
    
    [self hideNoDataMessage];
    
    // Non-searching state
    _isSearching = NO;
    [self.searchBar setText:nil];
    [self.searchBar resignFirstResponder];
    
    // Reload table data
    self.contactsTableView.dataSource = _contactsModel;
    [self.contactsTableView reloadData];
}

@end
