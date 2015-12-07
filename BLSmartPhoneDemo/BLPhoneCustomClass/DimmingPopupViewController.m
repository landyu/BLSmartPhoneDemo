//
//  DimmingPopupViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/2.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "DimmingPopupViewController.h"
#import "BLSmartPhoneDemo-Swift.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface DimmingPopupViewController ()
{
    NSDictionary *itemDetailDict;
    NSString *popupViewName;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
    UISlider *dimmingSlider;
    SevenSwitch *switchButton;
}
@property (strong, nonatomic) IBOutlet UILabel *itemNameLabel;

@end

@implementation DimmingPopupViewController
@synthesize delegate;

- (id)initWithItemDetailDict:(NSDictionary *)detailDict itemName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        itemDetailDict = detailDict;
        popupViewName = name;
        
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
    
    
    switchButton = [[SevenSwitch alloc] initWithFrame:CGRectMake(140, 343, 143 * 0.7, 52 * 0.7)];
    //switchButton.center = CGPointMake(self.frame.size.width * 0.5 + self.frame.origin.x, self.frame.size.height * 0.5 - 80 + self.frame.origin.y);
    [switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventValueChanged];
    UIImage *image = [UIImage imageNamed: @"OffText.png"];

    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
    BOOL hasAlpha = false;
    CGFloat scale =  0.0; // Automatically use scale factor of main screen

    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    //image.drawInRect(CGRect(origin: CGPointZero, size: size));
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];

    switchButton.offImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();




    //image = UIImage(named: "OnText.png");
    image = [UIImage imageNamed: @"OnText.png"];

    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
    hasAlpha = false;

    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];

    switchButton.onImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


    //mySwitch2.offImage = UIImage(named: "OffText.png")
    //mySwitch2.onImage = UIImage(named: "OnText.png")


    //image = UIImage(named: "SwitchButton.png");
    image = [UIImage imageNamed: @"SwitchButton.png"];

    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
    hasAlpha = true;

    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];

    switchButton.thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //mySwitch2.thumbImage = UIImage(named: "SwitchButton")
    //mySwitch2.thumbView.layer.cornerRadius =
    //mySwitch2.thumbTintColor = UIColor.clearColor()
    switchButton.backgroundColor = [UIColor blackColor];
    switchButton.onTintColor = [UIColor blackColor];
    switchButton.borderColor = [UIColor blackColor];
    switchButton.layer.cornerRadius = 15;
    [self.view addSubview:switchButton];

    // turn the switch on with animation
    [switchButton setOn:YES animated:YES];


    //////////////////////////////////////

    //滑块图片
    image = [UIImage imageNamed:@"Slider"];

    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.7, 0.7));
    hasAlpha = true;

    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];

    UIImage *thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    dimmingSlider=[[UISlider alloc]initWithFrame:CGRectMake(71, 252, 214, 31)];
    dimmingSlider.backgroundColor = [UIColor clearColor];
    dimmingSlider.value=128;
    dimmingSlider.minimumValue=0;
    dimmingSlider.maximumValue=255;
    dimmingSlider.minimumTrackTintColor = [UIColor whiteColor];
    dimmingSlider.maximumTrackTintColor = [UIColor blackColor];

    //[sliderA setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    //[sliderA setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [dimmingSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [dimmingSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    //滑块拖动时的事件
    //[sliderA addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //滑动拖动后的事件
    [dimmingSlider addTarget:self action:@selector(dimmingSliderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:dimmingSlider];
    
    [self initPanelItemValue];
    [self readItemState];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _itemNameLabel.text = popupViewName;
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
    SEL selector = @selector(dimmingPopupViewCancelButtonPressed);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate dimmingPopupViewCancelButtonPressed];
    }
}

- (void)switchButtonPressed:(SevenSwitch *)sender
{
    NSDictionary *OnoffDict = [itemDetailDict objectForKey:@"OnOff"];
    NSString *writeGroupAddress = [[OnoffDict objectForKey:@"WriteToGroupAddress"] objectForKey:@"0"];
    NSLog(@"WriteGroupAddress = %@", writeGroupAddress);
    NSInteger sendValue = 0;
    if ([sender isOn])
    {
        sendValue = 1;
    }
    else
    {
        sendValue = 0;
    }

    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeGroupAddress value:sendValue buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (void)dimmingSliderButtonPressed:(UISlider *)sender
{
    NSDictionary *valueDict = [itemDetailDict objectForKey:@"Value"];
    NSString *writeGroupAddress = [[valueDict objectForKey:@"WriteToGroupAddress"] objectForKey:@"0"];
    NSLog(@"WriteGroupAddress = %@ Value = %ld", writeGroupAddress, (long)sender.value);
    NSInteger sendValue = (NSInteger)sender.value;
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeGroupAddress value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (void)readItemState
{
    
    NSDictionary *valueDict = [itemDetailDict objectForKey:@"Value"];
    NSString *readGroupAddress = [[valueDict objectForKey:@"ReadFromGroupAddress"] objectForKey:@"0"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:readGroupAddress value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    NSDictionary *OnoffDict = [itemDetailDict objectForKey:@"OnOff"];
    readGroupAddress = [[OnoffDict objectForKey:@"ReadFromGroupAddress"] objectForKey:@"0"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:readGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
}

- (void)initPanelItemValue
{
    if (overallRecevedKnxDataDict != nil)
    {
        NSDictionary *valueDict = [itemDetailDict objectForKey:@"Value"];
        NSString *readGroupAddress = [[valueDict objectForKey:@"ReadFromGroupAddress"] objectForKey:@"0"];
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:readGroupAddress];
        if (objectValue != nil)
        {
            [self dimmingPositionChangedWithValue:[objectValue integerValue]];
        }
        
        NSDictionary *OnoffDict = [itemDetailDict objectForKey:@"OnOff"];
        NSString *onoffReadFromGroupAddress = [[OnoffDict objectForKey:@"ReadFromGroupAddress"] objectForKey:@"0"];
        objectValue = [overallRecevedKnxDataDict objectForKey:onoffReadFromGroupAddress];
        if (objectValue != nil)
        {
            [self switchButtonStatusChangedWithValue:[objectValue integerValue]];
        }
    }
}

- (void)dimmingPositionChangedWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       dimmingSlider.value = value;
                   });
}

- (void)switchButtonStatusChangedWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == 0)
                       {
                           [switchButton setOn:NO animated:YES];
                       }
                       else if(value == 1)
                       {
                           [switchButton setOn:YES animated:YES];
                       }
                   });
}

//- (void) dimmingPopupViewCancelButtonPressed
//{
//    SEL selector = @selector(dimmingPopupViewCancelButtonPressed);
//    
//    if ([delegate respondsToSelector:selector])
//    {
//        [delegate dimmingPopupViewCancelButtonPressed];
//    }
//    //NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
//    //[appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
//}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    NSDictionary *OnoffDict = [itemDetailDict objectForKey:@"OnOff"];
    NSString *onoffReadFromGroupAddress = [[OnoffDict objectForKey:@"ReadFromGroupAddress"] objectForKey:@"0"];
    NSDictionary *valueDict = [itemDetailDict objectForKey:@"Value"];
    NSString *valueReadFromGroupAddress = [[valueDict objectForKey:@"ReadFromGroupAddress"] objectForKey:@"0"];
    if ([dict[@"Address"] isEqualToString:onoffReadFromGroupAddress])
    {
        NSUInteger value = [dict[@"Value"] intValue];
        NSLog(@"receive value = %lu", (unsigned long)value);
        
        [self switchButtonStatusChangedWithValue:value];
    }
    else if([dict[@"Address"] isEqualToString:valueReadFromGroupAddress])
    {
        NSUInteger value = [dict[@"Value"] intValue];
        NSLog(@"receive value = %lu", (unsigned long)value);
        [self dimmingPositionChangedWithValue:value];
    }
}

- (void) tunnellingConnectSuccess
{
    [self readItemState];
}

@end
