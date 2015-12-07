//
//  BLSwitchCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLSwitchCell : UITableViewCell
//-(id)initWithPlistName:(NSString *)name indexInPlist:(NSString *)index;
-(id)initWithPlistName:(NSString *)name indexInPlist:(NSString *)index switchName:(NSString *)switchName detailDict:(NSDictionary *)detailDict;
-(id)initWithPlistName:(NSString *)name indexInPlist:(NSString *)index switchName:(NSString *)switchName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId;
- (void)readItemState;
@end
