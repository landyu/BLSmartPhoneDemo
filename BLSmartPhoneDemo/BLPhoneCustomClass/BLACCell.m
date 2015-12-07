//
//  BLACCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLACCell.h"
#import "ACPopupViewController.h"
#import "UIViewController+CWPopup.h"



@interface BLACCell()
{
    NSDictionary *itemDetailDict;
    
    
    NSString *cellReuseIdentifier;
    UIViewController *parentVC;
    
    NSString *cellName;
}
@property (strong, nonatomic) IBOutlet UIButton *labelButtonOutlet;

@end

@implementation BLACCell

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
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLACCell" owner:self options:nil] objectAtIndex:0];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)setACWithName:(NSString *)ACName detailDict:(NSDictionary *)detailDict
{
    //ACNameLabel.text = ACName;
    cellName = ACName;
    [_labelButtonOutlet setTitle:cellName forState:UIControlStateNormal];
    itemDetailDict = detailDict;
    

}

- (void)setACWithName:(NSString *)ACName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId
{
    [self setACWithName:ACName detailDict:detailDict];
    cellReuseIdentifier = reuseId;
}

- (NSString *)reuseIdentifier
{
    return cellReuseIdentifier;
}

- (IBAction)ACLabelButtonPressed:(UIButton *)sender
{
    ACPopupViewController *acPopupViewController = [[ACPopupViewController alloc] initWithItemDetailDict:itemDetailDict itemName:cellName];
    acPopupViewController.delegate = self;
    [parentVC presentPopupViewController:acPopupViewController animated:YES completion:^(void)
     {
     }];
}


- (void) ACPopupViewCancelButtonPressed
{
    if (parentVC.popupViewController != nil) {
        [parentVC dismissPopupViewControllerAnimated:YES completion:
         ^{
         }];
    }
}



@end
