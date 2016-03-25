//
//  DataFetcher.h
//  FoodShopTest
//
//  Created by rost on 23.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataFetcher : NSObject

+ (instancetype)shared;

- (NSArray *)fetchByEntity:(NSString *)title andPredicate:(NSString *)predicate;
- (void)saveObjects:(NSArray *)objects forEntity:(NSString *)entity;
- (void)saveValues:(id)values forEntity:(NSString *)entity byKeys:(NSArray *)keys;
- (void)deleteModelObject:(id)object;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
