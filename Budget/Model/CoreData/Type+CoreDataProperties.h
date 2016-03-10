//
//  Type+CoreDataProperties.h
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Type.h"

NS_ASSUME_NONNULL_BEGIN

@interface Type (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSSet<Expense *> *expenses;

@end

@interface Type (CoreDataGeneratedAccessors)

- (void)addExpensesObject:(Expense *)value;
- (void)removeExpensesObject:(Expense *)value;
- (void)addExpenses:(NSSet<Expense *> *)values;
- (void)removeExpenses:(NSSet<Expense *> *)values;

@end

NS_ASSUME_NONNULL_END
