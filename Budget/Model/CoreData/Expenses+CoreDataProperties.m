//
//  Expenses+CoreDataProperties.m
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Expenses+CoreDataProperties.h"

@implementation Expense (CoreDataProperties)

@dynamic amount;
@dynamic date;
@dynamic descriptionText;
@dynamic type;

@end
