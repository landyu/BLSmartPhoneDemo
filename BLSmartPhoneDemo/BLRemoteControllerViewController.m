//
//  BLRemoteControllerViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLRemoteControllerViewController.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"

@interface BLRemoteControllerViewController ()
{
    UITableView *itemsTableView;
    NSDictionary *remoteControllerDetailDict;
    UIScrollView *scrollView;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
}

@end

@implementation BLRemoteControllerViewController

- (id)initWithDetailDict:(NSDictionary *)detailDict
{
    self = [super init];
    if (self)
    {
        remoteControllerDetailDict = detailDict;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    //1. 建立UIScrollView窗口，我们只打算用手机的上半屏显示图像，(这一步也可以在storyboard里完成)
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    NSUInteger itemCount = [remoteControllerDetailDict count] - 1;
    NSUInteger itemRowNum = 0;
    if (itemCount > 3)
    {
        itemRowNum = itemCount / 3;
    }
    
    CGSize contentSize = CGSizeMake(self.view.bounds.size.width, itemRowNum * 80 + 80 + 150);
    scrollView.contentSize = contentSize;
    scrollView.backgroundColor = [UIColor clearColor];
    //2.建立内容视图
    //UIImageView * view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tesla.jpg"]];
    //3.将内容视图作为scrollView的子视图
    //[scrollView addSubview: view];
    [self addRemoteControllerButton];
    //4.当然了，还得把scrollView添加到视图结构中
    [self.view addSubview: scrollView];
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Balloon"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
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

//- (void)setRemoteControllerWithDetailDict:(NSDictionary *)detailDict
//{
//    //NSLog(@"%@", detailDict);
//    remoteControllerDetailDict = detailDict;
//    //NSUInteger itemCounter = [detailDict count];
//    [self addRemoteControllerButton];
//}

- (void)addRemoteControllerButton
{
    
    if (remoteControllerDetailDict == nil || scrollView == nil)
    {
        return;
    }
    
    float rcButtonHeight = 60.0;
    float rcButtonWidth = 98.0;
    
    for (NSUInteger index = 0; index < [remoteControllerDetailDict count] -1; index++)
    {
        NSDictionary *itemDict = [remoteControllerDetailDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        
        if (itemDict == nil)
        {
            NSLog(@"remote item dict error......");
            continue;
            //return;
        }
        else
        {
                 NSInteger currentRCItemIndex = index;
                 NSInteger currentRCItemColumnIndex = (currentRCItemIndex % 3);
                 NSInteger currentSceneItemRowIndex = 0;
                 if (currentRCItemIndex >= 3)
                 {
                     currentSceneItemRowIndex = (currentRCItemIndex / 3);
                 }
                 
                 
                 UIButton *rcButoon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                if (currentSceneItemRowIndex == 0)
                {
                    if (currentRCItemColumnIndex == 0)
                    {
                        rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * rcButtonWidth + 60, 15, rcButtonWidth, rcButtonHeight);
                    }
                    else
                    {
                        rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * (rcButtonWidth  + 15) + 60, 15, rcButtonWidth, rcButtonHeight);
                    }
                    
                }
                else
                {
                    if (currentRCItemColumnIndex == 0)
                    {
                        rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * rcButtonWidth + 60, (currentSceneItemRowIndex) * (rcButtonHeight + 10) + 15, rcButtonWidth, rcButtonHeight);
                    }
                    else
                    {
                        rcButoon.frame = CGRectMake((currentRCItemColumnIndex) * (rcButtonWidth  + 15) + 60, (currentSceneItemRowIndex) * (rcButtonHeight + 10) + 15, rcButtonWidth, rcButtonHeight);
                    }
                    
                }
            
                NSString *buttonTitle = [itemDict objectForKey:@"Name"];
            if ([buttonTitle isEqualToString:@""])
            {
                continue;
            }
            else
            {
                
                UIImage *image = [UIImage imageNamed: @"SceneButtonSelect"];
                [rcButoon setBackgroundImage:image forState:UIControlStateNormal];
                image = [UIImage imageNamed: @"SceneButtonNormal"];
                [rcButoon setBackgroundImage:image forState:UIControlStateSelected];
                [rcButoon setTitle:buttonTitle forState:UIControlStateNormal];
                rcButoon.translatesAutoresizingMaskIntoConstraints = NO;
                [rcButoon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [rcButoon addTarget:self action:@selector(rcButoonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [scrollView addSubview:rcButoon];
            }
                 //sceneItem->button = rcButoon;
                 
                 //[sceneArray addObject:sceneItem];
        }
        
        
        
        
    }
}

-(void)rcButoonPressed:(UIButton *)sender
{
    NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
    
    for (NSUInteger index = 0; index < [remoteControllerDetailDict count] -1; index++)
    {
        NSDictionary *itemDict = [remoteControllerDetailDict objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        
        if (itemDict == nil)
        {
            NSLog(@"remote item dict error......2");
            continue;
            //return;
        }
        
        NSString *itemName = [itemDict objectForKey:@"Name"];
        
        if (itemName == nil)
        {
            continue;
        }
        
        if ([buttonTitle isEqualToString:itemName])
        {
            NSLog(@"RC Group Address = %@", [itemDict objectForKey:@"WriteToGroupAddress"]);
            NSString *writeToGroupAddress = [itemDict objectForKey:@"WriteToGroupAddress"];
            NSString *value = [itemDict objectForKey:@"Value"];
            NSString *valueLength = [itemDict objectForKey:@"ValueLength"];
            
            [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeToGroupAddress value:[value integerValue] buttonName:nil valueLength:valueLength commandType:@"Write"];
            break;
        }
    }
}
//- (void)parseItemDetailDictWithDict:(NSDictionary *)detailDict
//{
//    
//}

@end
