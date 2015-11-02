//
//  BLCurtainCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLCurtainCell.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface Curtain : NSObject {
@public
    NSString *openCloseWriteToGroupAddress;
    NSString *stopWriteToGroupAddress;
    NSString *moveToPositionWriteToGroupAddress;
    NSString *positionStatusReadFromGroupAddress;
    NSUInteger curtainPosition;
}
- (id)init;
@end

@implementation Curtain

- (id)init
{
    self = [super init];
    return self;
}

@end

@interface BLCurtainCell()
{
    NSDictionary *itemDetailDict;
    Curtain *curtain;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    NSMutableDictionary *overallRecevedKnxDataDict;
}
@property (strong, nonatomic) IBOutlet UILabel *curtainNameLabel;
@property (strong, nonatomic) IBOutlet UISlider *curtainSliderOutlet;
- (IBAction)curtainOpenButtonPressed:(UIButton *)sender;
- (IBAction)curtainCloseButtonPressed:(UIButton *)sender;
- (IBAction)curtainStopButtonPressed:(UIButton *)sender;
- (IBAction)curtainSliderButtonPressed:(UISlider *)sender;

@end

@implementation BLCurtainCell
@synthesize curtainNameLabel;
@synthesize curtainSliderOutlet;
- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLCurtainCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        // any further initialization
        curtain = [[Curtain alloc] init];
        tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
        overallRecevedKnxDataDict = tunnellingShareInstance.overallReceivedKnxDataDict;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurtainWithName:(NSString *)curtainName detailDict:(NSDictionary *)detailDict
{
    curtainNameLabel.text = curtainName;
    itemDetailDict = detailDict;
    [itemDetailDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"Curtain"])
         {
             NSDictionary *yarnCurtainDict = (NSDictionary *)obj;
             [yarnCurtainDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
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

- (IBAction)curtainOpenButtonPressed:(UIButton *)sender
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->openCloseWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (IBAction)curtainCloseButtonPressed:(UIButton *)sender
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->openCloseWriteToGroupAddress value:0 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (IBAction)curtainStopButtonPressed:(UIButton *)sender
{
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->stopWriteToGroupAddress value:1 buttonName:nil valueLength:@"1Bit" commandType:@"Write"];
}

- (IBAction)curtainSliderButtonPressed:(UISlider *)sender
{
    NSInteger sendValue = (NSInteger)sender.value;
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:curtain->moveToPositionWriteToGroupAddress value:sendValue buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
}


- (void)curtainPositionChangedWithValue:(NSUInteger)position
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       curtainSliderOutlet.value = position;
                   });
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
