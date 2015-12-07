//
//  CurtainPopupViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/2.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Curtain : NSObject {
@public
    NSString *openCloseWriteToGroupAddress;
    NSString *stopWriteToGroupAddress;
    NSString *moveToPositionWriteToGroupAddress;
    NSString *positionStatusReadFromGroupAddress;
    NSUInteger curtainPosition;
}
- (id)init;
@end


@interface CurtainPopupViewController : UIViewController
@property (weak) id delegate;

- (id)initWithItemDetailDict:(NSDictionary *)detailDict itemName:(NSString *)name;
@end


@protocol CurtainPopupViewControllerDelegate
@optional
- (void)curtainPopupViewCancelButtonPressed;
@end