//
//  ItemsViewController.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/20.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Scene : NSObject {
@public
    NSString *sceneName;
    UIButton *button;
    NSDictionary *buttonInfoDict;
}
- (id)init;
@end

@interface ItemsViewController : UIViewController <UIGestureRecognizerDelegate>

@end
