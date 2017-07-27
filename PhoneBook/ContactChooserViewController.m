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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chosenContactsViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ThreadSafeMutableArray *contacts;
@property (strong, nonatomic) NSMutableDictionary *contactsInSections;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) ThreadSafeMutableArray *chosenContacts;
@property bool justSelect;

@end

@implementation ContactChooserViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _contacts = [[ThreadSafeMutableArray alloc] init];
    _contactsInSections = [[NSMutableDictionary alloc] init];
    _chosenContacts = [[ThreadSafeMutableArray alloc] init];
    [_chosenContactsViewHeight setConstant:0];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self loadContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
    [_chosenContacts addObject:[sectionArray objectAtIndex:[indexPath row]]];
    _justSelect = YES;
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
                             _chosenContactsViewHeight.constant = 60;
                             [self.view layoutIfNeeded];
                         }
                         completion:nil];

    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionArray = [_contactsInSections objectForKey:[_sectionTitles objectAtIndex:[indexPath section]]];
    NSObject *uncheckedContact = [sectionArray objectAtIndex:[indexPath row]];
    NSIndexPath *indexInCollectionView = [NSIndexPath indexPathForRow:[_chosenContacts indexOfObject:uncheckedContact]
                                                            inSection: 0];
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (_justSelect && [indexPath row] == [_chosenContacts count]-1) {
//        cell.alpha = 0;
//        [UIView animateWithDuration:0.5
//                              delay:0.2
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             cell.alpha = 1;
//                         }
//                         completion:nil];
//        _justSelect = NO;
//    }
}


#pragma mark - Utilities

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
