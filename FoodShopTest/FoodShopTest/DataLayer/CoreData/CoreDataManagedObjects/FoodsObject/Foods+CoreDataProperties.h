//
//  Foods+CoreDataProperties.h
//  FoodShopTest
//
//  Created by rost on 24.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Foods.h"

NS_ASSUME_NONNULL_BEGIN

@interface Foods (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *price;
@property (nullable, nonatomic, retain) NSString *quantity_details;

@end

NS_ASSUME_NONNULL_END
