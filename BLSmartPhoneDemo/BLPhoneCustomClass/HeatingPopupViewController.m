//
//  HeatingPopupViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/2.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "HeatingPopupViewController.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

enum ReadFromGroupAddressObject
{
    kOnOff = 0,
    kSettingTemperature,
    kEnviromentTemperature,
};

@interface HeatingPopupViewController ()
{
    NSInteger settingTemperatureValue;
    NSInteger environmentTemperatureValue;
    NSDictionary *itemDetailDict;
    NSString *popupViewName;
    
    float settingTemperatureFeedBackValue;
    
    NSDictionary *EnviromentTemperatureDict;
    NSDictionary *SettingTemperatureDict;
    NSDictionary *OnOffDict;
    
    NSMutableArray *ReadFromGroupAddressArray;
    NSMutableArray *WriteToGroupAddressArray;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@property (strong, nonatomic) IBOutlet UILabel *popupViewLabel;
@property (strong, nonatomic) IBOutlet UILabel *environmentTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *settingTemperatureLabel;
@property (strong, nonatomic) IBOutlet UIButton *onOffButtonOutlet;
@end

@implementation HeatingPopupViewController
@synthesize delegate;
- (id)initWithItemDetailDict:(NSDictionary *)detailDict itemName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        itemDetailDict = detailDict;
        popupViewName = name;
        
        ReadFromGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (NSInteger i = 0; i < 3; ++i)
        {
            [ReadFromGroupAddressArray addObject:[NSNull null]];
        }
        WriteToGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (NSInteger i = 0; i < 3; ++i)
        {
            [WriteToGroupAddressArray addObject:[NSNull null]];
        }
        
        [itemDetailDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"EnviromentTemperature"])
             {
                 EnviromentTemperatureDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                 [ReadFromGroupAddressArray replaceObjectAtIndex:kEnviromentTemperature withObject:[EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
                 //[WriteToGroupAddressArray replaceObjectAtIndex:kEnviromentTemperature withObject:[EnviromentTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
                 //ReadFromGroupAddressArray[kEnviromentTemperature] = [EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
                 //WriteToGroupAddressArray[kEnviromentTemperature] = [EnviromentTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"];
             }
             else if([key isEqualToString:@"SettingTemperature"])
             {
                 SettingTemperatureDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                 [ReadFromGroupAddressArray replaceObjectAtIndex:kSettingTemperature withObject:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
                 [WriteToGroupAddressArray replaceObjectAtIndex:kSettingTemperature withObject:[SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
                 //ReadFromGroupAddressArray[kSettingTemperature] = [SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
                 //WriteToGroupAddressArray[kSettingTemperature] = [SettingTemperatureDict[@"WriteToGroupAddress"] objectForKey:@"0"];
             }
             else if([key isEqualToString:@"OnOff"])
             {
                 OnOffDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                 [ReadFromGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
                 [WriteToGroupAddressArray replaceObjectAtIndex:kOnOff withObject:[OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
                 //ReadFromGroupAddressArray[kOnOff] = [OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
                 //WriteToGroupAddressArray[kOnOff] = [OnOffDict[@"WriteToGroupAddress"] objectForKey:@"0"];
             }
         }];
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
        
        [self initPanelItemValue];
        [self readItemState];
        
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
    
    _popupViewLabel.text = popupViewName;
    
    environmentTemperatureValue = settingTemperatureValue = 15;
    [_environmentTemperatureLabel setText:@"15"];
    [_settingTemperatureLabel setText:@"15"];
    
    UIImage *image = [UIImage imageNamed: @"BigButtonOff"];
    [_onOffButtonOutlet setBackgroundImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed: @"BigButtonOn"];
    [_onOffButtonOutlet setBackgroundImage:image forState:UIControlStateSelected];
    
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

- (void)readItemState
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kEnviromentTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
}

- (void)initPanelItemValue
{
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self heatingOnOffButtonStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self heatingSettingTemperatureLabelStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self heatingEnvironmentTemperatureLabelStatusUpdateWithValue:[objectValue integerValue]];
    }
}

- (void)heatingOnOffButtonStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == 0)
                       {
                           [_onOffButtonOutlet setSelected:NO];
                       }
                       else if(value == 1)
                       {
                           [_onOffButtonOutlet setSelected:YES];
                       }
                   });
}

- (void) heatingSettingTemperatureLabelStatusUpdateWithValue:(NSInteger)value
{
    settingTemperatureFeedBackValue = value;
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       _settingTemperatureLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
                   });
}

- (void) heatingEnvironmentTemperatureLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       _environmentTemperatureLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
                   });
}

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    SEL selector = @selector(heatingPopupViewCancelButtonPressed);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate heatingPopupViewCancelButtonPressed];
    }
}
- (IBAction)onOffButtonPressed:(UIButton *)sender
{
    NSUInteger value = 0;
    if (sender.selected == YES)
    {
        value = 0;
    }
    else
    {
        value = 1;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kOnOff] value:value buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
}
- (IBAction)settingTemperatureDownButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = settingTemperatureFeedBackValue - 1;
    if (sendSettingTemperature < 15)
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kSettingTemperature] value:sendSettingTemperature buttonName:nil valueLength:@"2Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
}

- (IBAction)settingTemperatureUpButton:(UIButton *)sender
{
    NSInteger sendSettingTemperature = settingTemperatureFeedBackValue + 1;
    if (sendSettingTemperature > 35)
    {
        return;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kSettingTemperature] value:sendSettingTemperature buttonName:nil valueLength:@"2Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    
    for (NSUInteger index = 0; index < [ReadFromGroupAddressArray count]; index++)
    {
        if ([dict[@"Address"] isEqualToString:ReadFromGroupAddressArray[index]])
        {
            NSUInteger value = [dict[@"Value"] intValue];
            
            if (index == kOnOff)
            {
                [self heatingOnOffButtonStatusUpdateWithValue:value];
            }
            else if (index == kSettingTemperature)
            {
                [self heatingSettingTemperatureLabelStatusUpdateWithValue:value];
            }
            else if (index == kEnviromentTemperature)
            {
                [self heatingEnvironmentTemperatureLabelStatusUpdateWithValue:value];
            }
        }
    }
}

- (void) tunnellingConnectSuccess
{
    [self readItemState];
}
@end
