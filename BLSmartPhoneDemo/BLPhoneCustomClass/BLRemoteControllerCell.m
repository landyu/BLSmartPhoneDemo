//
//  BLRemoteControllerCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//



#import "BLRemoteControllerCell.h"
#import "BLRemoteControllerViewController.h"

@interface BLRemoteControllerCell()
{
    UINavigationController *parentNavigationController;
    NSString *aRemoteControllerName;
    NSDictionary *itemDetailDict;
    NSString *cellReuseIdentifier;
}
@property (strong, nonatomic) IBOutlet UIButton *remoteControllerButtonOutlet;

@end

@implementation BLRemoteControllerCell
@synthesize remoteControllerButtonOutlet;

- (id)initWithParentNavigationController:(UINavigationController *)navigationController
{
    self = [self init];
    if (self)
    {
        parentNavigationController = navigationController;
    }
    return self;
}

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLRemoteControllerCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIImage imageNamed:@"CellBackground"] drawInRect:self.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundColor = [UIColor clearColor];
    self.separatorInset = UIEdgeInsetsZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)remoteControllerButtonPressed:(UIButton *)sender
{
    NSLog(@"remoteControllerButtonPressed");
    BLRemoteControllerViewController *remoteControllerVC = [[BLRemoteControllerViewController alloc] initWithDetailDict:itemDetailDict];
    //[remoteControllerVC setRemoteControllerWithdetailDict:itemDetailDict];
    [self->parentNavigationController pushViewController:remoteControllerVC animated:YES];
    remoteControllerVC.title = aRemoteControllerName;
}

- (void)setRemoteControllerWithName:(NSString *)remoteControllerName detailDict:(NSDictionary *)detailDict
{
    aRemoteControllerName = remoteControllerName;
    itemDetailDict = detailDict;
    [remoteControllerButtonOutlet setTitle:aRemoteControllerName forState:UIControlStateNormal];
}

- (void)setRemoteControllerWithName:(NSString *)remoteControllerName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId
{
    [self setRemoteControllerWithName:remoteControllerName detailDict:detailDict];
    cellReuseIdentifier = reuseId;
}

- (NSString *)reuseIdentifier
{
    return cellReuseIdentifier;
}

@end
