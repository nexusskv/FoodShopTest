//
//  CustomBasketCell.m
//  FoodShopTest
//
//  Created by rost on 25.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "CustomBasketCell.h"

@implementation CustomBasketCell

#pragma mark - Constructor
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.customTitleLabel = [self createLabelWithText:nil andTextRightAlign:NO];
        self.quantityLabel    = [self createLabelWithText:nil andTextRightAlign:YES];
        
        NSDictionary *viewsValues = @{@"customTitleLabel"   : self.customTitleLabel,
                                      @"quantityLabel"      : self.quantityLabel};
        
        NSArray *subViewsFormats = @[@"H:|-(10)-[customTitleLabel]-[quantityLabel]-(10)-|",
                                     @"V:|-(15)-[customTitleLabel(20)]-(15)-|",
                                     @"V:|-(15)-[quantityLabel(20)]-(15)-|"];
        
        [self addViews:viewsValues toSuperview:self withConstraints:subViewsFormats];
    }
    
    return self;    
}
#pragma mark - 


#pragma mark - createLabelWithText:andTextRightAlign:
- (UILabel *)createLabelWithText:(NSString *)text  andTextRightAlign:(BOOL)align {
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.textColor        = [UIColor blackColor];
    newLabel.font             = [UIFont fontWithName:@"Helvetica" size:16.0f];
    newLabel.backgroundColor  = [UIColor clearColor];
    newLabel.lineBreakMode    = NSLineBreakByWordWrapping;
    newLabel.numberOfLines    = 1;
    newLabel.layer.cornerRadius  = 7;
    newLabel.layer.masksToBounds = YES;
    
    if (text)
        newLabel.text = text;

    if (align)
        newLabel.textAlignment    = NSTextAlignmentRight;
    else
        newLabel.textAlignment    = NSTextAlignmentLeft;
    
    return newLabel;
}
#pragma mark -


#pragma mark - addViews:toSuperview:withConstraints:
- (void)addViews:(NSDictionary *)views toSuperview:(UIView *)superview withConstraints:(NSArray *)formats {
    for (UIView *view in views.allValues) {
        [superview addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    for (NSString *formatString in formats) {
        [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views]];
    }
}
#pragma mark -


@end
