//
//  ACPopupViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/2.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "ACPopupViewController.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

enum ReadFromGroupAddressObject
{
    kOnOff = 0,
    kMode,
    kWindSpeed,
    kSettingTemperature,
    kEnviromentTemperature,
};


@interface ACPopupViewController ()
{
    NSDictionary *itemDetailDict;
    
    NSInteger settingTemperatureValue;
    NSInteger environmentTemperatureValue;
    
    NSMutableDictionary *EnviromentTemperatureDict;
    NSMutableDictionary *SettingTemperatureDict;
    NSMutableDictionary *WindSpeedDict;
    NSMutableDictionary *ModeDict;
    NSMutableDictionary *OnOffDict;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
    
    NSMutableArray *ReadFromGroupAddressArray;
    NSMutableArray *WriteToGroupAddressArray;
    
    float settingTemperatureFeedBackValue;
    NSString *popupViewName;
}
@property (strong, nonatomic) IBOutlet UILabel *popupViewLabel;
@property (strong, nonatomic) IBOutlet UILabel *environmentTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *settingTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (strong, nonatomic) IBOutlet UIButton *onOffButtonOutlet;
@end

@implementation ACPopupViewController
@synthesize delegate;

- (id)initWithItemDetailDict:(NSDictionary *)detailDict itemName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        itemDetailDict = detailDict;
        popupViewName = name;
        ReadFromGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSInteger i = 0; i < 5; ++i)
        {
            [ReadFromGroupAddressArray addObject:[NSNull null]];
        }
        WriteToGroupAddressArray = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSInteger i = 0; i < 5; ++i)
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
             else if([key isEqualToString:@"WindSpeed"])
             {
                 WindSpeedDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                 [ReadFromGroupAddressArray replaceObjectAtIndex:kWindSpeed withObject:[WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
                 [WriteToGroupAddressArray replaceObjectAtIndex:kWindSpeed withObject:[WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
                 //ReadFromGroupAddressArray[kWindSpeed] = [WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
                 //WriteToGroupAddressArray[kWindSpeed] = [WindSpeedDict[@"WriteToGroupAddress"] objectForKey:@"0"];
             }
             else if([key isEqualToString:@"Mode"])
             {
                 ModeDict = [[NSMutableDictionary alloc] initWithDictionary:obj];
                 [ReadFromGroupAddressArray replaceObjectAtIndex:kMode withObject:[ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
                 [WriteToGroupAddressArray replaceObjectAtIndex:kMode withObject:[ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"]];
                 //ReadFromGroupAddressArray[kMode] = [ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
                 //WriteToGroupAddressArray[kMode] = [ModeDict[@"WriteToGroupAddress"] objectForKey:@"0"];
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
    
    environmentTemperatureValue = settingTemperatureValue = 15;
    [_environmentTemperatureLabel setText:@"15"];
    [_settingTemperatureLabel setText:@"15"];
    
    UIImage *image = [UIImage imageNamed: @"BigButtonOff"];
    [_onOffButtonOutlet setBackgroundImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed: @"BigButtonOn"];
    [_onOffButtonOutlet setBackgroundImage:image forState:UIControlStateSelected];
    
}

- (void)viewWillAppear:(BOOL)animated
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
    SEL selector = @selector(ACPopupViewCancelButtonPressed);
    
    if ([delegate respondsToSelector:selector])
    {
        [delegate ACPopupViewCancelButtonPressed];
    }
}
- (IBAction)modeButtonPressed:(UIButton *)sender
{
    NSInteger value = 0;
    if ([_modeLabel.text isEqualToString:@"除湿"])
    {
        value = [ModeDict[@"Cool"] integerValue];
    }
    else if ([_modeLabel.text isEqualToString:@"通风"])
    {
        value = [ModeDict[@"Desiccation"] integerValue];
    }
    else if ([_modeLabel.text isEqualToString:@"制热"])
    {
        value = [ModeDict[@"Vent"] integerValue];
    }
    else if ([_modeLabel.text isEqualToString:@"制冷"])
    {
        value = [ModeDict[@"Heat"] integerValue];
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kMode] value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kMode] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
}
- (IBAction)windSpeedButtonPressed:(UIButton *)sender
{
    NSInteger value = 0;
    if ([_windSpeedLabel.text isEqualToString:@"高速"])
    {
        value = [WindSpeedDict[@"Auto"] integerValue];
    }
    else if ([_windSpeedLabel.text isEqualToString:@"中速"])
    {
        value = [WindSpeedDict[@"High"] integerValue];
    }
    else if ([_windSpeedLabel.text isEqualToString:@"低速"])
    {
        value = [WindSpeedDict[@"Mid"] integerValue];
    }
    else if ([_windSpeedLabel.text isEqualToString:@"自动"])
    {
        value = [WindSpeedDict[@"Low"] integerValue];
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kWindSpeed] value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kWindSpeed] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
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


- (void)readItemState
{
    
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kOnOff] value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kMode] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kWindSpeed] value:0 buttonName:nil valueLength:@"1Byte" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kSettingTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:ReadFromGroupAddressArray[kEnviromentTemperature] value:0 buttonName:nil valueLength:@"2Byte" commandType:@"Read"];
}

- (void)initPanelItemValue
{
    if (overallRecevedKnxDataDict != nil)
    {
        NSString *objectValue = [overallRecevedKnxDataDict objectForKey:[OnOffDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acOnOffLabelStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[WindSpeedDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acWindSpeedLabelStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[ModeDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acModeLabelStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[SettingTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acSettingTemperatureLabelStatusUpdateWithValue:[objectValue integerValue]];
        objectValue = [overallRecevedKnxDataDict objectForKey:[EnviromentTemperatureDict[@"ReadFromGroupAddress"] objectForKey:@"0"]];
        [self acEnvironmentTemperatureLabelStatusUpdateWithValue:[objectValue integerValue]];
    }
}

- (void)acOnOffLabelStatusUpdateWithValue:(NSInteger)value
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

- (void)acModeLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == [[ModeDict objectForKey:@"Cool"] integerValue])
                       {
                           _modeLabel.text = @"制冷";
                       }
                       else if(value == [[ModeDict objectForKey:@"Heat"] integerValue])
                       {
                           _modeLabel.text = @"制热";
                       }
                       else if(value == [[ModeDict objectForKey:@"Vent"] integerValue])
                       {
                           _modeLabel.text = @"通风";
                       }
                       else if(value == [[ModeDict objectForKey:@"Desiccation"] integerValue])
                       {
                           _modeLabel.text = @"除湿";
                       }
                   });
}

- (void) acWindSpeedLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == [[WindSpeedDict objectForKey:@"Auto"] integerValue])
                       {
                           _windSpeedLabel.text = @"自动";
                       }
                       else if(value == [[WindSpeedDict objectForKey:@"Low"] integerValue])
                       {
                           _windSpeedLabel.text = @"低速";
                       }
                       else if(value == [[WindSpeedDict objectForKey:@"Mid"] integerValue])
                       {
                           _windSpeedLabel.text = @"中速";
                       }
                       else if(value == [[WindSpeedDict objectForKey:@"High"] integerValue])
                       {
                           _windSpeedLabel.text = @"高速";
                       }
                   });
    
}

- (void) acSettingTemperatureLabelStatusUpdateWithValue:(NSInteger)value
{
    settingTemperatureFeedBackValue = value;
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       _settingTemperatureLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
                   });
}

- (void) acEnvironmentTemperatureLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       _environmentTemperatureLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
                   });
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
                [self acOnOffLabelStatusUpdateWithValue:value];
            }
            else if(index == kMode)
            {
                [self acModeLabelStatusUpdateWithValue:value];
            }
            else if(index == kWindSpeed)
            {
                [self acWindSpeedLabelStatusUpdateWithValue:value];
            }
            else if (index == kSettingTemperature)
            {
                [self acSettingTemperatureLabelStatusUpdateWithValue:value];
            }
            else if (index == kEnviromentTemperature)
            {
                [self acEnvironmentTemperatureLabelStatusUpdateWithValue:value];
            }
        }
    }
}

- (void) tunnellingConnectSuccess
{
    [self readItemState];
}

@end
