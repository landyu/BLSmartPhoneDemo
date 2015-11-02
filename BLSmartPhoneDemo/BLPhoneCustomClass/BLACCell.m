//
//  BLACCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLACCell.h"
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

@interface BLACCell()
{
    NSDictionary *itemDetailDict;
    
    NSMutableDictionary *EnviromentTemperatureDict;
    NSMutableDictionary *SettingTemperatureDict;
    NSMutableDictionary *WindSpeedDict;
    NSMutableDictionary *ModeDict;
    NSMutableDictionary *OnOffDict;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
    
    NSMutableArray *ReadFromGroupAddressArray;
    NSMutableArray *WriteToGroupAddressArray;
    
    float senttingTemperatureFeedBackValue;
}
@property (strong, nonatomic) IBOutlet UILabel *ACNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *environmentTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *settingTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *onOffLabel;
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *windSpeedLabel;

- (IBAction)onOffButtonPressed:(UIButton *)sender;
- (IBAction)modeButtonPressed:(UIButton *)sender;
- (IBAction)windSpeedButtonPressed:(UIButton *)sender;
- (IBAction)settingTemperatureUpButtonPressed:(UIButton *)sender;
- (IBAction)settingTemperatureDownButtonPressed:(UIButton *)sender;

@end

@implementation BLACCell
@synthesize ACNameLabel;
@synthesize onOffLabel;
@synthesize modeLabel;
@synthesize windSpeedLabel;
@synthesize settingTemperatureLabel;
@synthesize environmentTemperatureLabel;

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLACCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        // any further initialization
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
        
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
        senttingTemperatureFeedBackValue = 15.0;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onOffButtonPressed:(UIButton *)sender
{
    NSInteger value = 0;
    if ([onOffLabel.text isEqualToString:@"开"])
    {
        value = 0;
    }
    else if ([onOffLabel.text isEqualToString:@"关"])
    {
        value = 1;
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kOnOff] value:value buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (IBAction)modeButtonPressed:(UIButton *)sender
{
    NSInteger value = 0;
    if ([modeLabel.text isEqualToString:@"除湿"])
    {
        value = [ModeDict[@"Cool"] integerValue];
    }
    else if ([modeLabel.text isEqualToString:@"通风"])
    {
        value = [ModeDict[@"Desiccation"] integerValue];
    }
    else if ([modeLabel.text isEqualToString:@"制热"])
    {
        value = [ModeDict[@"Vent"] integerValue];
    }
    else if ([modeLabel.text isEqualToString:@"制冷"])
    {
        value = [ModeDict[@"Heat"] integerValue];
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kMode] value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (IBAction)windSpeedButtonPressed:(UIButton *)sender
{
    NSInteger value = 0;
    if ([windSpeedLabel.text isEqualToString:@"高速"])
    {
        value = [WindSpeedDict[@"Auto"] integerValue];
    }
    else if ([windSpeedLabel.text isEqualToString:@"中速"])
    {
        value = [WindSpeedDict[@"High"] integerValue];
    }
    else if ([windSpeedLabel.text isEqualToString:@"低速"])
    {
        value = [WindSpeedDict[@"Mid"] integerValue];
    }
    else if ([windSpeedLabel.text isEqualToString:@"自动"])
    {
        value = [WindSpeedDict[@"Low"] integerValue];
    }
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kWindSpeed] value:value buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}

- (IBAction)settingTemperatureUpButtonPressed:(UIButton *)sender
{
    NSInteger sendSettingTemperature = senttingTemperatureFeedBackValue + 1;
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kSettingTemperature] value:sendSettingTemperature buttonName:nil valueLength:@"2Byte" commandType:@"Write"];
}

- (IBAction)settingTemperatureDownButtonPressed:(UIButton *)sender
{
    NSInteger sendSettingTemperature = senttingTemperatureFeedBackValue - 1;
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:WriteToGroupAddressArray[kSettingTemperature] value:sendSettingTemperature buttonName:nil valueLength:@"2Byte" commandType:@"Write"];
}

- (void)setACWithName:(NSString *)ACName detailDict:(NSDictionary *)detailDict
{
    ACNameLabel.text = ACName;
    itemDetailDict = detailDict;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];

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


- (void)acOnOffLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == 0)
                       {
                           onOffLabel.text = @"关";
                       }
                       else if(value == 1)
                       {
                           onOffLabel.text = @"开";
                       }
                   });
}

- (void)acModeLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == [[ModeDict objectForKey:@"Cool"] integerValue])
                       {
                           modeLabel.text = @"制冷";
                       }
                       else if(value == [[ModeDict objectForKey:@"Heat"] integerValue])
                       {
                           modeLabel.text = @"制热";
                       }
                       else if(value == [[ModeDict objectForKey:@"Vent"] integerValue])
                       {
                           modeLabel.text = @"通风";
                       }
                       else if(value == [[ModeDict objectForKey:@"Desiccation"] integerValue])
                       {
                           modeLabel.text = @"除湿";
                       }
                   });
}

- (void) acWindSpeedLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if (value == [[WindSpeedDict objectForKey:@"Auto"] integerValue])
                       {
                           windSpeedLabel.text = @"自动";
                       }
                       else if(value == [[WindSpeedDict objectForKey:@"Low"] integerValue])
                       {
                           windSpeedLabel.text = @"低速";
                       }
                       else if(value == [[WindSpeedDict objectForKey:@"Mid"] integerValue])
                       {
                           windSpeedLabel.text = @"中速";
                       }
                       else if(value == [[WindSpeedDict objectForKey:@"High"] integerValue])
                       {
                           windSpeedLabel.text = @"高速";
                       }
                   });

}

- (void) acSettingTemperatureLabelStatusUpdateWithValue:(NSInteger)value
{
    senttingTemperatureFeedBackValue = value;
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                      settingTemperatureLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
                   });
}

- (void) acEnvironmentTemperatureLabelStatusUpdateWithValue:(NSInteger)value
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       environmentTemperatureLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
                   });
}


@end
