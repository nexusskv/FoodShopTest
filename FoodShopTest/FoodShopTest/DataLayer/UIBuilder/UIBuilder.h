//
//  UIBuilder.h
//  FoodShopTest
//
//  Created by rost on 23.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^UIBuilderCallback)(id);


@interface UIBuilder : UIViewController

@property (copy, nonatomic) UIBuilderCallback callbackBlock;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) UITableView *valuesTable;
@property (strong, nonatomic) id selectedObject;

- (id)initWithCallback:(UIBuilderCallback)block;

- (UILabel *)createLabelWithText:(NSString *)text withBG:(UIColor *)color andTextRightAlign:(BOOL)align;

- (void)addViews:(NSDictionary *)views toSuperview:(UIView *)superview withConstraints:(NSArray *)formats;

- (void)showAlert:(NSString *)text;

@end
