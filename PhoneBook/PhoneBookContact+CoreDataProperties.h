//
//  PhoneBookContact+CoreDataProperties.h
//  
//
//  Created by chuonghm on 9/13/17.
//
//

#import "PhoneBookContact+CoreDataClass.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhoneBookContact (CoreDataProperties)

+ (NSFetchRequest<PhoneBookContact *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *firstName;                      // first name of contact
@property (nullable, nonatomic, copy) NSString *identifier;                     // id of contact
@property (nullable, nonatomic, copy) NSString *lastName;                       // last name of contact
@property (nullable, nonatomic, copy) NSString *middleName;                     // middle name of contact

/**
 Delete all records in core data
 */
+ (void)deleteAllRecords;

/**
 Get all records in core data

 @return array of PhoneBookContact object
 */
+ (NSArray<PhoneBookContact *> *)getAllRecords;

/**
 Init with CNContact object
 
 @param cnContact - CNContact to init
 @return PhoneBookContact object
 */
+ (instancetype)insertWithCNContact:(CNContact *)cnContact;

/**
 Init with AddressBookContact
 
 @param aBRecordRef - Contact to init
 @return PhoneBookContact object
 */
+ (instancetype)insertWithABRecordRef:(ABRecordRef)aBRecordRef;


@end

NS_ASSUME_NONNULL_END
