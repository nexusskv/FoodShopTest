//
//  CurrencyLoader.h
//  FoodShopTest
//
//  Created by rost on 24.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^CurrencyLoaderCallback)(id);


@interface CurrencyLoader : NSObject

@property (nonatomic, copy) CurrencyLoaderCallback callbackBlock;

- (id)initWithCallback:(CurrencyLoaderCallback)block;
- (void)loadCurrencies;

@end
