//
//  ItemsViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/20.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "ItemsViewController.h"
#import "ItemBriefFuncViewController.h"
//#import "BLACCellViewController.h"
#import "BLACCell.h"
#import "BLCurtainCell.h"
#import "BLSwitchCell.h"


@interface BLItemDetailPacket : NSObject
{
@public
    NSString *itemName;
    NSDictionary *itemDetailDict;
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
    NSMutableArray *ACs;
    NSMutableArray *Curtains;
    NSArray *itemGroup;
    NSMutableArray *availableSectionTitleArray;
    NSArray *itemCatagory;
    //NSIndexPath *selectedIndexPath;//当前选中的组和行
}

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.title = @"佰凌智能";
    [self initData];
    
    //创建一个分组样式的UITableView
    itemsTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    itemsTableView.dataSource = self;
    itemsTableView.delegate = self;
    
    [self.view addSubview:itemsTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:self.title ofType:@"plist"];
    NSDictionary *itemsDict = [[NSDictionary alloc]initWithContentsOfFile:path];
    
    lights = [[NSMutableArray alloc] init];
    ACs = [[NSMutableArray alloc] init];
    Curtains = [[NSMutableArray alloc] init];
    itemGroup = [[NSArray alloc] initWithObjects:lights, ACs, Curtains, nil];
    itemCatagory = [[NSArray alloc] initWithObjects:@"灯光", @"空调",@"窗帘",nil];
    
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
                  if ([key isEqualToString:@"objectType"])
                  {
                      if ([obj isEqualToString:@"Light"])
                      {
                          [lights addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"AC"])
                      {
                          [ACs addObject:itemDetailPacket];
                      }
                      else if([obj isEqualToString:@"Curtain"])
                      {
                          [Curtains addObject:itemDetailPacket];
                      }
                  }
              }];
         }];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *items;
    if ([availableSectionTitleArray[section] isEqualToString:@"灯光"])
    {
        items = itemGroup[0];
    }
    else if([availableSectionTitleArray[section] isEqualToString:@"空调"])
    {
        items = itemGroup[1];
    }
    else if([availableSectionTitleArray[section] isEqualToString:@"窗帘"])
    {
        items = itemGroup[2];
    }
    
    return [items count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if ([availableSectionTitleArray[indexPath.section] isEqualToString:@"灯光"])
    {
        BLSwitchCell *switchCell = [[BLSwitchCell alloc] init];
        BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)lights[indexPath.row];
        [switchCell setSwitchWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
        [switchCell readItemState];
        cell = switchCell;
    }
    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"空调"])
    {
        //UITableViewCell *ACCell = [tableView dequeueReusableCellWithIdentifier:@"BLACCellView"];
        //if (ACCell ==  nil)
        {
            //BLACCellViewController *ACCellVC = [[BLACCellViewController alloc] init];
            //return ACCellVC.acCell;
//            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BLACCell" owner:ACCellVC options:nil];
//            for(id currentObject in topLevelObjects)
//            {
//                if([currentObject isKindOfClass:[BLACCell class]])
//                {
//                    ACCell = currentObject;
//                    return ACCell;
//                }
//            }

        }
        
        BLACCell *ACCell = [[BLACCell alloc] init];
        //[ACCell setACName:ACs[indexPath.row]];
        BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)ACs[indexPath.row];
        [ACCell setACWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
        [ACCell initPanelItemValue];
        [ACCell readItemState];
        cell = ACCell;
        //return  ACCell;
    }
    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"窗帘"])
    {
//        NSString *itemName = Curtains[indexPath.row];
//        cell.textLabel.text=itemName;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        BLCurtainCell *curtainCell = [[BLCurtainCell alloc] init];
        //[curtainCell setCurtainName:Curtains[indexPath.row]];
        BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)Curtains[indexPath.row];
        [curtainCell setCurtainWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
        [curtainCell initPanelItemValue];
        [curtainCell readItemState];
        cell = curtainCell;

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
    
    return  sectionNumber;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([availableSectionTitleArray[indexPath.section] isEqualToString:@"空调"])
    {
        return 106.0;
    }
    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"窗帘"])
    {
        return 71.0;
    }
    else
    {
        return 45.0;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    NSString *headerTitle = nil;
//    
//    switch (section)
//    {
//        case 0:
//            headerTitle = @"灯光";
//            break;
//        case 1:
//            headerTitle = @"空调";
//            break;
//        case 2:
//            headerTitle = @"窗帘";
//            break;
//            
//        default:
//            break;
//    }
//    
//    return  headerTitle;
    
    return  availableSectionTitleArray[section];
}

#pragma mark - UITableViewDelegate
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
