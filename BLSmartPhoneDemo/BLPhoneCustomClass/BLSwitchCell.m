//
//  BLSwitchCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/10/23.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLSwitchCell.h"
#import "GlobalMacro.h"
#import "BLGCDKNXTunnellingAsyncUdpSocket.h"
#import "LikeItems.h"
#import "BLSmartPhoneDemo-Swift.h"

@interface BLSwitchCell()
{
    NSDictionary *itemDetailDict;
    NSString *writeToGroupAddress;
    NSString *readFromGroupAddress;
    NSString *itemValueLength;
    BLGCDKNXTunnellingAsyncUdpSocket *tunnellingShareInstance;
    
    NSString *plistName;
    NSString *indexInPlist;
    NSString *cellReuseIdentifier;
    
    SevenSwitch *switchButton;
}
- (IBAction)switchButtonPressed:(UISwitch *)sender;
- (IBAction)likeButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UISwitch *switchButtonOutlet;
@property (strong, nonatomic) IBOutlet UILabel *switchNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButtonOutlet;
@end



@implementation BLSwitchCell
@synthesize switchButtonOutlet;
@synthesize switchNameLabel;
@synthesize likeButtonOutlet;

-(id)initWithPlistName:(NSString *)name indexInPlist:(NSString *)index switchName:(NSString *)switchName detailDict:(NSDictionary *)detailDict
{
    self = [self init];
    
    if (self)
    {
        plistName = name;
        indexInPlist = index;
        LikeItems *likeItemsSharedInstance = [LikeItems sharedInstance];
        [self setSwitchWithName:switchName detailDict:detailDict];
        [likeItemsSharedInstance itemIsInLikeArrayWithPlistName:plistName indexInPlist:indexInPlist completion:^(BOOL isExist)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (isExist == YES)
                 {
                     [likeButtonOutlet setSelected:YES];
                 }
                 else
                 {
                     [likeButtonOutlet setSelected:NO];
                 }
             });
         }];
        
    }
    
    return self;
}

-(id)initWithPlistName:(NSString *)name indexInPlist:(NSString *)index switchName:(NSString *)switchName detailDict:(NSDictionary *)detailDict reuseIdentifier:(NSString *)reuseId
{
    self = [self initWithPlistName:name indexInPlist:index switchName:switchName detailDict:detailDict];
    if (self)
    {
        cellReuseIdentifier = reuseId;
    }
    return self;
}

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"BLSwitchCell" owner:self options:nil] objectAtIndex:0];
    if (self)
    {
        // any further initialization
        tunnellingShareInstance = [BLGCDKNXTunnellingAsyncUdpSocket sharedInstance];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    //NSLog(@"self.frame = %@", self.frame);
    
    // Example of a bigger switch with images
    switchButton = [[SevenSwitch alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.frame.size.width * 0.75, self.frame.origin.y + self.frame.size.height * 0.25, 143 * 0.5, 52 * 0.5)];
    //switchButton.center = CGPointMake(self.frame.size.width * 0.5 + self.frame.origin.x, self.frame.size.height * 0.5 - 80 + self.frame.origin.y);
    [switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventValueChanged];
    UIImage *image = [UIImage imageNamed: @"OffText.png"];
    
    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
    BOOL hasAlpha = false;
    CGFloat scale =  0.0; // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    //image.drawInRect(CGRect(origin: CGPointZero, size: size));
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    switchButton.offImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    //image = UIImage(named: "OnText.png");
    image = [UIImage imageNamed: @"OnText.png"];
    
    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
    hasAlpha = false;
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    switchButton.onImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //mySwitch2.offImage = UIImage(named: "OffText.png")
    //mySwitch2.onImage = UIImage(named: "OnText.png")
    
    
    //image = UIImage(named: "SwitchButton.png");
    image = [UIImage imageNamed: @"SwitchButton.png"];
    
    size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
    hasAlpha = true;
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    switchButton.thumbImage  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //mySwitch2.thumbImage = UIImage(named: "SwitchButton")
    //mySwitch2.thumbView.layer.cornerRadius =
    //mySwitch2.thumbTintColor = UIColor.clearColor()
    switchButton.backgroundColor = [UIColor blackColor];
    switchButton.onTintColor = [UIColor blackColor];
    switchButton.borderColor = [UIColor blackColor];
    switchButton.layer.cornerRadius = 15;
    [self addSubview:switchButton];
    
    // turn the switch on with animation
    [switchButton setOn:YES animated:YES];
    
    
    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIImage imageNamed:@"CellBackground"] drawInRect:self.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundColor = [UIColor clearColor];
    self.separatorInset = UIEdgeInsetsZero;
    
    //self.separatorInset = UIEdgeInsetsZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)reuseIdentifier
{
    return cellReuseIdentifier;
}

- (void)setSwitchWithName:(NSString *)switchName detailDict:(NSDictionary *)detailDict
{
    switchNameLabel.text = switchName;
    itemDetailDict = detailDict;
    
    writeToGroupAddress = [itemDetailDict[@"WriteToGroupAddress"] objectForKey:@"0"];
    readFromGroupAddress = [itemDetailDict[@"ReadFromGroupAddress"] objectForKey:@"0"];
    itemValueLength = [itemDetailDict objectForKey:@"ValueLength"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tunnellingConnectSuccess) name:TunnellingConnectSuccessNotification object:nil];
}

- (void)readItemState
{
    if (readFromGroupAddress == nil)
    {
        return;
    }
    
    NSLog(@"ReadFromGroupAddress =  %@", readFromGroupAddress);
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:readFromGroupAddress value:0 buttonName:nil valueLength:itemValueLength commandType:@"Read"];
}

- (IBAction)switchButtonPressed:(UISwitch *)sender
{
    NSInteger transmitValue;
    
    if ([itemValueLength isEqualToString:@"1Bit"])
    {
        if ([sender isOn])
        {
            transmitValue = 1;
        }
        else
        {
            transmitValue = 0;
        }
    }
    else
    {
        return;
    }
    
    NSLog(@"WriteToGroupAddress =  %@, value = %ld", writeToGroupAddress, (long)transmitValue);
    [tunnellingShareInstance tunnellingSendWithDestGroupAddress:writeToGroupAddress value:transmitValue buttonName:nil valueLength:itemValueLength commandType:@"Write"];
    
    
}

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    LikeItems *likeItemsSharedInstance = [LikeItems sharedInstance];
    if ([sender isSelected])
    {
        [likeItemsSharedInstance removeItemFromLikeArrayWithPlistName:plistName indexInPlist:indexInPlist];
        [sender setSelected:NO];
    }
    else
    {
        [likeItemsSharedInstance addItemToLikeArrayWithPlistName:plistName indexInPlist:indexInPlist itemName:switchNameLabel.text detailDict:itemDetailDict];
        [sender setSelected:YES];
    }
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    if ([dict[@"Address"] isEqualToString:readFromGroupAddress])
    {
        NSUInteger value = [dict[@"Value"] intValue];
        NSLog(@"receive value = %lu", (unsigned long)value);
        
        dispatch_async(dispatch_get_main_queue(),
        ^{
            if (value == 0)
            {
                [switchButton setOn:NO animated:YES];
            }
            else if(value == 1)
            {
                [switchButton setOn:YES animated:YES];
            }
        });
    }
}

- (void) tunnellingConnectSuccess
{
    [self readItemState];
}

@end
