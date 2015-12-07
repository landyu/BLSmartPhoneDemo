//
//  BLRemoteControllerCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLRemoteControllerCell : UITableViewCell
- (id)initWithParentNavigationController:(UINavigationController *)navigationController;
- (void)setRemoteControllerWithName:(NSString *)remoteControllerName detailDict:(NSDictionary *)detailDict;
- (void)setRemoteControllerWithName:(NSString *)remoteControllerName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId;
@end
