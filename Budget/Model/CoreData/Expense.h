//
//  Expenses.h
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Type;

NS_ASSUME_NONNULL_BEGIN

@interface Expense : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (Expense*)createExpenseWithAmount:(NSNumber *)amount description:(NSString*)descriptionText type:(Type*)type date:(NSDate*)date;

@end

NS_ASSUME_NONNULL_END

#import "Expenses+CoreDataProperties.h"
