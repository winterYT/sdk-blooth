//
//  OMRONBLEDeviceManager.h
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMRONBLEErrMsg.h"
#import "OMRONBLEBPDevice.h"
@interface OMRONBLEDeviceManager : NSObject
/**
 *  管理类
 *
 *  @return 单例对象
 */
+(instancetype)getBLEDevManager;


/**
 *  按照设备型号搜索
 *
 *  @param type     设备型号
 *  @param success  扫描成功
 *  @param failture 扫描失败
 */
-(void)scan:(OMRONDeviceType)type success:(void(^)(OMRONBLEBPDevice *device))success failture:(void(^)(OMRONBLEErrMsg *error))failture;

/*
 *  @param type  设备型号
 *  @param deviceMacAddress  设备Mac Address
 *  @param success  扫描成功
 *  @param failture 扫描失败
 */
-(void)scan:(OMRONDeviceType)type deviceMacAddress:(NSString *)deviceMacAddress success:(void(^)(OMRONBLEBPDevice *device))success failture:(void(^)(OMRONBLEErrMsg *error))failture;

/**
 *  设置扫描超时时间
 *
 *  @param timeout 超时时间/单位(秒)
 */
-(void)setScanTime:(int)timeout;

/**
 *  扫描Retry次数设置
 *
 *  @param count Retry 次数
 */
-(void)setScanRetry:(int)count;

/**
 *  是否循环扫描
 *
 *  @param loop 是否循环
 */
-(void)setScanLoop:(BOOL)loop;

/**
 *  停止扫描
 */
-(void)stopScan;

-(void)unbindDevice:(NSString *)uuid;
@end
