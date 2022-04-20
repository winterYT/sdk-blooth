//
//  OMRONBLEDevice.h
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OMRONBLEErrMsg.h"
#import "OMRONBLECallbackBase.h"
#define Advertising_Name @"kCBAdvDataLocalName"
#define Pressure_Device_Info    @"180A"
#define Generic_Access_Profile_Service @"1800"
#define Battery_Service @"180F"
#define Pressure_Service @"1810"
#define Pressure_Measure_Characteristic @"2A35"
#define Pressure_Measurement @"2A18"
#define Pressure_Measurement_Context @"2A34"
#define Pressure_Feature @"2A51"
#define Pressure_Record_Access_Control_Point @"2A52"
#define Battery_UUID @"2A19"
#define SerialNumber    @"2A25"
#define ModelNumber     @"2A24"
#define CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR_UUID @"2902"

/**
 *  设备状态
 */
typedef NS_ENUM(NSInteger, OMRONBLEDeviceState){
    /**
     *  连接中
     */
    STATE_CONNECTING,
    /**
     *  连接完成
     */
    STATE_CONNECTED,
    /**
     *  断开连接中
     */
    STATE_DISCONNECTING,
    /**
     *  断开连接
     */
    STATE_DISCONNECTED
};

@interface OMRONBLEDevice : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>{
    @public
    CBCentralManager *manager;
}
@property (nonatomic, copy) void(^blockOnPeripheralDidUpdateState)(CBCentralManager *central, OMRONBLEErrMsg *error);
@property (nonatomic, copy) void(^blockOnDisCoverPeripheralsByDeviceType)(CBCentralManager *central,OMRONBLEDevice *bleDevice,NSDictionary *advertisementData,NSNumber *RSSI);
@property (nonatomic, copy) void(^blockOnDIscoverPeripheralsFailed)(OMRONBLEErrMsg *error);
@property (nonatomic, copy) void(^blockOnConnectPeripheralState)(OMRONBLEDeviceState state);
@property (nonatomic, copy) void(^blockOnDiscoverPressureService)(OMRONBLEDevice *bleDevice,CBService *service);
@property (nonatomic, copy) void(^blockOnDiscoverDeviceInfoService)(OMRONBLEDevice *bleDevice,CBService *service);
@property (nonatomic, copy) void(^blockOnDiscoverDeviceInfoCharcteristics)(CBCharacteristic *characteristic);
@property (nonatomic, copy) void(^blockOnDiscoverMesaureCharcteristics)(CBCharacteristic *characteristic);
@property (nonatomic, copy) void(^blockOnMesaureCharcteristicsResponse)(NSMutableArray *characteristics);
@property (nonatomic, copy) void(^blockOnDiscoverPressureBatteryService)(OMRONBLEDevice *bleDevice,CBService *service);
@property (nonatomic, copy) void(^blockOnDiscoverGluCoseBatteryCharacteristics)(CBCharacteristic *characteristic);
@property (nonatomic, copy) CBPeripheral *basebleDevice;
@property (nonatomic, strong) OMRONBLECallbackBase *baseCallBack;

/**
 *  扫描外设
 */
-(void)scanForPeripherals:(int)timeout retryTimes:(int)retryTimes isLoop:(BOOL)isLoop;

/**
 *  连接外设
 *
 *  @param device         外设
 */
-(void)connect:(CBPeripheral *)device success:(void(^)(OMRONBLEDeviceState state))success failture:(void(^)(OMRONBLEErrMsg *errorConnect))failture;

/**
 *  终止通信
 *
 *  @param bleDeviceState 返回设备状态
 */
-(void)disconnect:(void(^)(OMRONBLEDeviceState state))bleDeviceState;

/**
 *  获取设备信息
 */
-(void)getDevInfo;

/**
 *  搜素服务
 *
 *  @param services 所搜索的外设
 */
-(void)disCoverService:(NSArray *)services;

/**
 *  停止扫描外设
 */
-(void)stopScanPeripherals;

-(void)resetPeripherals;
@end
