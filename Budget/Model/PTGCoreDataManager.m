//
//  PTGCoreDataManager.m
//  Budget
//
//  Created by Petar Gezenchov on 19/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGCoreDataManager.h"

#import "NSFileManager+DoNotBackup.h"

@interface PTGCoreDataManager ()

@property (strong, nonatomic) NSManagedObjectModel          *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext        *masterManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext        *backgroundManagedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator  *persistentStoreCoordinator;

@end

@implementation PTGCoreDataManager

@synthesize masterManagedObjectContext      = _masterManagedObjectContext;
@synthesize backgroundManagedObjectContext  = _backgroundManagedObjectContext;
@synthesize managedObjectModel              = _managedObjectModel;
@synthesize persistentStoreCoordinator      = _persistentStoreCoordinator;

static NSString * const kDatabaseName       = @"Model.sqlite";

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data stack

+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

// Used to propegate saves to the persistent store (disk) without blocking the UI
- (NSManagedObjectContext *)masterManagedObjectContext
{
    if (_masterManagedObjectContext != nil) {
        return _masterManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_masterManagedObjectContext performBlockAndWait:^{
            [_masterManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
        
    }
    
    return _masterManagedObjectContext;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:masterContext];
        }];
    }
    
    return _backgroundManagedObjectContext;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)newManagedObjectContext {
    NSManagedObjectContext *newContext = nil;
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext != nil) {
        newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [newContext performBlockAndWait:^{
            [newContext setParentContext:masterContext];
        }];
    }
    
    return newContext;
}

- (void)save
{
    [self saveMasterContext];
    [self saveBackgroundContext];
}

- (void)saveMasterContext
{
    [self.masterManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.masterManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save master context due to %@", error);
        }
    }];
}

- (void)saveBackgroundContext {
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.backgroundManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save background context due to %@", error);
        }
    }];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Budget" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (void)copyDatabaseIfNeededToURL:(NSURL *)storeURL
{
    // If there’s no Data Store present (which is the case when the app first launches),
    // identify the sqlite file we added in the Bundle Resources, copy it into the Documents directory, and make it the Data Store.
    if(![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        [self copyDatabaseToURL:storeURL];
    }
}

- (void)copyDatabaseToURL:(NSURL *)storeURL
{
    NSError     *error      = nil;
    // from
    NSString    *sqlitePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseName];
    BOOL        success     = [[NSFileManager defaultManager] copyItemAtPath:sqlitePath toPath:[storeURL path] error:&error];
    if (success) {
        [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:storeURL];
    } else {
        NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSError                         *error          = nil;
    NSPersistentStoreCoordinator    *coordinator    = [self persistentStoreCoordinatorWithError:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return coordinator;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithError:(NSError **)error
{
    if (_persistentStoreCoordinator == nil) {
        @synchronized(self) {
            // This next block is useful when the store is initialized for the first time.  If the DB doesn't already
			// exist and a copy of the db (with the same name) exists in the bundle, it'll be copied over and used.  This
			// is useful for the initial seeding of data in the app.
            NSURL *storeURL = [self storeURL];
            [self copyDatabaseIfNeededToURL:storeURL];
            
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

            // For manual migration using a mapping model set NSInferMappingModelAutomaticallyOption to NO

            NSDictionary *options =  @{NSSQLitePragmasOption:@{@"journal_mode" : @"DELETE"},
                                       NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES] ,
                                       NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]};
            
            
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                                     URL:storeURL options:options error:error]) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                 Typical reasons for an error here include:
                 * The persistent store is not accessible;
                 * The schema for the persistent store is incompatible with current managed object model.
                 Check the error message to determine what the actual problem was.
                 
                 
                 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
                 
                 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
                 * Simply deleting the existing store:
                 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
                 
                 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
                 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
                 
                 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
                 
                 */
                NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
                abort();
            }
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the path to the application's Documents directory.
- (NSString *)applicationDocumentsDirectory
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
#if TARGET_IPHONE_SIMULATOR
    // where are you?
    NSLog(@"Documents Directory: %@", path);
#endif
    
    return path;
}

// Returns the data base name (with .sqlite extensions)
- (NSString *)databaseName
{
    return kDatabaseName;
}

// Returns the full path to the data base in the application's Documents directory.
- (NSString *)storePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self databaseName]];
}

// Returns full path as URL
- (NSURL *)storeURL
{
	return [NSURL fileURLWithPath:[self storePath]];
}

#pragma mark - Migration methods

- (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata
{
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]]
                                       forStoreMetadata:sourceMetadata];
}

- (NSArray *)modelPaths
{
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray  *modelPaths     = [NSMutableArray array];
    NSArray         *momdArray      = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
    
    for (NSString *momdPath in momdArray) {
        NSString    *resourceSubpath    = [momdPath lastPathComponent];
        NSArray     *array              = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    
    NSArray         *otherModels    = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    
    return modelPaths;
}

- (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel
                  modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error
{
    NSArray *modelPaths = [self modelPaths];
    if (!modelPaths.count) {
        // Throw an error if there are no models
        // TODO: customize
        if (NULL != error) {
            *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:@{ NSLocalizedDescriptionKey : @"No models found!" }];
        }
        return NO;
    }
    
    //See if we can find a matching destination model
    NSString                *modelPath  = nil;
    NSMappingModel          *mapping    = nil;
    NSManagedObjectModel    *model      = nil;
    
    for (modelPath in modelPaths) {
        model   = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]] forSourceModel:sourceModel destinationModel:model];
        
        //If we found a mapping model then proceed
        if (mapping) {
            break;
        }
    }
    
    //We have tested every model, if nil here we failed
    if (!mapping) {
        if (NULL != error) {
            // TODO: customize
            *error = [NSError errorWithDomain:@"Zarra" code:8001 userInfo:@{ NSLocalizedDescriptionKey : @"No mapping model found in bundle" }];
        }
        return NO;
    } else {
        *destinationModel   = model;
        *mappingModel       = mapping;
        *modelName          = modelPath.lastPathComponent.stringByDeletingPathExtension;
    }
    return YES;
}

- (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL
                                       modelName:(NSString *)modelName
{
    // We have a mapping model, time to migrate
    NSString    *storeExtension = sourceStoreURL.path.pathExtension;
    NSString    *storePath      = sourceStoreURL.path.stringByDeletingPathExtension;
    
    // Build a path to write the new store
    storePath                   = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}

- (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError **)error
{
    NSString        *guid           = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString        *backupPath     = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    
    NSFileManager   *fileManager    = [NSFileManager defaultManager];
    
    if (![fileManager moveItemAtPath:sourceStoreURL.path toPath:backupPath error:error]) {
        // Failed to copy the file
        return NO;
    }
    
    // Move the destination to the source path
    if (![fileManager moveItemAtPath:destinationStoreURL.path toPath:sourceStoreURL.path error:error]) {
        // Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath toPath:sourceStoreURL.path error:nil];
        // don't forget iCloud
        [fileManager addSkipBackupAttributeToItemAtURL:sourceStoreURL];
        return NO;
    }
    
    return YES;
}

@end

@implementation PTGCoreDataManager (Helper)

#pragma mark - Retrieve objects

// Fetch objects with a predicate
+ (NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate
                                andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending
                                andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
    
	NSFetchRequest      *request    = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity     = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = @[sortDescriptor];
		[request setSortDescriptors:sortDescriptors];
	}
    
	// Execute the fetch request
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
	// If the returned array was nil then there was an error
	if (mutableFetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
    
	// Return the results
	return mutableFetchResults;
}

// Fetch objects without a predicate
+ (NSMutableArray *)getObjectsForEntity:(NSString*)entityName
                            withSortKey:(NSString*)sortKey
                       andSortAscending:(BOOL)sortAscending
                             andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self searchObjectsForEntity:entityName
                          withPredicate:nil
                             andSortKey:sortKey
                       andSortAscending:sortAscending
                             andContext:managedObjectContext];
}

- (NSMutableArray *)searchObjectsForEntity:(NSString*)entityName
                             withPredicate:(NSPredicate *)predicate
                                andSortKey:(NSString*)sortKey
                          andSortAscending:(BOOL)sortAscending
{
    return [PTGCoreDataManager searchObjectsForEntity:entityName
                                        withPredicate:predicate
                                           andSortKey:sortKey
                                     andSortAscending:sortAscending
                                           andContext:self.masterManagedObjectContext];
}

- (NSMutableArray *)getObjectsForEntity:(NSString*)entityName
                            withSortKey:(NSString*)sortKey
                       andSortAscending:(BOOL)sortAscending
{
    return [PTGCoreDataManager getObjectsForEntity:entityName
                                       withSortKey:sortKey
                                  andSortAscending:sortAscending
                                        andContext:self.masterManagedObjectContext];
}

#pragma mark - Count objects

// Get a count for an entity with a predicate
+ (NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setIncludesPropertyValues:NO];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// Execute the count request
	NSError *error = nil;
	NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    
	// If the count returned NSNotFound there was an error
	if (count == NSNotFound)
		NSLog(@"Couldn't get count for entity %@", entityName);
    
	// Return the results
	return count;
}

// Get a count for an entity without a predicate
+ (NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self countForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

- (NSUInteger)countForEntity:(NSString *)entityName
{
    return [PTGCoreDataManager countForEntity:entityName
                                withPredicate:nil
                                   andContext:self.masterManagedObjectContext];
}
- (NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate
{
    return [PTGCoreDataManager countForEntity:entityName
                                withPredicate:predicate
                                   andContext:self.masterManagedObjectContext];
}

#pragma mark - Delete Objects

// Delete all objects for a given entity
+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
                       andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
    
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
    
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
	// Delete the objects returned if the results weren't nil
	if (fetchResults != nil) {
		for (NSManagedObject *manObj in fetchResults) {
			[managedObjectContext deleteObject:manObj];
		}
	} else {
		NSLog(@"Couldn't delete objects for entity %@", entityName);
		return NO;
	}
    
	return YES;
}

+ (BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self deleteAllObjectsForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

- (BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    return [PTGCoreDataManager deleteAllObjectsForEntity:entityName
                                           withPredicate:predicate
                                              andContext:self.masterManagedObjectContext];
}

- (BOOL)deleteAllObjectsForEntity:(NSString*)entityName
{
    return [PTGCoreDataManager deleteAllObjectsForEntity:entityName
                                           withPredicate:nil
                                              andContext:self.masterManagedObjectContext];
}

// we never set the last modified date ourselves, we rely on Parse to do it
+ (id)insertNewObjectForEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)context
{
    id object =  [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];

    return object;
}

- (id)insertNewObjectForEntityForName:(NSString *)entityName
{
    return [PTGCoreDataManager insertNewObjectForEntityForName:entityName
                                        inManagedObjectContext:self.masterManagedObjectContext];
}

- (id)insertObjectOnceForEntity:(NSString *)entityName
                      predicate:(NSPredicate *)predicate
                    firstAppear:(BOOL *)firstAppear
{
    NSManagedObject *object = [[self searchObjectsForEntity:entityName
                                              withPredicate:predicate
                                                 andSortKey:nil
                                           andSortAscending:YES]
                               firstObject];
    
    if (object != nil)
    {
        if (firstAppear)
        {
            *firstAppear = NO;
        }
        return object;
    }
    
    if (firstAppear)
    {
        *firstAppear = YES;
    }
    
    return [self insertNewObjectForEntityForName:entityName];
}

#pragma mark - Asynchronous requests

- (NSAsynchronousFetchRequest *)asyncFetchRequest:(NSFetchRequest *)fetchRequest
                                       completion:(void (^)(NSAsynchronousFetchResult *result))completion
{
    // Initialize Asynchronous Fetch Request
    NSAsynchronousFetchRequest *asynchronousFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest
                                                                                                    completionBlock:^(NSAsynchronousFetchResult *result)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (completion)
            {
                completion(result);
            }
        });
    }];
    
    // Execute Asynchronous Fetch Request
    [self.masterManagedObjectContext performBlock:^
    {
        // Execute Asynchronous Fetch Request
        NSError *asynchronousFetchRequestError = nil;
        [self.masterManagedObjectContext executeRequest:asynchronousFetchRequest
                                                  error:&asynchronousFetchRequestError];
        
        if (asynchronousFetchRequestError)
        {
            NSLog(@"Unable to execute asynchronous fetch result.");
            NSLog(@"%@, %@", asynchronousFetchRequestError, asynchronousFetchRequestError.localizedDescription);
        }
    }];
    
    return asynchronousFetchRequest;
}

@end