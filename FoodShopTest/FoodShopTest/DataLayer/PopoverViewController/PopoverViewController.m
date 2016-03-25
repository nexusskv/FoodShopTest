//
//  PopoverViewController.m
//  FoodShopTest
//
//  Created by rost on 24.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "PopoverViewController.h"
#import "DataFetcher.h"
#import "Constants.h"


@interface PopoverViewController () <UITableViewDelegate, UITableViewDataSource>

@end


@implementation PopoverViewController

#pragma mark - View life cycle
- (void)loadView {
    [super loadView];

    self.dataArray = [[DataFetcher shared] fetchByEntity:CURRENCY_ENTITY andPredicate:@"title != '0'"];
    
    NSMutableArray *currenciesValues = [NSMutableArray arrayWithArray:self.dataArray];
    [currenciesValues sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    self.dataArray = currenciesValues;
    
    self.valuesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.valuesTable.delegate            = self;
    self.valuesTable.dataSource          = self;
    self.valuesTable.backgroundColor     = CUSTOM_GRAY_COLOR;
    self.valuesTable.separatorStyle      = UITableViewCellSeparatorStyleSingleLine;
    self.valuesTable.tableFooterView     = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([self.valuesTable respondsToSelector:@selector(setSeparatorInset:)])
        [self.valuesTable setSeparatorInset:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    
    NSArray *subViewsFormats = @[@"H:|[valuesTable]|",
                                 @"V:|[valuesTable]|" ];
    
    [self addViews:@{@"valuesTable" : self.valuesTable} toSuperview:self.view withConstraints:subViewsFormats];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor   = CUSTOM_GRAY_COLOR;
}
#pragma mark -


#pragma mark - TableView dataSource & delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id currencyObject       = self.dataArray[indexPath.row];
    NSString *titleValue    = [currencyObject valueForKey:@"title"];
    NSNumber *currencyValue = [currencyObject valueForKey:@"currency"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ \t - \t %.2f", titleValue, [currencyValue doubleValue]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell     = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor  = CUSTOM_GRAY_COLOR;
        cell.backgroundView     = bgView;
        cell.backgroundColor    = CUSTOM_GRAY_COLOR;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.callbackBlock(self.dataArray[indexPath.row]);
}
#pragma mark -

@end
