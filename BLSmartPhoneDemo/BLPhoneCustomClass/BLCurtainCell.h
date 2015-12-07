//
//  BLCurtainCell.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCurtainCell : UITableViewCell

- (id)initWithParentViewController:(UIViewController *)parentViewController;
- (void)setCurtainWithName:(NSString *)curtainName detailDict:(NSDictionary *)detailDict;
- (void)setCurtainWithName:(NSString *)curtainName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId;
//- (void)readItemState;
//- (void)initPanelItemValue;
@end
