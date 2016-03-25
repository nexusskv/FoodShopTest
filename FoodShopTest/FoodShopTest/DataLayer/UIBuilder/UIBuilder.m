//
//  UIBuilder.m
//  FoodShopTest
//
//  Created by rost on 23.03.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import "UIBuilder.h"
#import "Constants.h"


@interface UIBuilder ()

@end


@implementation UIBuilder

#pragma mark - View life cycle
- (void)loadView {
    [super loadView];

    self.navigationController.navigationBar.barTintColor = BACKGROUND_COLOR;
}
#pragma mark -


#pragma mark - initWithCallback:
- (id)initWithCallback:(UIBuilderCallback)block {
    if (self = [super init])
        self.callbackBlock = block;
    
    return self;
}
#pragma mark -


#pragma mark - createLabelWithText:withBG:andTextRightAlign:
- (UILabel *)createLabelWithText:(NSString *)text withBG:(UIColor *)color andTextRightAlign:(BOOL)align {
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    newLabel.textColor        = [UIColor blackColor];
    newLabel.font             = [UIFont fontWithName:@"Helvetica" size:16.0f];

    newLabel.lineBreakMode    = NSLineBreakByWordWrapping;
    newLabel.numberOfLines    = 1;
    newLabel.layer.cornerRadius  = 7;
    newLabel.layer.masksToBounds = YES;
    
    if (text)
        newLabel.text = text;
    
    if (color)
        newLabel.backgroundColor  = color;
    else
        newLabel.backgroundColor  = [UIColor clearColor];
    
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


#pragma mark - showAlert:
- (void)showAlert:(NSString *)text {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message"
                                                                             message:text
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
