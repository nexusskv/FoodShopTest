//
//  DataFetcher.m
//  FoodShopTest
//
//  Created by rost on 23.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "DataFetcher.h"
#import <CoreData/CoreData.h>
#import "Foods.h"
#import "Currency.h"
#import "Basket.h"
#import "Constants.h"


@interface DataFetcher ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end


@implementation DataFetcher

#pragma mark - Shared instance
+ (instancetype)shared {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}
#pragma mark -


#pragma mark - fetchByEntity:andPredicate:
- (NSArray *)fetchByEntity:(NSString *)title andPredicate:(NSString *)predicate {
    NSArray *valuesArray        = nil;
    NSArray *fetchedValues      = nil;
    NSError *fetchError         = nil;
    
    NSEntityDescription *fetchEntity    = [NSEntityDescription entityForName:title
                                                      inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *newRequest          = [[NSFetchRequest alloc] init];
    newRequest.entity                   = fetchEntity;
    newRequest.returnsDistinctResults   = YES;
    newRequest.includesPropertyValues   = YES;

    if (predicate) {
        [newRequest setPredicate:[NSPredicate predicateWithFormat:predicate]];
        
        fetchedValues = [self.managedObjectContext executeFetchRequest:newRequest error:&fetchError];
        
        if (fetchError)
            NSLog(@"Fetch values as dictionary error -> %@ ", fetchError.description);
    }
 
    if ([fetchedValues count] > 0)
        valuesArray = fetchedValues;
    
    return valuesArray;
}
#pragma mark -


#pragma mark - saveObjects:forEntity:
- (void)saveObjects:(NSArray *)objects forEntity:(NSString *)entity {
    
    for (NSDictionary *objectValues in objects) {
        [self saveValues:objectValues forEntity:entity byKeys:[objectValues allKeys]];
    }
}
#pragma mark -



#pragma mark - saveValues:forEntity:byKeys:
- (void)saveValues:(id)values forEntity:(NSString *)entity byKeys:(NSArray *)keys {
    id newObject = nil;
    
    NSString *fetchPredicate = [NSString stringWithFormat:@"title == '%@'", values[@"title"]];
    NSArray *existsCheckArray = [self fetchByEntity:entity andPredicate:fetchPredicate];
    
    if ([existsCheckArray count] > 0) {
        newObject = [existsCheckArray lastObject];
    } else {
        newObject = [self createEntityByClass:entity];
    }
    
    if (newObject) {
        for (NSString *key in keys) {
            [newObject setValue:values[key] forKey:key];
        }
        
        [self saveContext];
    }
}
#pragma mark -


#pragma mark - createEntityByClass:
- (id)createEntityByClass:(NSString *)title {
    NSEntityDescription *saveEntity = [NSEntityDescription entityForName:title
                                                  inManagedObjectContext:self.managedObjectContext];
    
    id newObject = [[NSClassFromString(title) alloc] initWithEntity:saveEntity
                                   insertIntoManagedObjectContext:self.managedObjectContext];
    
    return newObject;
}
#pragma mark -


#pragma mark - deleteModelObject:
- (void)deleteModelObject:(id)object {
    [self.managedObjectContext deleteObject:object];
    
    [self saveContext];
}
#pragma mark -


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.rost.FoodShopTest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FoodShopTest" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FoodShopTest.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
