//
//  Type.h
//  
//
//  Created by Petar Gezenchov on 19/02/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Expense;

NS_ASSUME_NONNULL_BEGIN

@interface Type : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (Type*)createTypeWithTitle:(NSString*)title;

@end

NS_ASSUME_NONNULL_END

#import "Type+CoreDataProperties.h"
