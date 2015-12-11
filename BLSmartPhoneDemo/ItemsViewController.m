//
//  ItemsViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/20.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "ItemsViewController.h"
//#import "ItemBriefFuncViewController.h"
//#import "BLACCellViewController.h"
#import "BLACCell.h"
#import "BLHeatingCell.h"
#import "BLCurtainCell.h"
#import "BLSwitchCell.h"
#import "BLDimmingCell.h"
#import "BLRemoteControllerCell.h"
#import "BLSmartPhoneDemo-Swift.h"
#import "UIViewController+CWPopup.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"




@implementation Scene

- (id)init
{
    self = [super init];
    return self;
}

@end


@interface BLItemDetailPacket : NSObject
{
@public
    NSString *itemName;
    NSDictionary *itemDetailDict;
    NSString *indexInPlist;
}

- (id)init;

@end

@implementation BLItemDetailPacket

- (id)init
{
    self = [super init];
    return self;
}


@end



@interface ItemsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *itemsTableView;
    NSMutableArray *lights;
    NSMutableArray *dimmings;
    NSMutableArray *ACs;
    NSMutableArray *curtains;
    NSMutableArray *heatings;
    NSMutableArray *rcs;
    NSArray *itemGroup;
    NSMutableArray *availableSectionTitleArray;
    NSArray *itemCatagory;
    //NSIndexPath *selectedIndexPath;//当前选中的组和行
    
    NSMutableArray *sceneArray;
    NSInteger sceneCellHight;
    NSDictionary *scenesDict;
    
    float sceneButtonHeight;
    float sceneButtonWidth;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
}

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.title = @"佰凌智能";
    
    sceneCellHight = 0;
    tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    
    [self initData];
    
    //创建一个分组样式的UITableView
    itemsTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    //itemsTableView=[[UITableView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + sceneCellHight, self.view.bounds.size.width, self.view.bounds.size.height - sceneCellHight) style:UITableViewStyleGrouped];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    itemsTableView.dataSource = self;
    itemsTableView.delegate = self;
    itemsTableView.allowsSelection = NO;
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //itemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    itemsTableView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    [itemsTableView setSeparatorColor:[UIColor clearColor]];
    [itemsTableView setLayoutMargins:UIEdgeInsetsZero];
    itemsTableView.autoresizingMask= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    [self.view addSubview:itemsTableView];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSceneButton) name:@"presentPopupViewController" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSceneButton) name:@"dismissPopupViewController" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadSceneButton
{
//    for (id obj in sceneArray)
//    {
//        Scene *sceneItem = obj;
//        [sceneItem->button removeFromSuperview];
//        //[self.view addSubview:sceneItem->button];
//    }
//    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    testButton.backgroundColor = [UIColor redColor];
//    testButton.frame = CGRectMake(60, 15, 50, 50);
//    [self.view addSubview:testButton];
//    
//    UIButton *testButton2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    testButton2.backgroundColor = [UIColor redColor];
//    testButton2.frame = CGRectMake(150, 15, 50, 50);
//    [self.view addSubview:testButton2];

    //[self initSceneItemWithSceneDict:scenesDict];
}

-(void)initData
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.title ofType:@"plist"];
    //NSDictionary *itemsDict = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
    NSString *itemPlistPath = [roomInfoDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", self.title]];;
    
    BOOL isDir = YES;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:roomInfoDirPath isDirectory:&isDir];
    if ((isDir == YES && existed == YES))
    {
        isDir = NO;
        existed = [[NSFileManager defaultManager] fileExistsAtPath:itemPlistPath isDirectory:&isDir];
        if (existed == NO)
        {
            return;
        }
    }
    else
    {
        return;
    }
    
    NSDictionary *plistDict = [[NSDictionary alloc]initWithContentsOfFile:itemPlistPath];
    
    scenesDict = [[NSDictionary alloc] initWithDictionary:[plistDict objectForKey:@"Scene"]];
    [self initSceneItemWithSceneDict:scenesDict];
    
    NSDictionary *itemsDict = [[NSDictionary alloc] initWithDictionary:[plistDict objectForKey:@"Items"]];
    lights = [[NSMutableArray alloc] init];
    dimmings = [[NSMutableArray alloc] init];
    ACs = [[NSMutableArray alloc] init];
    curtains = [[NSMutableArray alloc] init];
    heatings = [[NSMutableArray alloc] init];
    rcs = [[NSMutableArray alloc] init];
    itemGroup = [[NSArray alloc] initWithObjects:lights, dimmings, curtains, ACs, heatings, rcs, nil];
    itemCatagory = [[NSArray alloc] initWithObjects:@"灯光",@"调光灯", @"窗帘",@"空调", @"地暖",@"遥控", nil];
    
    for (NSInteger index = 0; index < [itemsDict count]; index++)
    {
        NSDictionary *itemDict = [itemsDict objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
        [itemDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             NSString *objName = [NSString stringWithString:key];
             NSDictionary *itemDict = [[NSDictionary alloc]initWithDictionary:obj];
             [itemDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  BLItemDetailPacket *itemDetailPacket = [[BLItemDetailPacket alloc] init];
                  itemDetailPacket->itemName = objName;
                  itemDetailPacket->itemDetailDict = itemDict;
                  itemDetailPacket->indexInPlist = [NSString stringWithFormat:@"%ld", (long)index];
                  if ([key isEqualToString:@"objectType"])
                  {
                      if ([obj isEqualToString:@"Light"])
                      {
                          [lights addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"Dimming"])
                      {
                          [dimmings addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"Curtain"])
                      {
                          [curtains addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"AC"])
                      {
                          [ACs addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"Heating"])
                      {
                          [heatings addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"RC"])
                      {
                          [rcs addObject:itemDetailPacket];
                      }
                  }
              }];
         }];
    }
    
}

- (void)initSceneItemWithSceneDict:(NSDictionary *)sceneDict
{
    
    sceneCellHight = 0;
    if ((sceneDict == nil) || ([sceneDict count] == 0))
    {
        return;
    }
    
    sceneButtonHeight = 60.0;
    sceneButtonWidth = 98.0;
    sceneArray = [[NSMutableArray alloc] init];
    //[sceneDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    //{
    for (NSInteger index = 0; index < [sceneDict count]; index++)
    {
        NSDictionary *sceneItemPre = [sceneDict objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
        [sceneItemPre enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             Scene *sceneItem = [[Scene alloc] init];
             sceneItem->sceneName = key;
             sceneItem->buttonInfoDict = obj;
             
             NSInteger currentSceneItemIndex = [sceneArray count];
             NSInteger currentSceneItemColumnIndex = (currentSceneItemIndex % 3);
             NSInteger currentSceneItemRowIndex = 0;
             if (currentSceneItemIndex >= 3)
             {
                 currentSceneItemRowIndex = (currentSceneItemIndex / 3);
             }
             
             
             UIButton *sceneButoon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
             if (currentSceneItemRowIndex == 0)
             {
                 if (currentSceneItemColumnIndex == 0)
                 {
                     sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * sceneButtonWidth + 45, 15, sceneButtonWidth, sceneButtonHeight);
                 }
                 else
                 {
                     sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * (sceneButtonWidth  + 15) + 45, 15, sceneButtonWidth, sceneButtonHeight);
                 }
                 
             }
             else
             {
                 if (currentSceneItemColumnIndex == 0)
                 {
                     sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * sceneButtonWidth + 45, (currentSceneItemRowIndex) * (sceneButtonHeight + 10) + 15, sceneButtonWidth, sceneButtonHeight);
                 }
                 else
                 {
                     sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * (sceneButtonWidth  + 15) + 45, (currentSceneItemRowIndex) * (sceneButtonHeight + 10) + 15, sceneButtonWidth, sceneButtonHeight);
                 }
                 
             }
             
             UIImage *image = [UIImage imageNamed: @"SceneButtonSelect"];
             [sceneButoon setBackgroundImage:image forState:UIControlStateNormal];
             image = [UIImage imageNamed: @"SceneButtonNormal"];
             [sceneButoon setBackgroundImage:image forState:UIControlStateSelected];
             [sceneButoon setTitle:sceneItem->sceneName forState:UIControlStateNormal];
             [sceneButoon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             //sceneButoon.translatesAutoresizingMaskIntoConstraints = NO;
             [sceneButoon addTarget:self action:@selector(sceneButoonPressed:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
             sceneItem->button = sceneButoon;
             [self.view addSubview:sceneButoon];
             [sceneArray addObject:sceneItem];
         }];
    }
    // }];
    
    sceneCellHight = (([sceneArray count] - 1) / 3 + 1) * (sceneButtonHeight + 10) + 20;
}


- (void) sceneButoonPressed:(UIButton *)sender
{
    NSString *sceneName = [sender titleForState:UIControlStateNormal];
    for (id obj in sceneArray)
    {
        Scene *sceneItem = obj;
        if ([sceneItem->sceneName isEqualToString:sceneName])
        {
            NSString *writeToGroupAddress = [sceneItem->buttonInfoDict[@"WriteToGroupAddress"] objectForKey:@"0"];
            NSString *sceneNumber = [sceneItem->buttonInfoDict objectForKey:@"SceneNumber"];
            
            [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeToGroupAddress value:[sceneNumber integerValue] buttonName:nil valueLength:@"1Byte" commandType:@"Write"];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *items;
    if ([sceneArray count] > 0)
    {
        if (section == 0)
        {
            return  1;
        }
        else
        {
            if ([availableSectionTitleArray[section - 1] isEqualToString:@"灯光"])
            {
                items = itemGroup[0];
            }
            else if([availableSectionTitleArray[section - 1] isEqualToString:@"调光灯"])
            {
                items = itemGroup[1];
            }
            else if([availableSectionTitleArray[section - 1] isEqualToString:@"窗帘"])
            {
                items = itemGroup[2];
            }
            else if([availableSectionTitleArray[section - 1] isEqualToString:@"空调"])
            {
                items = itemGroup[3];
            }
            else if([availableSectionTitleArray[section - 1] isEqualToString:@"地暖"])
            {
                items = itemGroup[4];
            }
            else if([availableSectionTitleArray[section - 1] isEqualToString:@"遥控"])
            {
                items = itemGroup[5];
            }
        }

    }
    else
    {
        if ([availableSectionTitleArray[section] isEqualToString:@"灯光"])
        {
            items = itemGroup[0];
        }
        else if([availableSectionTitleArray[section] isEqualToString:@"调光灯"])
        {
            items = itemGroup[1];
        }
        else if([availableSectionTitleArray[section] isEqualToString:@"窗帘"])
        {
            items = itemGroup[2];
        }
        else if([availableSectionTitleArray[section] isEqualToString:@"空调"])
        {
            items = itemGroup[3];
        }
        else if([availableSectionTitleArray[section] isEqualToString:@"地暖"])
        {
            items = itemGroup[4];
        }
        else if([availableSectionTitleArray[section] isEqualToString:@"遥控"])
        {
            items = itemGroup[5];
        }
    }
    
    
    return [items count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *cellIdentifier = String(indexPath.section) + "-" + String(indexPath.row)
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([sceneArray count] > 0)
    {
        if (indexPath.section == 0)
        {
            if (cell == nil)
            {
                cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                for (id obj in sceneArray)
                {
                    Scene *sceneItem = obj;
                    [cell addSubview:sceneItem->button];
                }
                
                UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
                [[UIImage imageNamed:@"Background"] drawInRect:[[UIScreen mainScreen] bounds]];
                UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                UIView *bgView = [[UIView alloc] init];
                bgView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
                cell.selectedBackgroundView = bgView;
                cell.backgroundView = bgView;
            }
        }
        else
        {
            if (cell == nil)
            {
                if ([availableSectionTitleArray[indexPath.section - 1] isEqualToString:@"灯光"])
                {
                    BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)lights[indexPath.row];
                    BLSwitchCell *switchCell = [[BLSwitchCell alloc] initWithPlistName:self.title indexInPlist:itemDetail->indexInPlist switchName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                    
                    [switchCell readItemState];
                    cell = switchCell;
                    
                }
                else if ([availableSectionTitleArray[indexPath.section - 1] isEqualToString:@"调光灯"])
                {
                    BLDimmingCell *dimmingCell = [[BLDimmingCell alloc] initWithParentViewController:self];
                    BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)dimmings[indexPath.row];
                    [dimmingCell setSwitchWithName:itemDetail->itemName itemDetailDict:itemDetail->itemDetailDict];
                    cell = dimmingCell;
                }
                else if([availableSectionTitleArray[indexPath.section - 1] isEqualToString:@"窗帘"])
                {
                    BLCurtainCell *curtainCell = [[BLCurtainCell alloc] initWithParentViewController:self];
                    BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)curtains[indexPath.row];
                    [curtainCell setCurtainWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                    cell = curtainCell;
                    
                }
                else if([availableSectionTitleArray[indexPath.section - 1] isEqualToString:@"空调"])
                {
                    
                    BLACCell *ACCell = [[BLACCell alloc] initWithParentViewController:self];
                    BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)ACs[indexPath.row];
                    [ACCell setACWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                    cell = ACCell;
                }
                else if([availableSectionTitleArray[indexPath.section - 1] isEqualToString:@"地暖"])
                {
                    BLHeatingCell *heatingCell = [[BLHeatingCell alloc] initWithParentViewController:self];
                    BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)heatings[indexPath.row];
                    [heatingCell setHeatingWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                    cell = heatingCell;
                }
                else if([availableSectionTitleArray[indexPath.section - 1] isEqualToString:@"遥控"])
                {
                    BLRemoteControllerCell *rcCell = [[BLRemoteControllerCell alloc] initWithParentNavigationController:self.navigationController];
                    BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)rcs[indexPath.row];
                    //[rcCell setRemoteControllerWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
                    [rcCell setRemoteControllerWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                    cell = rcCell;
                }
            }
        }
    }
    else
    {
        if (cell == nil)
        {
            
            if ([availableSectionTitleArray[indexPath.section] isEqualToString:@"灯光"])
            {
                BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)lights[indexPath.row];
                BLSwitchCell *switchCell = [[BLSwitchCell alloc] initWithPlistName:self.title indexInPlist:itemDetail->indexInPlist switchName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                
                [switchCell readItemState];
                cell = switchCell;
                
            }
            else if ([availableSectionTitleArray[indexPath.section] isEqualToString:@"调光灯"])
            {
                BLDimmingCell *dimmingCell = [[BLDimmingCell alloc] initWithParentViewController:self];
                BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)dimmings[indexPath.row];
                [dimmingCell setSwitchWithName:itemDetail->itemName itemDetailDict:itemDetail->itemDetailDict];
                cell = dimmingCell;
            }
            else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"窗帘"])
            {
                BLCurtainCell *curtainCell = [[BLCurtainCell alloc] initWithParentViewController:self];
                BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)curtains[indexPath.row];
                [curtainCell setCurtainWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                cell = curtainCell;
                
            }
            else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"空调"])
            {
                
                BLACCell *ACCell = [[BLACCell alloc] initWithParentViewController:self];
                BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)ACs[indexPath.row];
                [ACCell setACWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                cell = ACCell;
            }
            else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"地暖"])
            {
                BLHeatingCell *heatingCell = [[BLHeatingCell alloc] initWithParentViewController:self];
                BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)heatings[indexPath.row];
                [heatingCell setHeatingWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                cell = heatingCell;
            }
            else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"遥控"])
            {
                BLRemoteControllerCell *rcCell = [[BLRemoteControllerCell alloc] initWithParentNavigationController:self.navigationController];
                BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)rcs[indexPath.row];
                [rcCell setRemoteControllerWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict reuseIdentifier:cellIdentifier];
                cell = rcCell;
            }
        }
    }
    
    
    
    
    
   
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNumber = 0;
    availableSectionTitleArray = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < [itemGroup count]; index++)
    {
        NSMutableArray *items = itemGroup[index];
        if ([items count])
        {
            [availableSectionTitleArray addObject:itemCatagory[index]];
            sectionNumber++;
        }
    }
    
    if ([sceneArray count] > 0)
    {
        sectionNumber++;
    }
    
    return  sectionNumber;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if ([sceneArray count] > 0)
    {
        if (section == 0)
        {
            title = @"场景";
        }
        else
        {
            title = availableSectionTitleArray[section - 1];
        }
    }
    else
    {
        title = availableSectionTitleArray[section];
    }
    return  title;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 43.0;
    if ([sceneArray count] > 0)
    {
        if (indexPath.section == 0)
        {
            rowHeight = sceneCellHight;
        }
    }
//    if([availableSectionTitleArray[indexPath.section] isEqualToString:@"空调"])
//    {
//        return 43.0;
//    }
//    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"地暖"])
//    {
//        return 43.0;
//    }
//    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"窗帘"])
//    {
//        return 43.0;
//    }
//    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"调光灯"])
//    {
//        return 43.0;
//    }
//    else
//    {
//        return 45.0;
//    }
    return rowHeight;
}



//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //selectedIndexPath = indexPath;
//    NSString *itemName;
//
//    if (indexPath.section == 0)
//    {
//        itemName = lights[indexPath.row];
//    }
//    else if(indexPath.section == 1)
//    {
//        itemName = ACs[indexPath.row];
//    }
//    else if(indexPath.section == 2)
//    {
//        itemName = Curtains[indexPath.row];
//    }
//
//    ItemBriefFuncViewController *itemBriefFuncViewController = [[ItemBriefFuncViewController alloc] init];
//    [self.navigationController pushViewController:itemBriefFuncViewController animated:YES];
//    itemBriefFuncViewController.title = itemName;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
