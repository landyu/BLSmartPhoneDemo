//
//  BLACCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLACCell : UITableViewCell
- (id)initWithParentViewController:(UIViewController *)parentViewController;
- (void)setACWithName:(NSString *)ACName detailDict:(NSDictionary *)detailDict;
- (void)setACWithName:(NSString *)ACName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId;
@end
