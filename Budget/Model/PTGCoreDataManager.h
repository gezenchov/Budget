//
//  PTGCoreDataManager.h
//  Budget
//
//  Created by Petar Gezenchov on 19/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); [__obj isKindOfClass:[NSNull class]] ? nil : obj; })

@interface PTGCoreDataManager : NSObject


- (NSURL *)storeURL;
- (NSString *)storePath;
- (NSString *)databaseName;
- (NSString *)applicationDocumentsDirectory;

- (void)copyDatabaseToURL:(NSURL *)storeURL;
- (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError **)error;

- (NSManagedObjectContext *)newManagedObjectContext;
- (NSManagedObjectContext *)masterManagedObjectContext;
- (NSManagedObjectContext *)backgroundManagedObjectContext;

- (void)save;
- (void)saveMasterContext;
- (void)saveBackgroundContext;

- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@interface PTGCoreDataManager (Helper)


// For retrieval of objects
+ (NSMutableArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext;

- (NSMutableArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending;
- (NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending;

// For deletion of objects
+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext;

- (BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;
- (BOOL)deleteAllObjectsForEntity:(NSString*)entityName;

// For counting objects
+ (NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext;

- (NSUInteger)countForEntity:(NSString *)entityName;
- (NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

// Insert objects
+ (id)insertNewObjectForEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context;

- (id)insertNewObjectForEntityForName:(NSString *)entityName;
- (id)insertObjectOnceForEntity:(NSString *)entityName
                      predicate:(NSPredicate *)predicate
                    firstAppear:(BOOL *)firstAppear;

// Async Fetch Request
- (NSAsynchronousFetchRequest *)asyncFetchRequest:(NSFetchRequest *)fetchRequest
                                       completion:(void (^)(NSAsynchronousFetchResult *result))completion;

@end
