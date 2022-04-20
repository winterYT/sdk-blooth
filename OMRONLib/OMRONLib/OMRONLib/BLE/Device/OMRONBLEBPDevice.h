//
//  OMRONBLEBPDevice.h
//  OMRONBLELib
//
//  Created by Calvin on 14/11/2016.
//  Copyright © 2016 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMRONBLEDevice.h"
#import "OMRONLib.h"
@interface OMRONBLEBPDevice : OMRONBLEDevice
/**
 *  读取血压数据
 */
-(void)readData:(void(^)(NSArray *bpDatas))success failture:(void(^)(OMRONBLEErrMsg *errorMsg))failture;

/*
    获取血压设备通信ID
 */
-(void)readDeviceSerialNumber:(OMRONDeviceType)deviceType success:(void(^)(NSString *serialNum,NSString *macAddress,NSString *deviceName,NSString *advertisingName))success failture:(void(^)(OMRONBLEErrMsg *errorMsg))failture;

/**
 *  获取血压仪电量
 *
 *  @param success 返回电池电量
 */
-(void)readBatteryLevel:(void(^)(int battery))success failture:(void(^)(OMRONBLEErrMsg *errorMsg))failture;

/**
 *  <#Description#>
 *
 *  @param deviceType <#deviceType description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)getAdvertisingName:(OMRONDeviceType)deviceType;

/**
 *  <#Description#>
 *
 *  @param deviceType <#deviceType description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)getDeviceTypeName:(OMRONDeviceType)deviceType;

+(id)shareInstance;

@property (nonatomic, copy) NSString *macAddress;
@property (nonatomic, copy) NSString *advertisingName;
@end
