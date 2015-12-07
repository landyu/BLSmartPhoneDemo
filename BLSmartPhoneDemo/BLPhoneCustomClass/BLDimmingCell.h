//
//  BLDimmingCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLDimmingCell : UITableViewCell
- (id)initWithParentViewController:(UIViewController *)parentViewController;
- (void)setSwitchWithName:(NSString *)itemName itemDetailDict:(NSDictionary *)detailDict;
@end
