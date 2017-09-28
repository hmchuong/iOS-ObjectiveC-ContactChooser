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
#import "ZLMPhoneBookContact.h"

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
+ (NSArray<ZLMPhoneBookContact *> *)getAllRecords;

/**
 Insert object
 
 @param contact - contact to insert
 */
+ (void)insert:(ZLMPhoneBookContact *)contact;

/**
 Insert multiple objects

 @param contacts array of contacts
 */
+ (void)insertContacts:(NSArray<ZLMPhoneBookContact *> *)contacts;

@end

NS_ASSUME_NONNULL_END
