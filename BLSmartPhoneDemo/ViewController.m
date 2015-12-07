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





@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSDictionary* roomListDict;
    NSDictionary* sceneDict;
    UITableView *frontPageTableView;
    NSMutableArray *rooms;
    NSIndexPath *selectedIndexPath;//当前选中的组和行
    
    UITableViewCell *sceneCell;
    NSInteger sceneCellHight;
    NSMutableArray *sceneArray;
    
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    
    float sceneButtonHeight;
    float sceneButtonWidth;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"佰凌智能";
    [self initData];
    
    //创建一个分组样式的UITableView
    frontPageTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    //设置数据源，注意必须实现对应的UITableViewDataSource协议
    frontPageTableView.dataSource = self;
    frontPageTableView.delegate = self;
    frontPageTableView.backgroundColor = [UIColor clearColor];
    [frontPageTableView setSeparatorColor:[UIColor clearColor]];
    frontPageTableView.autoresizingMask= UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //self.view.backgroundColor = [UIColor clearColor];
    
    //tableView.alpha = 0.5;
    //self.view.alpha = 0.5;
    UIColor *color = [UIColor clearColor];
    self.view.backgroundColor = [color colorWithAlphaComponent:0.3];
    
    [self.view addSubview:frontPageTableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [frontPageTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    NSString* roomInfoDirPath = [documentPath stringByAppendingPathComponent:@"RoomInfo"];
    NSString *propertyConfigPath = [roomInfoDirPath stringByAppendingPathComponent:@"PropertyConfig.plist"];
    sceneButtonHeight = 60.0;
    sceneButtonWidth = 98.0;
    
    BOOL isDir = YES;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:roomInfoDirPath isDirectory:&isDir];
    if ((isDir == YES && existed == YES))
    {
        isDir = NO;
        existed = [[NSFileManager defaultManager] fileExistsAtPath:propertyConfigPath isDirectory:&isDir];
        if (existed == NO)
        {
            return;
        }
    }
    else
    {
        return;
    }
    
    sceneArray = [[NSMutableArray alloc] init];
    //sceneCell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    tunnellingShareInstance  = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"PropertyConfig" ofType:@"plist"];
    NSDictionary *temDict = [[NSDictionary alloc]initWithContentsOfFile:propertyConfigPath];
    
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
                      if (currentSceneItemColumnIndex == 0)
                      {
                          sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * sceneButtonWidth + 60, 15, sceneButtonWidth, sceneButtonHeight);
                      }
                      else
                      {
                          sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * (sceneButtonWidth  + 15) + 60, 15, sceneButtonWidth, sceneButtonHeight);
                      }
                      
                  }
                  else
                  {
                      if (currentSceneItemColumnIndex == 0)
                      {
                          sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * sceneButtonWidth + 60, (currentSceneItemRowIndex) * (sceneButtonHeight + 10) + 15, sceneButtonWidth, sceneButtonHeight);
                      }
                      else
                      {
                          sceneButoon.frame = CGRectMake((currentSceneItemColumnIndex) * (sceneButtonWidth  + 15) + 60, (currentSceneItemRowIndex) * (sceneButtonHeight + 10) + 15, sceneButtonWidth, sceneButtonHeight);
                      }
                      
                  }
                  
//                  if (currentSceneItemIndex % 2)
//                  {
//                      sceneButoon.backgroundColor = [UIColor greenColor];
//                  }
//                  else
//                  {
//                      sceneButoon.backgroundColor = [UIColor redColor];
//                  }
                  UIImage *image = [UIImage imageNamed: @"SceneButtonSelect"];
//                  CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.1, 0.1));
//                  BOOL hasAlpha = false;
//                  CGFloat scale =  0.0; // Automatically use scale factor of main screen
//                  
//                  UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
//                  //image.drawInRect(CGRect(origin: CGPointZero, size: size));
//                  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                  
                  [sceneButoon setBackgroundImage:image forState:UIControlStateNormal];
//                  UIGraphicsEndImageContext();

                  image = [UIImage imageNamed: @"SceneButtonNormal"];
//                  size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.1, 0.1));
//                  hasAlpha = false;
//                  scale =  0.0; // Automatically use scale factor of main screen
//                  
//                  UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
//                  //image.drawInRect(CGRect(origin: CGPointZero, size: size));
//                  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                  
                  [sceneButoon setBackgroundImage:image forState:UIControlStateSelected];
                  //UIGraphicsEndImageContext();
                  
                  
                  //[sceneButoon setBackgroundImage:[UIImage imageNamed:@"SceneButtonNormal.png"] forState:UIControlStateNormal];
                  //[sceneButoon setImage:[UIImage imageNamed:@"SceneButtonSelect.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
                  //sceneButoon.backgroundColor = [UIColor clearColor];
                  [sceneButoon setTitle:sceneItem->sceneName forState:UIControlStateNormal];
                  [sceneButoon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                  //sceneButoon.titleLabel.text = sceneItem->sceneName;
                  //sceneButoon.titleLabel.textColor = [UIColor whiteColor];
                  //sceneButoon.translatesAutoresizingMaskIntoConstraints = NO;
                  [sceneButoon addTarget:self action:@selector(sceneButoonPressed:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDown];
                  
                  sceneItem->button = sceneButoon;
                  
                  [sceneArray addObject:sceneItem];
              }];
         }
    // }];
    
    sceneCellHight = (([sceneArray count] - 1) / 3 + 1) * (sceneButtonHeight + 15) + 20;
//    for (id obj in sceneArray)
//    {
//        Scene *sceneItem = obj;
//        [sceneCell addSubview:sceneItem->button];
//    }
    
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
    //UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [frontPageTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil)
    {
        return cell;
    }
    
    if (indexPath.section == 0)
    {
        sceneCell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        for (id obj in sceneArray)
        {
            Scene *sceneItem = obj;
            [sceneCell addSubview:sceneItem->button];
        }
        cell = sceneCell;
        
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        
        //    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //    visualEfView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, cell.frame.size.height);
        //    visualEfView.alpha = 0.3;
        //    visualEfView.opaque = true;
        //    [bgView addSubview:visualEfView];
        
        cell.selectedBackgroundView = bgView;
        cell.backgroundView = bgView;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *roomCell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        NSString *roomName = rooms[indexPath.row];
        roomCell.textLabel.text=roomName;
        roomCell.textLabel.textColor = [UIColor whiteColor];
        roomCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = roomCell;
        
        UIGraphicsBeginImageContext(cell.bounds.size);
        [[UIImage imageNamed:@"CellBackground"] drawInRect:cell.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
        
        //    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //    visualEfView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, cell.frame.size.height);
        //    visualEfView.alpha = 0.3;
        //    visualEfView.opaque = true;
        //    [bgView addSubview:visualEfView];
        
        cell.selectedBackgroundView = bgView;
        
        UIImage *image = [UIImage imageNamed: @"RoomIcon"];
        
        CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
        BOOL hasAlpha = true;
        CGFloat scale =  0.0; // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
        //image.drawInRect(CGRect(origin: CGPointZero, size: size));
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        cell.imageView.image  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    
    //bgView.alpha = 0.1;//This setting has no effect
    
    
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
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
