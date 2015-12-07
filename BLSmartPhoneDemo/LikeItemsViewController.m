//
//  LikeItemsViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/5.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "LikeItemsViewController.h"
#import "LikeItems.h"
#import "BLACCell.h"
#import "BLCurtainCell.h"
#import "BLSwitchCell.h"



@interface LikeItemsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableView;
    LikeItems *likeItemsSharedInstance;
    NSInteger numberOfSection;
    NSInteger numberOfRow;
    NSInteger numberOfRooms;
    NSArray *availableSectionTitleArray;
    NSArray *availableRoomsArray;
}

@end

@implementation LikeItemsViewController
//+ (instancetype)sharedInstance
//{
//    // 1
//    static LikeItemsViewController *_sharedInstance = nil;
//    
//    // 2
//    static dispatch_once_t oncePredicate;
//    
//    // 3
//    dispatch_once(&oncePredicate, ^{
//        _sharedInstance = [[LikeItemsViewController alloc] init];
//    });
//    return _sharedInstance;
//}
//
//- (instancetype) init
//{
//    self = [super init];
//    if (self)
//    {
//        
//    }
//    
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"个人收藏";
    likeItemsSharedInstance = [LikeItems sharedInstance];
    //[self initData];
    
    //创建一个分组样式的UITableView
    CGRect frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 25, self.view.bounds.size.width, self.view.bounds.size.height - 25);
    tableView=[[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    tableView.dataSource = self;
    tableView.delegate = self;
    //[tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([likeItemsSharedInstance rearrangeLikeItemArray2] == NO)
    {
        return;
    };
    availableRoomsArray  = [likeItemsSharedInstance getAvailableRooms];
    numberOfRooms = [availableRoomsArray count];
    [self->tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)initData
//{
//    
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //[availableSectionTitleArray[section]]
{
    NSUInteger numberOfRows = 0;
    //NSArray *items = [likeItemsSharedInstance getCertainItemsWithItemType:availableSectionTitleArray[section]];
    RoomItemsPacket *room = availableRoomsArray[section];
    numberOfRows = [likeItemsSharedInstance getItemNumbersOfRoomWithRoomName:room->roomName];
    return numberOfRows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    RoomItemsPacket *room = availableRoomsArray[indexPath.section];
    if ([room->lights count])
    {
        if (indexPath.row < [room->lights count])
        {
                    NSArray *items = room->lights;
                    LikeItemPacket *itemDetail = items[indexPath.row];
                    BLSwitchCell *switchCell = [[BLSwitchCell alloc] initWithPlistName:itemDetail->plistName indexInPlist:itemDetail->indexInPlist switchName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
                    //[switchCell setSwitchWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
                    [switchCell readItemState];
                    cell = switchCell;
        }
    }
    
    if ([room->ACs count])
    {
        if((indexPath.row >= [room->lights count]) && (indexPath.row < ([room->lights count] + [room->ACs count])))
        {
                    BLACCell *ACCell = [[BLACCell alloc] init];
                    //[ACCell setACName:ACs[indexPath.row]];
                    NSArray *items = [likeItemsSharedInstance getCertainItemsWithItemType:@"空调"];
                    LikeItemPacket *itemDetail = items[indexPath.row];
                    [ACCell setACWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
                    //[ACCell initPanelItemValue];
                    //[ACCell readItemState];
                    cell = ACCell;
                    //return  ACCell;
        }
    }
    
    if ([room->Curtains count]) {
        if((indexPath.row >= ([room->lights count] + [room->ACs count])))
        {
                    BLCurtainCell *curtainCell = [[BLCurtainCell alloc] init];
                    //[curtainCell setCurtainName:Curtains[indexPath.row]];
                    NSArray *items = [likeItemsSharedInstance getCertainItemsWithItemType:@"窗帘"];
                    LikeItemPacket *itemDetail = items[indexPath.row];
                    //BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)Curtains[indexPath.row];
                    [curtainCell setCurtainWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
                    //[curtainCell initPanelItemValue];
                    //[curtainCell readItemState];
                    cell = curtainCell;
        }
    }
//    if ([availableSectionTitleArray[indexPath.section] isEqualToString:@"灯光"])
//    {
//        NSArray *items = [likeItemsSharedInstance getCertainItemsWithItemType:@"灯光"];
//        LikeItemPacket *itemDetail = items[indexPath.row];
//        BLSwitchCell *switchCell = [[BLSwitchCell alloc] initWithPlistName:itemDetail->plistName indexInPlist:itemDetail->indexInPlist switchName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
//        //[switchCell setSwitchWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
//        [switchCell readItemState];
//        cell = switchCell;
//    }
//    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"空调"])
//    {
//        
//        BLACCell *ACCell = [[BLACCell alloc] init];
//        //[ACCell setACName:ACs[indexPath.row]];
//        NSArray *items = [likeItemsSharedInstance getCertainItemsWithItemType:@"空调"];
//        LikeItemPacket *itemDetail = items[indexPath.row];
//        [ACCell setACWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
//        [ACCell initPanelItemValue];
//        [ACCell readItemState];
//        cell = ACCell;
//        //return  ACCell;
//    }
//    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"窗帘"])
//    {
//        BLCurtainCell *curtainCell = [[BLCurtainCell alloc] init];
//        //[curtainCell setCurtainName:Curtains[indexPath.row]];
//        NSArray *items = [likeItemsSharedInstance getCertainItemsWithItemType:@"窗帘"];
//        LikeItemPacket *itemDetail = items[indexPath.row];
//        //BLItemDetailPacket *itemDetail = (BLItemDetailPacket *)Curtains[indexPath.row];
//        [curtainCell setCurtainWithName:itemDetail->itemName detailDict:itemDetail->itemDetailDict];
//        [curtainCell initPanelItemValue];
//        [curtainCell readItemState];
//        cell = curtainCell;
//        
//    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfRooms;
}



- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    RoomItemsPacket *room = availableRoomsArray[section];
    return room->roomName;
    //return  availableSectionTitleArray[section];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if([availableSectionTitleArray[indexPath.section] isEqualToString:@"空调"])
//    {
//        return 106.0;
//    }
//    else if([availableSectionTitleArray[indexPath.section] isEqualToString:@"窗帘"])
//    {
//        return 71.0;
//    }
//    else
//    {
//        return 45.0;
//    }
    
    RoomItemsPacket *room = availableRoomsArray[indexPath.section];
    if ([room->lights count])
    {
        if (indexPath.row < [room->lights count])
        {
            return 45.0;
        }
    }
    
    if ([room->ACs count])
    {
        if((indexPath.row >= [room->lights count]) && (indexPath.row < ([room->lights count] + [room->ACs count])))
        {
            return 106.0;
        }
    }
    
    if ([room->Curtains count]) {
        if((indexPath.row >= ([room->lights count] + [room->ACs count])))
        {
            return 71.0;
        }
    }
    
    return 45.0;
}
@end
