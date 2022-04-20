//
//  LocalStore.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/17.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "LocalStore.h"
#define OMRON_DEMO_DEVICE_LIST  @"devicelist"
@implementation LocalStore
+(BOOL)store:(NSString *)num name:(NSString *)name userIndex:(NSString *)userIndex userInfo:(NSDictionary *)userInfo
{
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSArray *curArray = [device valueForKey:OMRON_DEMO_DEVICE_LIST];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *values = @[name,userIndex];
    [dic setValue:values forKey:[NSString stringWithFormat:@"%@@%@",num,userIndex]];
    NSMutableArray *array;
    BOOL isExists = false;
    array = [NSMutableArray array];
    NSString *key = [NSString stringWithFormat:@"%@@%@",num,userIndex];
    for (NSDictionary *dic in curArray) {
        if([dic.allKeys containsObject:key])
        {
            isExists = YES;
        }
        else
        {
            [array addObject:dic];
        }
    }
    [array addObject:dic];
    [device setValue:array forKey:OMRON_DEMO_DEVICE_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return true;
}

+(void)storeUserInfo:(NSDictionary *)userInfo
{
    NSUserDefaults *userinfos = [NSUserDefaults standardUserDefaults];
    [userinfos setValue:userInfo forKey:@"DeviceUserInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getUserInfo
{
    NSUserDefaults *userInfos = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [userInfos valueForKey:@"DeviceUserInfo"];
    return userInfo;
}

+(NSArray *)getDeviceStore
{
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSArray *curArray = [device valueForKey:OMRON_DEMO_DEVICE_LIST];
    return curArray;
}

+(BOOL)delTargetDevice:(NSString *)num
{
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSArray *curArray = [device valueForKey:OMRON_DEMO_DEVICE_LIST];
    NSMutableArray *newArray = [NSMutableArray array];
    for (NSDictionary *dic in curArray)
    {
        if(![dic.allKeys containsObject:num])
        {
            [newArray addObject:dic];
        }
    }
    [device setValue:newArray forKey:OMRON_DEMO_DEVICE_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}
@end
