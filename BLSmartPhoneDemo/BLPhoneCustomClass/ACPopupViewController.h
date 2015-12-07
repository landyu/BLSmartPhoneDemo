//
//  ACPopupViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/2.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACPopupViewController : UIViewController
@property (weak) id delegate;
- (id)initWithItemDetailDict:(NSDictionary *)detailDict itemName:(NSString *)name;
@end


@protocol ACPopupViewControllerDelegate
@optional
- (void)ACPopupViewCancelButtonPressed;
@end