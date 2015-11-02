//
//  BLSettingViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/31.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLSettingViewController.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "BLSettingData.h"
#import "GlobalMacro.h"

@interface BLSettingViewController ()
@property (strong, nonatomic) IBOutlet UITextField *deviceIpAddressText;
- (IBAction)deviceIpAddressTextEditingDidEnd:(UITextField *)sender;

@end

@implementation BLSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *ipAddress = [BLSettingData sharedSettingData].deviceIPAddress;
    self.deviceIpAddressText.text = ipAddress;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)deviceIpAddressTextEditingDidEnd:(UITextField *)sender
{
    [BLSettingData sharedSettingData].deviceIPAddress = sender.text;
    [[BLSettingData sharedSettingData] save];
    LogInfo(@"Editing Did End device ip = %@", sender.text);
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingSocketSharedInstance = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    if ([[tunnellingSocketSharedInstance serverIpAddress] isEqualToString:sender.text])
    {
        return;
    }
    [tunnellingSocketSharedInstance setTunnellingSocketWithClientBindToPort:0 deviceIpAddress:sender.text deviceIpPort:3671 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [tunnellingSocketSharedInstance tunnellingServeRestart];
}
@end
