//
//  BLHeatingCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLHeatingCell : UITableViewCell
- (id)initWithParentViewController:(UIViewController *)parentViewController;
- (void)setHeatingWithName:(NSString *)heatingName detailDict:(NSDictionary *)detailDict;
- (void)setHeatingWithName:(NSString *)heatingName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId;
@end
