//
//  ZLMPhoneBookContactMO+CDP.h
//  
//
//  Created by chuonghm on 9/13/17.
//
//

#import "ZLMPhoneBookContactMO+CDC.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLMPhoneBookContactMO (CoreDataProperties)

+ (NSFetchRequest<ZLMPhoneBookContactMO *> *)fetchRequest;

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

 @return array of ZLMPhoneBookContactMO object
 */
+ (NSArray<ZLMPhoneBookContactMO *> *)getAllRecords;

/**
 Insert with CNContact object
 
 @param cnContact - CNContact to init
 */
+ (void)insertWithCNContact:(CNContact *)cnContact;

/**
 Insert with AddressBookContact
 
 @param aBRecordRef - Contact to init
 */
+ (void)insertWithABRecordRef:(ABRecordRef)aBRecordRef;


@end

NS_ASSUME_NONNULL_END
