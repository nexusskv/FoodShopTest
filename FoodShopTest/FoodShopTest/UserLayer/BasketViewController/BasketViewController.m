//
//  BasketViewController.m
//  FoodShopTest
//
//  Created by rost on 23.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "BasketViewController.h"
#import "AddItemViewController.h"
#import "PopoverViewController.h"
#import "WYPopoverController.h"
#import "CurrencyLoader.h"
#import "Constants.h"
#import "DataFetcher.h"
#import "CustomBasketCell.h"
#import "SVProgressHUD.h"


@interface BasketViewController () <UITableViewDelegate, UITableViewDataSource, WYPopoverControllerDelegate>
@property (strong, nonatomic) id selectedCurrency;
@property (strong, nonatomic) WYPopoverController *popoverController;
@end


@implementation BasketViewController


#pragma mark - View life cycle
- (void)loadView {
    [super loadView];

    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 44.0f)];
    titleImageView.contentMode  = UIViewContentModeScaleAspectFit;
    titleImageView.image = [UIImage imageNamed:@"basket_logo"];
    self.navigationItem.titleView = titleImageView;

    
    NSArray *checkExistsFoods = [[DataFetcher shared] fetchByEntity:FOODS_ENTITY andPredicate:@"title != '0'"];
    if ([checkExistsFoods count] == 0) {
        [self saveFoodsExamples];
    }
    
    [self refreshBasketTable];
    

    UIButton *currencyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    currencyButton.frame     = CGRectMake(0.0f, 0.0f, 42.0f, 42.0f);
    currencyButton.tag       = CURRENCY_ITEM_TAG;
    [currencyButton setImage:[UIImage imageNamed:@"currency_logo"] forState:UIControlStateNormal];
    [currencyButton setImage:[UIImage imageNamed:@"currency_logo_tapped"] forState:UIControlStateHighlighted];
    [currencyButton addTarget:self action:@selector(buttonsSelector:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *currencyItem = [[UIBarButtonItem alloc] initWithCustomView:currencyButton];
    self.navigationItem.leftBarButtonItem = currencyItem;
    
    UIBarButtonItem *addFoodItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self
                                                                                 action:@selector(buttonsSelector:)];
    addFoodItem.tag = ADD_FOOD_ITEM_TAG;
    self.navigationItem.rightBarButtonItem = addFoodItem;
    
    
    self.valuesTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.valuesTable.delegate            = self;
    self.valuesTable.dataSource          = self;
    self.valuesTable.backgroundColor     = BACKGROUND_COLOR;
    self.valuesTable.separatorStyle      = UITableViewCellSeparatorStyleSingleLine;
    self.valuesTable.tableFooterView     = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([self.valuesTable respondsToSelector:@selector(setSeparatorInset:)])
        [self.valuesTable setSeparatorInset:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    
    NSDictionary *subViews = @{@"valuesTable"    : self.valuesTable};
    
    NSArray *subViewsFormats = @[@"H:|[valuesTable]|",
                                 @"V:|[valuesTable]|" ];
    
    [self addViews:subViews toSuperview:self.view withConstraints:subViewsFormats];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BACKGROUND_COLOR;
}
#pragma mark -


#pragma mark - buttonsSelector:
- (void)buttonsSelector:(id)sender {
    UIButton *tappedButton = (UIButton *)sender;

    switch (tappedButton.tag) {
        case CURRENCY_ITEM_TAG: {
            [SVProgressHUD show];
            [self refreshCurrencies];
        }
            break;
            
        case ADD_FOOD_ITEM_TAG: {
            AddItemViewController *addItemVC = [[AddItemViewController alloc] initWithCallback:^(id resultObject) {
                if ([resultObject boolValue] == YES) {
                    [self refreshBasketTable];
                }
            }];
            
            addItemVC.title = @"Add New Food Item";
            
            [self.navigationController pushViewController:addItemVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark -


#pragma mark - refreshCurrencies
- (void)refreshCurrencies {
    CurrencyLoader *currencyLoader = [[CurrencyLoader alloc] initWithCallback:^(id currencyObject) {
        [[DataFetcher shared] saveObjects:currencyObject forEntity:CURRENCY_ENTITY];
        
        [SVProgressHUD dismiss];
        
        PopoverViewController *currenciesPopover = [[PopoverViewController alloc] initWithCallback:^(id resultObject) {
            if (resultObject) {
                self.selectedCurrency = resultObject;
                
                [self popoverControllerDidDismissPopover:_popoverController];
                
                [self.valuesTable reloadData];
            }
        }];
        
        currenciesPopover.modalInPopover = NO;
        
        if ([currenciesPopover respondsToSelector:@selector(setPreferredContentSize:)]) {
            currenciesPopover.preferredContentSize = CGSizeMake(275.0f, 300.0f);
        }
        
        _popoverController = [[WYPopoverController alloc] initWithContentViewController:currenciesPopover];
        _popoverController.delegate = self;
        _popoverController.wantsDefaultContentAppearance = NO;
        _popoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 0, 0, 3);
        
        WYPopoverTheme *popoverTheme    = _popoverController.theme;
        popoverTheme.overlayColor       = [UIColor clearColor];
        popoverTheme.arrowBase          = 6.0f;
        popoverTheme.arrowHeight        = 6.0f;
        popoverTheme.tintColor          = CUSTOM_GRAY_COLOR;
        popoverTheme.outerStrokeColor   = CUSTOM_GRAY_COLOR;
        popoverTheme.fillTopColor       = CUSTOM_GRAY_COLOR;
        popoverTheme.fillBottomColor    = CUSTOM_GRAY_COLOR;
        
        _popoverController.theme = popoverTheme;
        
        UIBarButtonItem *leftItem = [self.navigationItem.leftBarButtonItems lastObject];
        UIView *currencyView = [leftItem valueForKey:@"view"];
        
        [_popoverController presentPopoverFromRect:currencyView.bounds
                                            inView:currencyView
                          permittedArrowDirections:WYPopoverArrowDirectionUp
                                          animated:YES];
    }];
    
    [currencyLoader loadCurrencies];
}
#pragma mark -


#pragma mark - createBasketItemsArray
- (void)refreshBasketTable {
    self.dataArray = [[DataFetcher shared] fetchByEntity:BASKET_ENTITY andPredicate:@"title != '0'"];
    
    if ([self.dataArray count] > 0)
        [self.valuesTable reloadData];
}
#pragma mark -


#pragma mark - saveFoodsExamples
- (void)saveFoodsExamples {
    NSArray *foodsExamples = @[@{@"title"               : @"Peas",
                                 @"price"               : @(0.95),
                                 @"quantity_details"    : @"Bag"
                                 },
                               @{@"title"               : @"Eggs",
                                 @"price"               : @(2.10),
                                 @"quantity_details"    : @"Dozen"
                                 },
                               @{@"title"               : @"Milk",
                                 @"price"               : @(1.30),
                                 @"quantity_details"    : @"Bottle"
                                 },
                               @{@"title"               : @"Beans",
                                 @"price"               : @(1.30),
                                 @"quantity_details"    : @"Can"
                                 },
                               @{@"title"               : @"Apples",
                                 @"price"               : @(0.50),
                                 @"quantity_details"    : @"Package"
                                 },
                               @{@"title"               : @"Pine",
                                 @"price"               : @(1.75),
                                 @"quantity_details"    : @"A piece"
                                 },
                               @{@"title"               : @"Vine",
                                 @"price"               : @(20.10),
                                 @"quantity_details"    : @"Bottle"
                                 },
                               @{@"title"               : @"Cherry juice",
                                 @"price"               : @(5.65),
                                 @"quantity_details"    : @"Bottle"
                                 },
                               @{@"title"               : @"Grapefruit juice",
                                 @"price"               : @(7.05),
                                 @"quantity_details"    : @"Bottle"
                                 },
                               @{@"title"               : @"Potato",
                                 @"price"               : @(3.35),
                                 @"quantity_details"    : @"Bag"
                                 },
                               @{@"title"               : @"Chocolate",
                                 @"price"               : @(3.35),
                                 @"quantity_details"    : @"A piece"
                                 },
                               ];

    [[DataFetcher shared] saveObjects:foodsExamples forEntity:FOODS_ENTITY];
}
#pragma mark -


#pragma mark - TableView dataSource & delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(CustomBasketCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id currencyObject           = self.dataArray[indexPath.row];
    NSString *titleValue        = [currencyObject valueForKey:@"title"];
    NSNumber *quantityValue     = [currencyObject valueForKey:@"quantity"];
    NSString *quantityDetails   = [currencyObject valueForKey:@"quantity_details"];
    
    cell.customTitleLabel.text = titleValue;
    cell.quantityLabel.text    = [NSString stringWithFormat:@"%d %@", [quantityValue intValue], quantityDetails];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    CustomBasketCell *cell = (CustomBasketCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell     = [[CustomBasketCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor  = LIGHT_ORANGE_COLOR;
        cell.backgroundView     = bgView;
        cell.backgroundColor    = LIGHT_ORANGE_COLOR;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.dataArray count] > 0.0f) {
        return 80.0f;
    } else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.dataArray count] > 0) {
        UIView *footerView = [[UIView alloc] init];
        footerView.backgroundColor = CUSTOM_GRAY_COLOR;
        
        CGFloat currencyValue    = 1.0f;     // DEFAULT CURRENCY IS USD
        NSString *currencyTitle  = @"USD";
        if (self.selectedCurrency) {
            currencyValue = [[self.selectedCurrency valueForKey:@"currency"] floatValue];
            NSString *currencyString = [NSString stringWithFormat:@"%.2f", currencyValue];
            currencyValue = [currencyString floatValue];
            currencyTitle = [self.selectedCurrency valueForKey:@"title"];
        }
        
        CGFloat totalBasket = 0.0f;
        for (id basketObject in self.dataArray) {
            NSUInteger quantityFood = [[basketObject valueForKey:@"quantity"] intValue];
            CGFloat priceFood       = [[basketObject valueForKey:@"price"] floatValue];
            
            totalBasket += (quantityFood * priceFood);
        }
        
        totalBasket = (totalBasket * currencyValue);
        
        UILabel *totalLabel    = [self createLabelWithText:[NSString stringWithFormat:@"Total count: %.2f", totalBasket]
                                                    withBG:nil
                                         andTextRightAlign:YES];

        currencyTitle = [NSString stringWithFormat:@"Selected currency: %@ - %.2f", currencyTitle, currencyValue];
        UILabel *currencyLabel = [self createLabelWithText:currencyTitle
                                                       withBG:nil
                                            andTextRightAlign:YES];

        
        NSDictionary *viewsList = @{@"totalLabel"       : totalLabel,
                                    @"currencyLabel"    : currencyLabel};
        
        NSArray *formatArray = @[@"H:|-(10)-[totalLabel]-(10)-|",
                                 @"H:|-(10)-[currencyLabel]-(10)-|",
                                 @"V:[totalLabel(20)]-(45)-|",
                                 @"V:[currencyLabel(20)]-(15)-|"];
        
        [self addViews:viewsList toSuperview:footerView withConstraints:formatArray];
        
        return footerView;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddItemViewController *editItemVC = [[AddItemViewController alloc] initWithCallback:^(id resultObject) {
        if ([resultObject boolValue] == YES) {
            [self refreshBasketTable];
        }
    }];

    editItemVC.title            = @"Edit selected item";
    editItemVC.selectedObject   = self.dataArray[indexPath.row];
    
    [self.navigationController pushViewController:editItemVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [[DataFetcher shared] deleteModelObject:self.dataArray[indexPath.row]];
        
        [self refreshBasketTable];
    }
    
    [tableView endUpdates];
}
#pragma mark -


#pragma mark - showPopoverFromObject:byType:andContent:
- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    [controller dismissPopoverAnimated:YES];
    controller.delegate = nil;
    controller = nil;
}
#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
