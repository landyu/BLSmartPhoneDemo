//
//  BLHeatingCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLHeatingCell.h"
#import "UIViewController+CWPopup.h"
#import "HeatingPopupViewController.h"


@interface BLHeatingCell()
{
    NSDictionary *itemDetailDict;
    
    
    NSString *cellReuseIdentifier;
    UIViewController *parentVC;
    
    NSString *cellName;
}
@property (strong, nonatomic) IBOutlet UIButton *labelButtonOutlet;
@end

@implementation BLHeatingCell

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
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLHeatingCell" owner:self options:nil] objectAtIndex:0];
    
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

- (void)setHeatingWithName:(NSString *)heatingName detailDict:(NSDictionary *)detailDict
{
    //heatingNameLabel.text = heatingName;
    cellName = heatingName;
    [_labelButtonOutlet setTitle:cellName forState:UIControlStateNormal];
    itemDetailDict = detailDict;
    
}

- (void)setHeatingWithName:(NSString *)heatingName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId
{
    [self setHeatingWithName:heatingName detailDict:detailDict];
    cellReuseIdentifier = reuseId;
}

- (NSString *)reuseIdentifier
{
    return cellReuseIdentifier;
}



- (IBAction)heatingLabelButtonPressed:(UIButton *)sender
{
    HeatingPopupViewController *heatingPopupViewController = [[HeatingPopupViewController alloc] initWithItemDetailDict:itemDetailDict itemName:cellName];
    heatingPopupViewController.delegate = self;
    [parentVC presentPopupViewController:heatingPopupViewController animated:YES completion:^(void)
     {
     }];
}


- (void) heatingPopupViewCancelButtonPressed
{
    if (parentVC.popupViewController != nil) {
        [parentVC dismissPopupViewControllerAnimated:YES completion:
         ^{
         }];
    }
}




@end
