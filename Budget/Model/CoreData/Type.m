//
//  Type.m
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//

#import "Type.h"
#import "Expense.h"
#import "PTGApplicationManager.h"


@implementation Type

// Insert code here to add functionality to your managed object subclass

+ (Type*)createTypeWithTitle:(NSString*)title {
    
    PTGCoreDataManager *coreDataManager = [PTGApplicationManager sharedManager].coreDataManager;
    Type *type = [PTGCoreDataManager insertNewObjectForEntityForName:@"Type"
                                                    inManagedObjectContext:coreDataManager.masterManagedObjectContext];
    
    type.title = title;
    
    [coreDataManager save];
    
    return type;
}

@end