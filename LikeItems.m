//
//  LikeItems.m
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/6.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "LikeItems.h"


@interface LikeItemPacket()<NSCoding>
@end

@implementation LikeItemPacket
- (instancetype) init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)encode
{
    [encode encodeObject:self->plistName    forKey:@"kPlistName"];
    [encode encodeObject:self->indexInPlist    forKey:@"kIndexInPlist"];
    [encode encodeObject:self->itemName    forKey:@"kItemName"];
    [encode encodeObject:self->itemDetailDict    forKey:@"kItemDetailDict"];
    
}
- (nullable instancetype)initWithCoder:(NSCoder *)decoder // NS_DESIGNATED_INITIALIZER
{
    self->plistName     = [decoder decodeObjectForKey:@"kPlistName"];
    self->indexInPlist  = [decoder decodeObjectForKey:@"kIndexInPlist"];
    self->itemName      = [decoder decodeObjectForKey:@"kItemName"];
    self->itemDetailDict    = [decoder decodeObjectForKey:@"kItemDetailDict"];
    return self;
}

@end

@interface LikeItems()
{
    NSMutableArray *likeItemsArray;
    dispatch_queue_t likeItemProcessSerialQueue;
    
    NSMutableArray *rooms;
    NSMutableArray *lights;
    NSMutableArray *ACs;
    NSMutableArray *Curtains;
    NSArray *itemGroup;
    NSMutableArray *availableSectionTitleArray;
    NSArray *itemCatagory;
    
    NSInteger sectionNumber;
    
    BOOL likeItemsChanged;
}

@end

@implementation LikeItems

+ (instancetype)sharedInstance
{
    // 1
    static LikeItems *_sharedInstance = nil;

    // 2
    static dispatch_once_t oncePredicate;

    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LikeItems alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (likeItemsArray == nil)
        {
            likeItemsArray  = [[NSMutableArray alloc] init];
        }
        likeItemProcessSerialQueue = dispatch_queue_create("LikeItemProcessSerialQueueSerial", DISPATCH_QUEUE_SERIAL);
        
        rooms = [[NSMutableArray alloc] init];
        lights = [[NSMutableArray alloc] init];
        ACs = [[NSMutableArray alloc] init];
        Curtains = [[NSMutableArray alloc] init];
        itemGroup = [[NSArray alloc] initWithObjects:lights, ACs, Curtains, nil];
        itemCatagory = [[NSArray alloc] initWithObjects:@"灯光", @"空调",@"窗帘",nil];
        
        likeItemsChanged = NO;
        likeItemsNeedToOverWrite = NO;
    }
    
    return self;
}


- (void) addItemToLikeArrayWithPlistName:(NSString *)plistName indexInPlist:(NSString *)indexInPlist itemName:(NSString *)itemName detailDict:(NSDictionary *)detailDict
{
    LikeItemPacket *likeItemPacket = [[LikeItemPacket alloc] init];
    likeItemPacket->plistName = plistName;
    likeItemPacket->indexInPlist = indexInPlist;
    likeItemPacket->itemName = itemName;
    likeItemPacket->itemDetailDict = detailDict;
    
    dispatch_async(likeItemProcessSerialQueue, ^{
        [likeItemsArray addObject:likeItemPacket];
        likeItemsChanged = YES;
        likeItemsNeedToOverWrite = YES;
    });
    
}

- (void) removeItemFromLikeArrayWithPlistName:(NSString *)plistName indexInPlist:(NSString *)indexInPlist
{
    
    dispatch_async(likeItemProcessSerialQueue, ^{
        for (NSUInteger itemIndex = 0; itemIndex < [likeItemsArray count]; itemIndex++)
        {
            LikeItemPacket *likeItemPacket = likeItemsArray[itemIndex];
            if ([likeItemPacket->plistName isEqualToString:plistName] && [likeItemPacket->indexInPlist isEqualToString:indexInPlist])
            {
                [likeItemsArray removeObjectAtIndex:itemIndex];
                likeItemsChanged = YES;
                likeItemsNeedToOverWrite = YES;
                break;
            }
        }
    });
    
}

- (void) itemIsInLikeArrayWithPlistName:(NSString *)plistName indexInPlist:(NSString *)indexInPlist completion:(void(^)(BOOL isExist))completion
{
    dispatch_async(likeItemProcessSerialQueue, ^{
        BOOL isExist = NO;
        for (NSUInteger itemIndex = 0; itemIndex < [likeItemsArray count]; itemIndex++)
        {
            LikeItemPacket *likeItemPacket = likeItemsArray[itemIndex];
            if ([likeItemPacket->plistName isEqualToString:plistName] && [likeItemPacket->indexInPlist isEqualToString:indexInPlist])
            {
                isExist = YES;
                break;
            }
        }
        
        completion(isExist);
    });
}

- (void)setLikeItemsArrayWithArray:(NSMutableArray *)array
{
    if (array == nil)
    {
        return;
    }
    likeItemsArray = array;
    likeItemsChanged = YES;
}

- (NSMutableArray *)getLikeItemsArrayWithArray
{
    return likeItemsArray;
}

- (BOOL)rearrangeLikeItemArray
{
    if (likeItemsChanged == NO)
    {
        return NO;
    }
    [lights removeAllObjects];
    [ACs removeAllObjects];
    [Curtains removeAllObjects];
    
    for (LikeItemPacket *likeItemPacket in likeItemsArray)
    {
        NSDictionary *itemDetailDict = likeItemPacket->itemDetailDict;
        NSString *objectType = [itemDetailDict objectForKey:@"objectType"];
        if ([objectType isEqualToString:@"Light"])
        {
            [lights addObject:likeItemPacket];
        }
        else if([objectType isEqualToString:@"AC"])
        {
            [ACs addObject:likeItemPacket];
        }
        else if([objectType isEqualToString:@"Curtain"])
        {
            [Curtains addObject:likeItemPacket];
        }
        
    }
    
    sectionNumber = 0;
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
    
    likeItemsChanged = NO;
    return YES;
}

- (BOOL)rearrangeLikeItemArray2
{
    if (likeItemsChanged == NO)
    {
        return NO;
    }
    
    [rooms removeAllObjects];
    
    for (LikeItemPacket *likeItemPacket in likeItemsArray)
    {
        BOOL roomExist = NO;
        for (RoomItemsPacket *roomItemsPacket in rooms)
        {
            if ([roomItemsPacket->roomName isEqualToString:likeItemPacket->plistName])
            {
                roomExist = YES;
                roomItemsPacket->itemDetailDict = likeItemPacket->itemDetailDict;
                NSString *objectType = [roomItemsPacket->itemDetailDict objectForKey:@"objectType"];
                if ([objectType isEqualToString:@"Light"])
                {
                    [roomItemsPacket->lights addObject:likeItemPacket];
                }
                else if([objectType isEqualToString:@"AC"])
                {
                    [roomItemsPacket->ACs addObject:likeItemPacket];
                }
                else if([objectType isEqualToString:@"Curtain"])
                {
                    [roomItemsPacket->Curtains addObject:likeItemPacket];
                }

            }
        }
        
        if (roomExist == NO)
        {
            RoomItemsPacket *room = [[RoomItemsPacket alloc] init];
            room->roomName = likeItemPacket->plistName;
            room->itemDetailDict = likeItemPacket->itemDetailDict;
            NSString *objectType = [room->itemDetailDict objectForKey:@"objectType"];
            if ([objectType isEqualToString:@"Light"])
            {
                [room->lights addObject:likeItemPacket];
            }
            else if([objectType isEqualToString:@"AC"])
            {
                [room->ACs addObject:likeItemPacket];
            }
            else if([objectType isEqualToString:@"Curtain"])
            {
                [room->Curtains addObject:likeItemPacket];
            }

            [rooms addObject:room];
        }
        
    }
    
    
    for (RoomItemsPacket *roomItemsPacket in rooms)
    {
        [roomItemsPacket setAvailableSectionTitleArray];
    }
    
    likeItemsChanged = NO;
    return YES;

}

- (NSArray *)getAvailableRooms
{
    return rooms;
}

- (NSInteger)getItemNumbersOfRoomWithRoomName:(NSString *)roomName
{
    NSInteger itemNumber = 0;
    
    for (RoomItemsPacket *roomItemsPacket in rooms)
    {
         if ([roomItemsPacket->roomName isEqualToString:roomName])
         {
             itemNumber = [roomItemsPacket->lights count] + [roomItemsPacket->ACs count] + [roomItemsPacket->Curtains count];
         }
    }
    
    return itemNumber;
}

- (NSArray *)getAvailableSectionTitleArray
{
    return availableSectionTitleArray;
}

- (NSArray *)getCertainItemsWithItemType:(NSString *)itemType
{
    if ([itemType isEqualToString:@"灯光"])
    {
        return lights;
    }
    else if([itemType isEqualToString:@"空调"])
    {
        return ACs;
    }
    else if([itemType isEqualToString:@"窗帘"])
    {
        return Curtains;
    }
    
    return nil;

}


@end


@interface RoomItemsPacket()
{
    //NSString *roomName;
    NSArray *itemGroup;
    NSMutableArray *availableSectionTitleArray;
    NSArray *itemCatagory;
}
-(id)init;
@end

@implementation RoomItemsPacket

-(id) init
{
    self = [super init];
    if (self)
    {
        lights = [[NSMutableArray alloc] init];
        ACs = [[NSMutableArray alloc] init];
        Curtains = [[NSMutableArray alloc] init];
        itemGroup = [[NSArray alloc] initWithObjects:lights, ACs, Curtains, nil];
        itemCatagory = [[NSArray alloc] initWithObjects:@"灯光", @"空调",@"窗帘",nil];
    }
    
    return self;
}

-(void)setAvailableSectionTitleArray
{
    availableSectionTitleArray = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < [itemGroup count]; index++)
    {
        NSMutableArray *items = itemGroup[index];
        if ([items count])
        {
            [availableSectionTitleArray addObject:itemCatagory[index]];
        }
    }

}
@end
