//
//  TimmingItemTableViewCell.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/12/9.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "TimmingItemTableViewCell.h"

@interface TimmingItemTableViewCell()
{
    TimmingPacket *timmingData;
}

@end


@implementation TimmingItemTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UISwitch *enableSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(self.bounds.size.width, self.bounds.origin.y + 6, 10, self.bounds.size.height / 2.0)];
        [enableSwitch addTarget:self action:@selector(enableSwitchPressed:)  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:enableSwitch];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIGraphicsBeginImageContext(self.bounds.size);
        //UIGraphicsBeginImageContext(CGSizeMake(cell.bounds.size.width, cell.bounds.size.height - 3));
        [[UIImage imageNamed:@"CellBackground"] drawInRect:self.bounds];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.backgroundColor = [UIColor clearColor];
    }
    return  self;
}


- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTimmingData:(TimmingPacket *)data
{
    timmingData = data;
    NSMutableArray *availableRepeatDate = [[NSMutableArray alloc] init];
    NSArray *repeatDate = [[NSArray alloc] initWithObjects:@"每周日", @"每周一",  @"每周二", @"每周三", @"每周四", @"每周五", @"每周六",nil];
    BOOL repeatWeekend = YES;
    BOOL repeatWeekday = YES;
    BOOL everyday = YES;
    NSString *repeatDateDetail = @"";
    for (NSUInteger index = 0; index < [repeatDate count]; index++)
    {
        NSString *repeatDateKey = [repeatDate objectAtIndex:index];
        NSString *repeatValue = [timmingData->timmingRepeat objectForKey:repeatDateKey];
        
        if (repeatValue != nil)
        {
            if ([repeatDateKey  isEqualToString:@"每周日"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekend = repeatWeekend & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周一"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周二"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周三"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周四"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周五"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekday = repeatWeekday & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
            else if ([repeatDateKey  isEqualToString:@"每周六"])
            {
                if ([repeatValue isEqualToString:@"0"])
                {
                    everyday = everyday & NO;
                    repeatWeekend = repeatWeekend & NO;
                }
                else
                {
                    [availableRepeatDate addObject:repeatDateKey];
                }
            }
        }
    }
    
    if (everyday)
    {
        repeatDateDetail = [NSString stringWithFormat:@"每天"];
    }
    else if(repeatWeekday && ([availableRepeatDate count] <= 5))
    {
        repeatDateDetail = [NSString stringWithFormat:@"工作日"];;
    }
    else if(repeatWeekend && ([availableRepeatDate count] <= 2))
    {
        repeatDateDetail = [NSString stringWithFormat:@"每周末"];;
    }
    else
    {
        repeatDateDetail = [NSString stringWithString:[[availableRepeatDate valueForKey:@"description"] componentsJoinedByString:@","]];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSString *timmingTimeString = [formatter stringFromDate:timmingData->timmingDate];
    
    self.textLabel.text = timmingTimeString;
    self.textLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", timmingData->timmingLabelName, timmingData->timmingWriteToAddress, timmingData->timmingValueType, timmingData->timmingSendValue, repeatDateDetail];
    self.detailTextLabel.textColor = [UIColor whiteColor];
}

- (void)enableSwitchPressed:(UISwitch *)sender
{
    NSLog(@"%@ Enable......", self.detailTextLabel.text);
}

@end
