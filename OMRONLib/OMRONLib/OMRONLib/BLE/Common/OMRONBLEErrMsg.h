//
//  OMRONBLEErrMsg.h
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#define OMRON_BLE_ERROR_BT_IS_CLOSED                @"蓝牙未打开"
#define OMRON_BLE_ERROR_NOT_SUPPORT_BLE             @"不支持BLE"
#define OMRON_BLE_ERROR_DEVICE_SCAN_FAILED          @"设备扫描失败"
#define OMRON_BLE_ERROR_DEVICE_BOND_FAILED          @"设备配对失败"
#define OMRON_BLE_ERROR_FOUND_SERVICE_FAILED        @"发现服务失败"
#define OMRON_BLE_ERROR_READ_BG_DATA_FAILED         @"血压数据读取失败"
#define OMRON_BLE_ERROR_READ_BATERY_FAILED          @"获取电池信息失败"

@interface OMRONBLEErrMsg : NSObject
@property (nonatomic, assign) NSInteger errorId;
@property (nonatomic, copy)   NSString  *errorMsg;
@property (nonatomic, assign) BOOL isExistError;
-(OMRONBLEErrMsg *)initWithMsg:(NSString *)msg;
-(OMRONBLEErrMsg *)initWithMsgAndId:(NSInteger)errorId msg:(NSString *)msg;
+(OMRONBLEErrMsg *)errorWithMsg:(NSString *)msg;
+(OMRONBLEErrMsg *)errorWithMsdAndId:(NSInteger)errorId msg:(NSString *)msg;
@end
