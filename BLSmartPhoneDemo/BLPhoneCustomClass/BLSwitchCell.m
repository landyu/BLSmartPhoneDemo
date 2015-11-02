//
//  BLSwitchCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLSwitchCell.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface BLSwitchCell()
{
    NSDictionary *itemDetailDict;
    NSString *writeToGroupAddress;
    NSString *readFromGroupAddress;
    NSString *itemValueLength;
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
}
- (IBAction)switchButtonPressed:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *switchButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *switchNameLabel;
@end



@implementation BLSwitchCell
@synthesize switchButtonOutlet;
@synthesize switchNameLabel;
- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLSwitchCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        // any further initialization
        tunnellingShareInstance = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
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

- (void)setSwitchWithName:(NSString *)switchName detailDict:(NSDictionary *)detailDict
{
    switchNameLabel.text = switchName;
    itemDetailDict = detailDict;
    
    writeToGroupAddress = [itemDetailDict[@"WriteToGroupAddress"] objectForKey:@"0"];
    readFromGroupAddress = [itemDetailDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
    itemValueLength = [itemDetailDict objectForKey:@"ValueLength"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
}

- (void)readItemState
{
    if (readFromGroupAddress == nil)
    {
        return;
    }
    
    NSLog(@"ReadFromGroupAddress =  %@", readFromGroupAddress);
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:readFromGroupAddress value:0 buttonName:nil valueLength:itemValueLength commandType:@"Read"];
}

- (IBAction)switchButtonPressed:(UISwitch *)sender
{
    NSInteger transmitValue;
    
    if ([itemValueLength isEqualToString:@"1Bit"])
    {
        if ([sender isOn])
        {
            transmitValue = 1;
        }
        else
        {
            transmitValue = 0;
        }
    }
    else
    {
        return;
    }
    
    NSLog(@"WriteToGroupAddress =  %@, value = %ld", writeToGroupAddress, (long)transmitValue);
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeToGroupAddress value:transmitValue buttonName:nil valueLength:itemValueLength commandType:@"Write"];
    
    
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict[@"Address"] isEqualToString:readFromGroupAddress])
    {
        NSUInteger value = [dict[@"Value"] intValue];
        NSLog(@"receive value = %lu", (unsigned long)value);
        
        dispatch_async(dispatch_get_main_queue(),
        ^{
            if (value == 0)
            {
                [switchButtonOutlet setOn:NO animated:YES];
            }
            else if(value == 1)
            {
                [switchButtonOutlet setOn:YES animated:YES];
            }
        });
    }
}

- (void) tunnellingConnectSuccess
{
    [self readItemState];
}

@end
