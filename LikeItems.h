//
//  LikeItems.h
//  BLSmartPhoneDemo
//
//  Created by Landyu on 15/11/6.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LikeItems : NSObject
{
@public
    BOOL likeItemsNeedToOverWrite;
}
+ (instancetype)sharedInstance;
- (void) addItemToLikeArrayWithPlistName:(NSString *)plistName indexInPlist:(NSString *)indexInPlist itemName:(NSString *)itemName detailDict:(NSDictionary *)detailDict;
- (void) removeItemFromLikeArrayWithPlistName:(NSString *)plistName indexInPlist:(NSString *)indexInPlist;
- (void) itemIsInLikeArrayWithPlistName:(NSString *)plistName indexInPlist:(NSString *)index completion:(void(^)(BOOL isExist))completion;
- (BOOL)rearrangeLikeItemArray;
- (BOOL)rearrangeLikeItemArray2;
- (void)setLikeItemsArrayWithArray:(NSMutableArray *)array;
- (NSMutableArray *)getLikeItemsArrayWithArray;
- (NSArray *)getAvailableSectionTitleArray;
- (NSArray *)getCertainItemsWithItemType:(NSString *)itemType;

- (NSArray *)getAvailableRooms;
- (NSInteger)getItemNumbersOfRoomWithRoomName:(NSString *)roomName;
@end


@interface LikeItemPacket: NSObject
{
@public
    NSString *plistName;
    NSString *indexInPlist;
    NSString *itemName;
    NSDictionary *itemDetailDict;
}
@end

@interface RoomItemsPacket: NSObject
{
@public
    NSString *roomName;
    //NSString *indexInPlist;
    //NSString *itemName;
    NSDictionary *itemDetailDict;
    
    NSMutableArray *lights;
    NSMutableArray *ACs;
    NSMutableArray *Curtains;
}
-(void)setAvailableSectionTitleArray;
@end