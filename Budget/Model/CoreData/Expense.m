//
//  Expenses.m
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//

#import "Expense.h"
#import "Type.h"
#import "PTGApplicationManager.h"

@implementation Expense

// Insert code here to add functionality to your managed object subclass

+ (Expense*)createExpenseWithAmount:(NSNumber *)amount description:(NSString *)descriptionText type:(Type *)type date:(NSDate *)date {
    
    PTGCoreDataManager *coreDataManager = [PTGApplicationManager sharedManager].coreDataManager;
    Expense *expense = [PTGCoreDataManager insertNewObjectForEntityForName:@"Expense"
                                                   inManagedObjectContext:coreDataManager.masterManagedObjectContext];

    expense.amount = amount;
    expense.descriptionText = descriptionText;
    expense.type = type;
    expense.date = date;

    [coreDataManager save];

    return expense;
}

@end
