//
//  ViewController.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/20.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "ViewController.h"
#import "ItemsViewController.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"


@interface Scene : NSObject {
@public
    NSString *sceneName;
    UIButton *button;
    NSDictionary *buttonInfoDict;
}
- (id)init;
@end

@implementation Scene

- (id)init
{
    self = [super init];
    return self;
}

@end


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSDictionary* roomListDict;
    NSDictionary* sceneDict;
    UITableView *tableView;
    NSMutableArray *rooms;
    NSIndexPath *selectedIndexPath;//当前选中的组和行
    
    UITableViewCell *sceneCell;
    NSInteger sceneCellHight;
    NSMutableArray *sceneArray;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"佰凌智能";
    [self initData];
    
    //创建一个分组样式的UITableView
    tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    sceneArray = [[NSMutableArray alloc] init];
    sceneCell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PropertyConfig" ofType:@"plist"];
    NSDictionary *temDict = [[NSDictionary alloc]initWithContentsOfFile:path];
    
    roomListDict = [[NSDictionary alloc] initWithDictionary:[temDict objectForKey:@"RoomList"]];
    
    if (roomListDict == nil)
    {
        return;
    }
    
    rooms = [[NSMutableArray alloc] init];
    
    for (NSInteger index = 0; index < [roomListDict count]; index++)
    {
        NSString *roomName = [roomListDict objectForKey:[NSString stringWithFormat:@"%ld", (long)index]];
        [rooms addObject:roomName];
    }
    
    
    sceneDict = [[NSDictionary alloc] initWithDictionary:[temDict objectForKey:@"Scene"]];
    
    if (sceneDict == nil)
    {
        return;
    }
    
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
                      sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * 50 + 100, 10, 50, 50);
                  }
                  else
                  {
                      sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * 50 + 100, (currentSceneItemRowIndex) * 50 + 10, 50, 50);
                  }
                  
                  if (currentSceneItemIndex % 2)
                  {
                      sceneButoon.backgroundColor = [UIColor greenColor];
                  }
                  else
                  {
                      sceneButoon.backgroundColor = [UIColor redColor];
                  }
                  [sceneButoon setTitle:sceneItem->sceneName forState:UIControlStateNormal];
                  sceneButoon.translatesAutoresizingMaskIntoConstraints = NO;
                  [sceneButoon addTarget:self action:@selector(sceneButoonPressed:) forControlEvents:UIControlEventTouchUpInside];
                  
                  sceneItem->button = sceneButoon;
                  
                  [sceneArray addObject:sceneItem];
              }];
         }
    // }];
    
    sceneCellHight = (([sceneArray count] - 1) / 3 + 1) * 50 + 20;
    for (id obj in sceneArray)
    {
        Scene *sceneItem = obj;
        [sceneCell addSubview:sceneItem->button];
    }
    
//    UIButton *sceneButoon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    sceneButoon.frame = CGRectMake(50 + 50, 10, 50, 50);
//    sceneButoon.backgroundColor = [UIColor greenColor];
//    [sceneButoon setTitle:@"上班" forState:UIControlStateNormal];
//    sceneButoon.translatesAutoresizingMaskIntoConstraints = NO;
//    [sceneCell addSubview:sceneButoon];
//    UIButton *sceneButoon2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    sceneButoon2.frame = CGRectMake(100 + 50, 10, 50, 50);
//    sceneButoon2.backgroundColor = [UIColor redColor];
//    [sceneButoon2 setTitle:@"下班" forState:UIControlStateNormal];
//    sceneButoon2.translatesAutoresizingMaskIntoConstraints = NO;
//    [sceneCell addSubview:sceneButoon2];
//    UIButton *sceneButoon3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    sceneButoon3.frame = CGRectMake(150 + 50, 10, 50, 50);
//    sceneButoon3.backgroundColor = [UIColor purpleColor];
//    [sceneButoon3 setTitle:@"迎宾" forState:UIControlStateNormal];
//    sceneButoon3.translatesAutoresizingMaskIntoConstraints = NO;
//    [sceneCell addSubview:sceneButoon3];
    
    /////////////////////////////////////////////////////
    
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sectionNumber = 0;
    if(section == 0)
    {
        sectionNumber = 1;
    }
    else if(section == 1)
    {
        sectionNumber = [rooms count];
    }
    return  sectionNumber;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSInteger sectionNum = 0;
//    
//    if ([roomListDict count])
//    {
//        sectionNum++;
//    }
//    
//    if ([sceneDict count])
//    {
//        sectionNum++;
//    }
    
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = sceneCell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *roomCell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        NSString *roomName = rooms[indexPath.row];
        roomCell.textLabel.text=roomName;
        roomCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = roomCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return sceneCellHight;
    }
    else
    {
        return 45.0;
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    selectedIndexPath = indexPath;
    NSString *roomName = rooms[indexPath.row];
    ItemsViewController *itemsViewController = [[ItemsViewController alloc] init];
    [self.navigationController pushViewController:itemsViewController animated:YES];
    itemsViewController.title = roomName;
    //创建弹出窗口
    //UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"System Info" message:roomName delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    //alert.alertViewStyle=UIAlertViewStylePlainTextInput; //设置窗口内容样式
    //UITextField *textField= [alert textFieldAtIndex:0]; //取得文本框
    //textField.text=roomName; //设置文本框内容
    //[alert show]; //显示窗口
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

//#pragma mark 窗口的代理方法，用户保存数据
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    //当点击了第二个按钮（OK）
//    if (buttonIndex==1) {
//        UITextField *textField= [alertView textFieldAtIndex:0];
//        //修改模型数据
//        //NSString *roomName = rooms[indexPath.row];
//        rooms[selectedIndexPath.row] =textField.text;
//        //刷新表格
//        [tableView reloadData];
//    }
//}
@end
