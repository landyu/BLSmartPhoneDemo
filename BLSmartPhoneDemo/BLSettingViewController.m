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
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MyHTTPConnection.h"
#import "ZipArchive.h"
#include <ifaddrs.h>
#include <arpa/inet.h>


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface BLSettingViewController ()
{
    HTTPServer *httpServer;
}
@property (strong, nonatomic) IBOutlet UITextField *deviceIpAddressText;
@property (strong, nonatomic) IBOutlet UISwitch *configImportButtonOutlet;
- (IBAction)deviceIpAddressTextEditingDidEnd:(UITextField *)sender;
- (IBAction)configImportButtonPressed:(UISwitch *)sender;
- (IBAction)checkConfigFileButtonPressed:(UIButton *)sender;
- (IBAction)configFileUnzipButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *configFileSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *httpServerPortLabel;

@end

@implementation BLSettingViewController
@synthesize configImportButtonOutlet;
@synthesize configFileSizeLabel;
@synthesize httpServerPortLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    [configImportButtonOutlet setOn:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpServerStarted:) name:@"HTTPServerStarted" object:nil];
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

- (IBAction)configImportButtonPressed:(UISwitch *)sender
{
    
    if ([sender isOn])
    {
        LogInfo(@"ON");
        // Configure our logging framework.
        // To keep things simple and fast, we're just going to log to the Xcode console.
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Initalize our http server
        httpServer = [[HTTPServer alloc] init];
        
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        [httpServer setType:@"_http._tcp."];
        
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
        //	[httpServer setPort:12345];
        
        // Serve files from the standard Sites folder
        NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
        DDLogInfo(@"Setting document root: %@", docRoot);
        
        [httpServer setDocumentRoot:docRoot];
        
        [httpServer setConnectionClass:[MyHTTPConnection class]];
        
        NSError *error = nil;
        if(![httpServer start:&error])
        {
            DDLogError(@"Error starting HTTP Server: %@", error);
        }
    }
    else
    {
        LogInfo(@"OFF");
        [httpServer stop];
    }
}

- (IBAction)checkConfigFileButtonPressed:(UIButton *)sender
{
//    NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
//    NSString* uploadDirPath = [docRoot stringByAppendingPathComponent:@"upload"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString* uploadDirPath = [path stringByAppendingPathComponent:@"upload"];
    
    BOOL isDir = YES;
    configFileSizeLabel.text = @"0";
    if ([[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ])
    {
        LogInfo(@"find upload Directory...");
        NSString* configFilePath = [uploadDirPath stringByAppendingPathComponent:@"RoomInfo.zip"];
        isDir = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:configFilePath isDirectory:&isDir]){
            
            NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:configFilePath error:nil];
            
            // file size
            NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
            LogInfo(@"RoomInfo.zip    size  = %ld", (long)[theFileSize integerValue]);
            configFileSizeLabel.text = [NSString stringWithFormat:@"%ld", (long)[theFileSize integerValue]];
        }
    }
}

- (IBAction)configFileUnzipButtonPressed:(UIButton *)sender
{
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [paths objectAtIndex:0];
//    NSString *RoomInfoDirPath = [path stringByAppendingPathComponent:@"RoomInfo2"];
//    NSString *propertyConfigPath = [RoomInfoDirPath stringByAppendingPathComponent:@"PropertyConfig.plist"];
//    //NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSString *textString = [NSString stringWithContentsOfFile:propertyConfigPath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSLog(@"propertyConfig = %@", textString);

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString* uploadDirPath = [path stringByAppendingPathComponent:@"upload"];
    NSString* configFilePath = [uploadDirPath stringByAppendingPathComponent:@"RoomInfo.zip"];
    
    ZipArchive *za = [[ZipArchive alloc] init];
    // 1
    if ([za UnzipOpenFile: configFilePath]) {
        // 2
        BOOL ret = [za UnzipFileTo: path overWrite: YES];
        if (NO == ret)
        {
            
        }
        [za UnzipCloseFile];
        
        // 3
        NSString *RoomInfoDirPath = [path stringByAppendingPathComponent:@"RoomInfo"];
        NSString *propertyConfigPath = [RoomInfoDirPath stringByAppendingPathComponent:@"总经理办公室.plist"];
        //NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *textString = [NSString stringWithContentsOfFile:propertyConfigPath encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"总经理办公室 = %@", textString);
    }
}

- (void)httpServerStarted:(NSNotification *)notification
{
    NSDictionary *serverPort = [notification userInfo];
    //LogInfo(@"port = %@", [serverPort objectForKey:@"port"]);
    //httpServerPortLabel.text = [serverPort objectForKey:@"port"];
    httpServerPortLabel.text = [NSString stringWithFormat:@"%@:%@",[self getIPAddress], [serverPort objectForKey:@"port"]];
}

- (NSString *)getIPAddress
{
    
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    //LogInfo(@"local ip address = %@", address);
                    break;
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
@end
