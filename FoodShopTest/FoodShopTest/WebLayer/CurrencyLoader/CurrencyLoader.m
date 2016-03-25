//
//  CurrencyLoader.m
//  FoodShopTest
//
//  Created by rost on 24.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "CurrencyLoader.h"
#import "Constants.h"


@implementation CurrencyLoader

#pragma mark - initWithCallback:
- (id)initWithCallback:(CurrencyLoaderCallback)block {
    if (self = [super init])
        self.callbackBlock = block;
    
    return self;
}
#pragma mark -


#pragma mark - loadCurrencies
- (void)loadCurrencies {
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@=%@", CURRENCY_API_URL, CURRENCY_API_KEY]];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *requestToApi = [NSMutableURLRequest requestWithURL:requestURL];
    requestToApi.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:requestToApi
                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                      
                      if ((data) && (data.length > 0)) {
                          NSError *jsonError = nil;
                          NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:NSJSONReadingMutableLeaves
                                                                                       error:&jsonError];
                          
                          if (!jsonObject) {
                              NSLog(@"Parsing JSON error: %@", jsonError);
                              self.callbackBlock(jsonError);
                          } else {
                              //NSLog(@"resp: %@ = %@",[jsonObject objectForKey:@"source"],[jsonObject objectForKey:@"quotes"]);
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                  NSDictionary *currenciesValues = [jsonObject objectForKey:@"quotes"];
                                  
                                  NSMutableArray *currenciesArray = [NSMutableArray array];
                                  
                                  for (NSString *keyValue in [currenciesValues allKeys]) {
                                      NSMutableString *currencyTitle = [NSMutableString stringWithString:keyValue];
                                      [currencyTitle insertString:@" to " atIndex:3];
                                      
                                      NSDictionary *currencyParams = @{@"title"     : currencyTitle,
                                                                       @"currency"  : currenciesValues[keyValue]};
                                      
                                      if ([[currencyParams allValues] count] > 0) {
                                          [currenciesArray addObject:currencyParams];
                                      }
                                  }
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self.callbackBlock(currenciesArray);
                                  });
                                  
                              });
                              
                              
                              
                          } // USDUSD = 1;
                          // USDEUR = "0.894454";
                      }
                  }];
    
    [dataTask resume];
}
#pragma mark -

@end
