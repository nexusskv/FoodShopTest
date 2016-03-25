//
//  AddItemViewController.m
//  FoodShopTest
//
//  Created by rost on 23.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "AddItemViewController.h"
#import "Constants.h"
#import "DataFetcher.h"


@interface AddItemViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) UILabel *foodValueLabel;
@property (strong, nonatomic) UILabel *quantityValueLabel;
@property (strong, nonatomic) NSArray *quantityArray;
@property (strong, nonatomic) id createdFoodItem;
@end


@implementation AddItemViewController

#pragma mark - View life cycle
- (void)loadView {
    [super loadView];
    
    self.dataArray = [[DataFetcher shared] fetchByEntity:FOODS_ENTITY andPredicate:@"title != '0'"];
    
    NSMutableArray *foodsValues = [NSMutableArray arrayWithArray:self.dataArray];
    [foodsValues sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    self.dataArray = foodsValues;
    
    NSMutableArray *quantityTempValues = [NSMutableArray array];
    for (int i = 1; i < 101; i++) {
        [quantityTempValues addObject:@(i)];
    }
    
    self.quantityArray = quantityTempValues;


    UIBarButtonItem *saveFoodItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                  target:self
                                                                                  action:@selector(buttonsSelector:)];
    saveFoodItem.tag                        = SAVE_FOOD_ITEM_TAG;
    self.navigationItem.rightBarButtonItem  = saveFoodItem;
    
    
    UILabel *foodTitleLabel     = [self createLabelWithText:@"Food title" withBG:nil andTextRightAlign:NO];
    UILabel *quantityTitleLabel = [self createLabelWithText:@"Quantity" withBG:nil andTextRightAlign:NO];
    
    UIPickerView *foodsPicker = [[UIPickerView alloc] init];
    foodsPicker.backgroundColor = [UIColor whiteColor];
    foodsPicker.dataSource = self;
    foodsPicker.delegate   = self;
    foodsPicker.showsSelectionIndicator = YES;
    
    
    NSString *foodTitle      = nil;
    NSString *quantityValue  = nil;
    
    if (self.selectedObject) {
        NSString *fetchPredicate = [NSString stringWithFormat:@"title == '%@'", [self.selectedObject valueForKey:@"title"]];
        id selectedObject        = [[[DataFetcher shared] fetchByEntity:BASKET_ENTITY andPredicate:fetchPredicate] lastObject];
        NSNumber *quantityNumber = [selectedObject valueForKey:@"quantity"];
        foodTitle                = [selectedObject valueForKey:@"title"];
        quantityValue            = [NSString stringWithFormat:@"%@", quantityNumber];
        
        [self.dataArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            if ([[self.selectedObject valueForKey:@"title"] isEqualToString:[object valueForKey:@"title"]]) {
                [foodsPicker selectRow:idx inComponent:0 animated:YES];
            }
        }];
        
        [self.quantityArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            if ([[self.selectedObject valueForKey:@"quantity"] intValue] == [object intValue])
                [foodsPicker selectRow:idx inComponent:1 animated:YES];
        }];
    }
    
    self.foodValueLabel      = [self createLabelWithText:foodTitle withBG:[UIColor whiteColor] andTextRightAlign:YES];
    self.quantityValueLabel  = [self createLabelWithText:quantityValue withBG:[UIColor whiteColor] andTextRightAlign:YES];
    
    UILabel *foodsListLabel      = [self createLabelWithText:@"Foods list" withBG:nil andTextRightAlign:NO];
    UILabel *quantitiesListLabel = [self createLabelWithText:@"List of quantities" withBG:nil andTextRightAlign:YES];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    
    UIView *pickerTitlesView = [[UIView alloc] init];
    NSDictionary *viewsObjects = @{@"foodsListLabel"        : foodsListLabel,
                                   @"quantitiesListLabel"   : quantitiesListLabel};
    
    NSArray *formatArray = @[@"H:|-(20)-[foodsListLabel]-[quantitiesListLabel]-(20)-|",
                             @"V:|[foodsListLabel]|",
                             @"V:|[quantitiesListLabel]|"];
    
    [self addViews:viewsObjects toSuperview:pickerTitlesView withConstraints:formatArray];
    
    
    viewsObjects = @{@"foodTitleLabel"        : foodTitleLabel,
                     @"quantityTitleLabel"    : quantityTitleLabel,
                     @"foodValueLabel"        : self.foodValueLabel,
                     @"quantityValueLabel"    : self.quantityValueLabel,
                     @"lineView"              : lineView,
                     @"pickerTitlesView"      : pickerTitlesView,
                     @"foodsPicker"           : foodsPicker};
    
    formatArray = @[@"H:|-(10)-[foodTitleLabel(70)]-(30)-[foodValueLabel]-(10)-|",
                    @"H:|-(10)-[quantityTitleLabel(70)]",
                    @"H:[quantityValueLabel(80)]-(10)-|",
                    @"H:|[foodsPicker]|",
                    @"H:|-(10)-[lineView]-(10)-|",
                    @"H:|[pickerTitlesView]|",
                    @"V:|-(100)-[foodTitleLabel(30)]-(30)-[quantityTitleLabel(30)]",
                    @"V:|-(100)-[foodValueLabel(30)]-(30)-[quantityValueLabel(30)]-(25)-[lineView(1)]",
                    @"V:[foodsPicker(300)]-(1)-|",
                    @"V:[pickerTitlesView(20)]-(270)-|"];
    
    [self addViews:viewsObjects toSuperview:self.view withConstraints:formatArray];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BACKGROUND_COLOR;
}
#pragma mark - View life cycle


#pragma mark - buttonsSelector:
- (void)buttonsSelector:(id)sender {
    UIButton *tappedButton = (UIButton *)sender;
    
    switch (tappedButton.tag) {
        case SAVE_FOOD_ITEM_TAG: {
            if (self.foodValueLabel.text.length == 0) {
                [self showAlert:@"Please select some food item."];
                return;
            }
            
            if (self.quantityValueLabel.text.length == 0) {
                [self showAlert:@"Please set count for selected food item."];
                return;
            }

            
            if (!self.createdFoodItem) {
                self.createdFoodItem = self.selectedObject;
            }
            
            NSString *titleValue    = [self.createdFoodItem valueForKey:@"title"];
            NSNumber *priceValue    = [self.createdFoodItem valueForKey:@"price"];
            NSString *detailsValue  = [self.createdFoodItem valueForKey:@"quantity_details"];
                
            
            NSDictionary *saveValues = @{@"title"               : titleValue,
                                         @"price"               : priceValue,
                                         @"quantity"            : @([self.quantityValueLabel.text intValue]),
                                         @"quantity_details"    : detailsValue};
            
            [[DataFetcher shared] saveValues:saveValues forEntity:BASKET_ENTITY byKeys:[saveValues allKeys]];
            
            self.callbackBlock(@(YES));
            
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark -


#pragma mark Picker Data Source Methods and Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [self.dataArray count];
            break;
        case 1:
            return [self.quantityArray count];
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return (self.view.bounds.size.width / 2.0f);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            id foodObject = self.dataArray[row];
            NSString *titleValue = [foodObject valueForKey:@"title"];
            return titleValue;
        }
            break;
        case 1: {
            NSString *quantityValue = [NSString stringWithFormat:@"%@", self.quantityArray[row]];
            return quantityValue;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
        switch (component) {
            case 0: {
                self.createdFoodItem     = self.dataArray[row];
                self.foodValueLabel.text = [self.createdFoodItem valueForKey:@"title"];
            }
                break;
                
            case 1: {
                NSString *quantityValue       = [NSString stringWithFormat:@"%@", self.quantityArray[row]];
                self.quantityValueLabel.text  = quantityValue;
            }
                break;
                
            default:
                break;
        }

}
#pragma mark -


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
