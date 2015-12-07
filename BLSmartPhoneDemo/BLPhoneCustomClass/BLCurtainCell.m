//
//  BLCurtainCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtainCell.h"
#import "GlobalMacro.h"
//#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "BLSmartPhoneDemo-Swift.h"
#import "CurtainPopupViewController.h"
#import "UIViewController+CWPopup.h"

//@interface Curtain : NSObject {
//@public
//    NSString *openCloseWriteToGroupAddress;
//    NSString *stopWriteToGroupAddress;
//    NSString *moveToPositionWriteToGroupAddress;
//    NSString *positionStatusReadFromGroupAddress;
//    NSUInteger curtainPosition;
//}
//- (id)init;
//@end
//
//@implementation Curtain
//
//- (id)init
//{
//    self = [super init];
//    return self;
//}
//
//@end

@interface BLCurtainCell()
{
    NSDictionary *itemDetailDict;
    Curtain *curtain;
    NSString *itemName;
    
    //BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    //NSMutableDictionary *overallRecevedKnxDataDict;
    NSString *cellReuseIdentifier;
    
    UIViewController *parentVC;
}
@property (strong, nonatomic) IBOutlet UIButton *curtainLabelButtonOutlet;

@end

@implementation BLCurtainCell

- (id)initWithParentViewController:(UIViewController *)parentViewController
{
    self = [self init];
    if (self)
    {
        parentVC = parentViewController;
    }
    return  self;
}

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLCurtainCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        // any further initialization
        curtain = [[Curtain alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIImage imageNamed:@"CellBackground"] drawInRect:self.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundColor = [UIColor clearColor];
    self.separatorInset = UIEdgeInsetsZero;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurtainWithName:(NSString *)curtainName detailDict:(NSDictionary *)detailDict
{
    //curtainNameLabel.text = curtainName;
    itemName = curtainName;
    [_curtainLabelButtonOutlet setTitle:curtainName forState:UIControlStateNormal];
    itemDetailDict = detailDict;
}

- (void)setCurtainWithName:(NSString *)curtainName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId
{
    [self setCurtainWithName:curtainName detailDict:detailDict];
    cellReuseIdentifier = reuseId;
}

- (NSString *)reuseIdentifier
{
    return cellReuseIdentifier;
}

- (IBAction)curtainLabelButtonPressed:(UIButton *)sender
{
    CurtainPopupViewController *curtainPopupViewController = [[CurtainPopupViewController alloc] initWithItemDetailDict:itemDetailDict itemName:itemName];
    curtainPopupViewController.delegate = self;
    [parentVC presentPopupViewController:curtainPopupViewController animated:YES completion:^(void)
     {
     }];
}


- (void) curtainPopupViewCancelButtonPressed
{
    if (parentVC.popupViewController != nil) {
        [parentVC dismissPopupViewControllerAnimated:YES completion:
         ^{
         }];
    }
}


@end
