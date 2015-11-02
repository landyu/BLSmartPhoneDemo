//
//  BLSwitchCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLSwitchCell : UITableViewCell
- (void)setSwitchWithName:(NSString *)switchName detailDict:(NSDictionary *)detailDict;
- (void)readItemState;
@end
