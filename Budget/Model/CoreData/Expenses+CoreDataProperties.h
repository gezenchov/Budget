//
//  Expenses+CoreDataProperties.h
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Expense.h"

NS_ASSUME_NONNULL_BEGIN

@interface Expense (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *descriptionText;
@property (nullable, nonatomic, retain) Type *type;

@end

NS_ASSUME_NONNULL_END
