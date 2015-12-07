//
//  BLDimmingCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/24.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLDimmingCell.h"
#import "UIViewController+CWPopup.h"
#import "DimmingPopupViewController.h"

@interface BLDimmingCell ()
{
    UIViewController *parentVC;
    NSDictionary *itemDetailDict;
    NSString *cellName;
}
@property (strong, nonatomic) IBOutlet UIButton *labelButtonOutlet;

@end

@implementation BLDimmingCell

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
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLDimmingCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    // Example of a bigger switch with images
//    SevenSwitch *switchButton = [[SevenSwitch alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.frame.size.width * 0.75, self.frame.origin.y + self.frame.size.height * 0.1, 143 * 0.5, 52 * 0.5)];
//    //switchButton.center = CGPointMake(self.frame.size.width * 0.5 + self.frame.origin.x, self.frame.size.height * 0.5 - 80 + self.frame.origin.y);
//    [switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventValueChanged];
//    UIImage *image = [UIImage imageNamed: @"OffText.png"];
//    
//    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
//    BOOL hasAlpha = false;
//    CGFloat scale =  0.0; // Automatically use scale factor of main screen
//    
//    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
//    //image.drawInRect(CGRect(origin: CGPointZero, size: size));
//    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    
//    switchButton.offImage  = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    
//    
//    
//    //image = UIImage(named: "OnText.png");
//    image = [UIImage imageNamed: @"OnText.png"];
//    
//    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
//    hasAlpha = false;
//    
//    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
//    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    
//    switchButton.onImage  = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    
//    //mySwitch2.offImage = UIImage(named: "OffText.png")
//    //mySwitch2.onImage = UIImage(named: "OnText.png")
//    
//    
//    //image = UIImage(named: "SwitchButton.png");
//    image = [UIImage imageNamed: @"SwitchButton.png"];
//    
//    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
//    hasAlpha = true;
//    
//    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
//    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    
//    switchButton.thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //mySwitch2.thumbImage = UIImage(named: "SwitchButton")
//    //mySwitch2.thumbView.layer.cornerRadius =
//    //mySwitch2.thumbTintColor = UIColor.clearColor()
//    switchButton.backgroundColor = [UIColor blackColor];
//    switchButton.onTintColor = [UIColor blackColor];
//    switchButton.borderColor = [UIColor blackColor];
//    switchButton.layer.cornerRadius = 15;
//    [self addSubview:switchButton];
//    
//    // turn the switch on with animation
//    [switchButton setOn:YES animated:YES];
//    
//    
//    //////////////////////////////////////
//    
//    //滑块图片
//    image = [UIImage imageNamed:@"Slider"];
//    
//    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
//    hasAlpha = true;
//    
//    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
//    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    
//    UIImage *thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UISlider *sliderA=[[UISlider alloc]initWithFrame:CGRectMake(95, 44, 214, 31)];
//    sliderA.backgroundColor = [UIColor clearColor];
//    sliderA.value=128;
//    sliderA.minimumValue=0;
//    sliderA.maximumValue=255;
//    
//    //[sliderA setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
//    //[sliderA setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
//    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
//    [sliderA setThumbImage:thumbImage forState:UIControlStateHighlighted];
//    [sliderA setThumbImage:thumbImage forState:UIControlStateNormal];
//    //滑块拖动时的事件
//    //[sliderA addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//    //滑动拖动后的事件
//    [sliderA addTarget:self action:@selector(dimmingSliderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self addSubview:sliderA];
    
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

- (void)setSwitchWithName:(NSString *)itemName itemDetailDict:(NSDictionary *)detailDict
{
    itemDetailDict = detailDict;
    cellName = itemName;
    [_labelButtonOutlet setTitle:itemName forState:UIControlStateNormal];
}

- (void)switchButtonPressed:(UIButton *)sender
{
//    SamplePopupViewController *samplePopupViewController = [[SamplePopupViewController alloc] initWithNibName:@"SamplePopupViewController" bundle:nil];
//    samplePopupViewController.delegate = self;
//    [parentVC presentPopupViewController:samplePopupViewController animated:YES completion:^(void) {
//        NSLog(@"popup view presented");
//    }];
    
}


- (IBAction)dimmingLabelButtonPressed:(UIButton *)sender
{
    DimmingPopupViewController *dimmingPopupViewController = [[DimmingPopupViewController alloc] initWithItemDetailDict:itemDetailDict itemName:cellName];
    dimmingPopupViewController.delegate = self;
    [parentVC presentPopupViewController:dimmingPopupViewController animated:YES completion:^(void)
    {
    }];
}


- (void) dimmingPopupViewCancelButtonPressed
{
    if (parentVC.popupViewController != nil) {
        [parentVC dismissPopupViewControllerAnimated:YES completion:
         ^{
        }];
    }
}





@end
