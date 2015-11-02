//
//  BLACCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLACCell : UITableViewCell
- (void)setACWithName:(NSString *)ACName detailDict:(NSDictionary *)detailDict;
- (void)readItemState;
- (void)initPanelItemValue;
@end
