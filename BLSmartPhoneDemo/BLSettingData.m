//
//  BLPadSettingData.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/9/25.
//  Copyright © 2015年 Landyu. All rights reserved.
//

#import "BLSettingData.h"


@implementation BLSettingData

static NSString* const BLSettingDataDeviceIPAddressKey = @"deviceIPAddress";
static NSString* const BLSettingDataLikeItemsArrayKey = @"likeItemsArray";

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.deviceIPAddress forKey: BLSettingDataDeviceIPAddressKey];
    [encoder encodeObject:self.likeItemsArray forKey: BLSettingDataLikeItemsArrayKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _deviceIPAddress = [decoder decodeObjectForKey: BLSettingDataDeviceIPAddressKey];
        _likeItemsArray = [[decoder decodeObjectForKey: BLSettingDataLikeItemsArrayKey] mutableCopy];
        if (_likeItemsArray == nil)
            _likeItemsArray = [[NSMutableArray alloc] init];
        //NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
//        _likeItemsArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:BLSettingDataLikeItemsArrayKey];
//        if (_likeItemsArray)
//            _likeItemsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)sharedSettingData
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"settingdata.plist"];
    }
    return filePath;
}

+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [BLSettingData filePath]];
    if (decodedData) {
        BLSettingData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[BLSettingData alloc] init];
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[BLSettingData filePath] atomically:YES];
}

@end
