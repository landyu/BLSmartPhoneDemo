//
//  CurtainPopupViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/2.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "CurtainPopupViewController.h"
#import "BLSmartPhoneDemo-Swift.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"


@implementation Curtain

- (id)init
{
    self = [super init];
    return self;
}

@end

@interface CurtainPopupViewController ()
{
    Curtain *curtain;
    NSDictionary *itemDetailDict;
    NSString *popupViewName;
    UISlider *curtainSlider;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@property (strong, nonatomic) IBOutlet UILabel *popupViewLabel;
@end

@implementation CurtainPopupViewController
@synthesize delegate;

- (id)initWithItemDetailDict:(NSDictionary *)detailDict itemName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        itemDetailDict = detailDict;
        popupViewName = name;
        curtain = [[Curtain alloc] init];
        
        [itemDetailDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"Curtain"])
             {
                 NSDictionary *curtainDict = (NSDictionary *)obj;
                 [curtainDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                  {
                      if ([key isEqualToString:@"OpenClose"])
                      {
                          curtain->openCloseWriteToGroupAddress = (NSString *)obj;
                      }
                      else if ([key isEqualToString:@"Stop"])
                      {
                          curtain->stopWriteToGroupAddress = (NSString *)obj;
                      }
                      else if ([key isEqualToString:@"MoveToPosition"])
                      {
                          curtain->moveToPositionWriteToGroupAddress = (NSString *)obj;
                      }
                      else if ([key isEqualToString:@"StatusHeight"])
                      {
                          curtain->positionStatusReadFromGroupAddress = (NSString *)obj;
                      }
                  }];
             }
         }];
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [[UIImage imageNamed:@"CellBackground"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    // Example of a bigger switch with images
        SevenSwitch *openButton = [[SevenSwitch alloc] initWithFrame:CGRectMake(10, 343, 143 * 0.7, 52 * 0.7)];
        //switchButton.center = CGPointMake(self.frame.size.width * 0.5 + self.frame.origin.x, self.frame.size.height * 0.5 - 80 + self.frame.origin.y);
        [openButton addTarget:self action:@selector(curtainOpenButtonPressed:) forControlEvents:UIControlEventValueChanged];
        UIImage *image = [UIImage imageNamed: @"OnText"];
    
        CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        BOOL hasAlpha = false;
        CGFloat scale =  0.0; // Automatically use scale factor of main screen
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        //image.drawInRect(CGRect(origin: CGPointZero, size: size));
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        openButton.onImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
    
    
        image = [UIImage imageNamed: @"OnText"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = false;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        openButton.offImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        //mySwitch2.offImage = UIImage(named: "OffText.png")
        //mySwitch2.onImage = UIImage(named: "OnText.png")
    
    
        //image = UIImage(named: "SwitchButton.png");
        image = [UIImage imageNamed: @"SwitchButton"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = true;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        openButton.thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
    
        //mySwitch2.thumbImage = UIImage(named: "SwitchButton")
        //mySwitch2.thumbView.layer.cornerRadius =
        //mySwitch2.thumbTintColor = UIColor.clearColor()
        openButton.backgroundColor = [UIColor blackColor];
        openButton.onTintColor = [UIColor blackColor];
        openButton.borderColor = [UIColor blackColor];
        openButton.layer.cornerRadius = 15;
        [self.view addSubview:openButton];
    
        // turn the switch on with animation
        [openButton setOn:YES animated:YES];
    
    
    
    
        ///////////////////////////////
    
        SevenSwitch *stopButton = [[SevenSwitch alloc] initWithFrame:CGRectMake(140, 343, 143 * 0.7, 52 * 0.7)];
        //switchButton.center = CGPointMake(self.frame.size.width * 0.5 + self.frame.origin.x, self.frame.size.height * 0.5 - 80 + self.frame.origin.y);
        [stopButton addTarget:self action:@selector(curtainStopButtonPressed:) forControlEvents:UIControlEventValueChanged];
        image = [UIImage imageNamed: @"StopText"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = false;
        scale =  0.0; // Automatically use scale factor of main screen
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        //image.drawInRect(CGRect(origin: CGPointZero, size: size));
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        stopButton.onImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
    
        image = [UIImage imageNamed: @"StopText"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = false;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        stopButton.offImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        //mySwitch2.offImage = UIImage(named: "OffText.png")
        //mySwitch2.onImage = UIImage(named: "OnText.png")
    
    
        //image = UIImage(named: "SwitchButton.png");
        image = [UIImage imageNamed: @"SwitchButton"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = true;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        stopButton.thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        //mySwitch2.thumbImage = UIImage(named: "SwitchButton")
        //mySwitch2.thumbView.layer.cornerRadius =
        //mySwitch2.thumbTintColor = UIColor.clearColor()
        stopButton.backgroundColor = [UIColor blackColor];
        stopButton.onTintColor = [UIColor blackColor];
        stopButton.borderColor = [UIColor blackColor];
        stopButton.layer.cornerRadius = 15;
        [self.view addSubview:stopButton];
    
        // turn the switch on with animation
        [stopButton setOn:YES animated:YES];
    
    
        ///////////////////////////////
    
        SevenSwitch *closeButton = [[SevenSwitch alloc] initWithFrame:CGRectMake(260, 343, 143 * 0.7, 52 * 0.7)];
        //switchButton.center = CGPointMake(self.frame.size.width * 0.5 + self.frame.origin.x, self.frame.size.height * 0.5 - 80 + self.frame.origin.y);
        [closeButton addTarget:self action:@selector(curtainCloseButtonPressed:) forControlEvents:UIControlEventValueChanged];
        image = [UIImage imageNamed: @"OffText"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = false;
        scale =  0.0; // Automatically use scale factor of main screen
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        //image.drawInRect(CGRect(origin: CGPointZero, size: size));
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        closeButton.onImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
    
        image = [UIImage imageNamed: @"OffText"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = false;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        closeButton.offImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        //mySwitch2.offImage = UIImage(named: "OffText.png")
        //mySwitch2.onImage = UIImage(named: "OnText.png")
    
    
        //image = UIImage(named: "SwitchButton.png");
        image = [UIImage imageNamed: @"SwitchButton"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = true;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        closeButton.thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        //mySwitch2.thumbImage = UIImage(named: "SwitchButton")
        //mySwitch2.thumbView.layer.cornerRadius =
        //mySwitch2.thumbTintColor = UIColor.clearColor()
        closeButton.backgroundColor = [UIColor blackColor];
        closeButton.onTintColor = [UIColor blackColor];
        closeButton.borderColor = [UIColor blackColor];
        closeButton.layer.cornerRadius = 15;
        [self.view addSubview:closeButton];
    
        // turn the switch on with animation
        [closeButton setOn:YES animated:YES];
    
    
    
        //滑块图片
        image = [UIImage imageNamed:@"Slider"];
    
        size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
        hasAlpha = true;
    
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
        UIImage *thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        curtainSlider = [[UISlider alloc]initWithFrame:CGRectMake(71, 252, 214, 31)];
        curtainSlider.backgroundColor = [UIColor clearColor];
        curtainSlider.value=128;
        curtainSlider.minimumValue=0;
        curtainSlider.maximumValue=255;
        curtainSlider.minimumTrackTintColor = [UIColor blackColor];
        curtainSlider.maximumTrackTintColor = [UIColor whiteColor];
        
        //[sliderA setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        //[sliderA setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
        [curtainSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
        [curtainSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        //滑块拖动时的事件
        //[sliderA addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        //滑动拖动后的事件
        [curtainSlider addTarget:self action:@selector(curtainSliderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:curtainSlider];
        [self initPanelItemValue];
        [self readItemState];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _popupViewLabel.text = popupViewName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    SEL selector = @selector(curtainPopupViewCancelButtonPressed);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate curtainPopupViewCancelButtonPressed];
    }
}

- (void) curtainOpenButtonPressed:(UIButton *)sender
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->openCloseWriteToGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void) curtainStopButtonPressed:(UIButton *)sender
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->stopWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void) curtainCloseButtonPressed:(UIButton *)sender
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->openCloseWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void) curtainSliderButtonPressed:(UISlider *)sender
{
    //NSLog(@"WriteGroupAddress = %@ Value = %ld", curtain->moveToPositionWriteToGroupAddress, (long)sender.value);
    NSInteger sendValue = (NSInteger)sender.value;
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (void)curtainPositionChangedWithValue:(NSUInteger)position
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       curtainSlider.value = position;
                   });
}

- (void)readItemState
{
    
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->positionStatusReadFromGroupAddress value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
}

- (void)initPanelItemValue
{
        if (overallRecevedKnxDataDict != nil)
        {
            NSString *objectValue = [overallRecevedKnxDataDict objectForKey:curtain->positionStatusReadFromGroupAddress];
            [self curtainPositionChangedWithValue:[objectValue integerValue]];
        }
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict[@"Address"] isEqualToString:curtain->positionStatusReadFromGroupAddress])
    {
        NSUInteger value = [dict[@"Value"] intValue];
        //NSLog(@"receive value = %lu", (unsigned long)value);
        
        [self curtainPositionChangedWithValue:value];
    }
}

- (void) tunnellingConnectSuccess
{
    [self readItemState];
}

@end
