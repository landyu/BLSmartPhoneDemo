//
//  AppDelegate.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/20.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BLSettingViewController.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "BLSettingData.h"
#import "LikeItemsViewController.h"
#import "LikeItems.h"
#import "ConfigFileProcess.h"

@interface AppDelegate ()
{
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    ConfigFileProcess *configFileProcess;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    configFileProcess = [[ConfigFileProcess alloc] init];
    
   
    
    BLSettingViewController *settingViewController = [[BLSettingViewController alloc] init];
    UIImage* anImage = [UIImage imageNamed:@"Icon_Profile"];
    settingViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:anImage tag:2];
    
    LikeItemsViewController *likeItemsViewController = [[LikeItemsViewController alloc] init];
    anImage = [UIImage imageNamed:@"常用功能"];
    likeItemsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"个人收藏" image:anImage tag:2];
    
    UINavigationController *BLPhoneNavigationController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc]init]];
    anImage = [UIImage imageNamed:@"Icon_Home"];
    BLPhoneNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"佰凌智能" image:anImage tag:0];
    BLPhoneNavigationController.navigationBar.titleTextAttributes = @{
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      };
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    UIGraphicsBeginImageContext([BLPhoneNavigationController navigationBar].bounds.size);
    [[UIImage imageNamed:@"NavigationBarBackground"] drawInRect:[BLPhoneNavigationController navigationBar].bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[BLPhoneNavigationController navigationBar] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    
    NSArray *viewControllers = [NSArray arrayWithObjects:BLPhoneNavigationController, likeItemsViewController, settingViewController,nil];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = viewControllers;
    
    UITabBar *tabBar = [tabBarController tabBar];
    
    UIGraphicsBeginImageContext(tabBar.bounds.size);
    [[UIImage imageNamed:@"TabBarBackground"] drawInRect:tabBar.bounds];
    backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [tabBar setBackgroundImage:backgroundImage];
    [tabBarController.view setNeedsDisplay];
    
    //tabBarController.view.alpha = 0.7;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    //self.window.backgroundColor = [UIColor blackColor];
    
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Balloon"]];
    self.window.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [tunnellingShareInstance tunnellingServeStop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[BLSettingData sharedSettingData].likeItemsArray = [[LikeItems sharedInstance] getLikeItemsArrayWithArray];
    if ([LikeItems sharedInstance]->likeItemsNeedToOverWrite == YES)
    {
        [[BLSettingData sharedSettingData] save];
        [LikeItems sharedInstance]->likeItemsNeedToOverWrite = NO;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSMutableArray *likeItemsArray = [BLSettingData sharedSettingData].likeItemsArray;
    [[LikeItems sharedInstance] setLikeItemsArrayWithArray:likeItemsArray];
    tunnellingShareInstance = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    NSString *ipAddress = [BLSettingData sharedSettingData].deviceIPAddress;
    if (ipAddress)
    {
        [tunnellingShareInstance setTunnellingSocketWithClientBindToPort:0 deviceIpAddress:ipAddress deviceIpPort:3671 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    else
    {
        [tunnellingShareInstance setTunnellingSocketWithClientBindToPort:0 deviceIpAddress:@"192.168.10.193" deviceIpPort:3671 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    
    [tunnellingShareInstance tunnellingServeStart];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
