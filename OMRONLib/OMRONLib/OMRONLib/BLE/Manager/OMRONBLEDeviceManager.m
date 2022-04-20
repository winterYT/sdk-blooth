//
//  OMRONBLEDeviceManager.m
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import "OMRONBLEDeviceManager.h"

@interface OMRONBLEDeviceManager()
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) OMRONBLEBPDevice  *bpDevice;
@property (nonatomic, assign) int timeout;
@property (nonatomic, assign) int retryTimes;
@property (nonatomic, assign) BOOL isLoop;

@end

@implementation OMRONBLEDeviceManager
/**
 *  单例对象实现
 *
 *  @return 返回单例对象
 */
+(instancetype)getBLEDevManager
{
    static OMRONBLEDeviceManager *share;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[OMRONBLEDeviceManager alloc] init];
    });
    return share;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.peripherals = [[NSMutableArray alloc] init];
        self.bpDevice = [OMRONBLEBPDevice shareInstance];
        _timeout = 10;
        _retryTimes =3;
        _isLoop = false;
    }
    
    return self;
}

-(void)scan:(OMRONDeviceType)type success:(void (^)(OMRONBLEBPDevice *))success failture:(void (^)(OMRONBLEErrMsg *))failture
{
    __weak typeof(self) weakSelf = self;
    [weakSelf.bpDevice setBlockOnDIscoverPeripheralsFailed:^(OMRONBLEErrMsg *errorMsg) {
        failture(errorMsg);
    }];
    
    void(^scanBlock)(void)=^{
        [weakSelf.bpDevice setBlockOnDisCoverPeripheralsByDeviceType:^(CBCentralManager *central, OMRONBLEDevice *bleDevice, NSDictionary *advertisementData, NSNumber *RSSI) {
            [weakSelf.peripherals addObject:bleDevice];
            NSString *advertisingName = [advertisementData valueForKey:Advertising_Name];
            if (advertisingName!=nil) {
                if ([[[OMRONBLEBPDevice getAdvertisingName:type] uppercaseString] containsString:[[advertisingName substringToIndex:17] uppercaseString]]) {
                    [weakSelf.bpDevice->manager stopScan];
                    weakSelf.bpDevice.macAddress=[advertisingName substringFromIndex:[OMRONBLEBPDevice getAdvertisingName:type].length];
                    weakSelf.bpDevice.advertisingName = advertisingName;
                    success((OMRONBLEBPDevice *)bleDevice);
                }
            }
        }];
        
        [weakSelf.bpDevice scanForPeripherals:weakSelf.timeout retryTimes:weakSelf.retryTimes isLoop:weakSelf.isLoop];
    };
    if (self.bpDevice->manager.state == CBCentralManagerStatePoweredOn) {
        scanBlock();
    }
    else
    {
        [self.bpDevice setBlockOnPeripheralDidUpdateState:^(CBCentralManager *central, OMRONBLEErrMsg *error) {
            if (error.isExistError) {
                failture(error);
            }
            else
            {
                scanBlock();
            }
        }];
    }
}

-(void)scan:(OMRONDeviceType)type deviceMacAddress:(NSString *)deviceMacAddress success:(void(^)(OMRONBLEBPDevice *device))success failture:(void(^)(OMRONBLEErrMsg *error))failture
{
    __weak typeof(self) weakSelf = self;
    [weakSelf.bpDevice setBlockOnDIscoverPeripheralsFailed:^(OMRONBLEErrMsg *errorMsg) {
        failture(errorMsg);
    }];
    
    void(^scanBlock)(void)=^{
        [weakSelf.bpDevice setBlockOnDisCoverPeripheralsByDeviceType:^(CBCentralManager *central, OMRONBLEDevice *bleDevice, NSDictionary *advertisementData, NSNumber *RSSI) {
            [weakSelf.peripherals addObject:bleDevice];
            NSString *advertisingName = [advertisementData valueForKey:Advertising_Name];
            if (advertisingName!=nil) {
                if ([[[OMRONBLEBPDevice getAdvertisingName:type] uppercaseString] containsString:[[advertisingName substringToIndex:17] uppercaseString]]) {
                    if (advertisingName.length>[OMRONBLEBPDevice getAdvertisingName:type].length) {
                        if ([deviceMacAddress isEqualToString:[advertisingName substringFromIndex:[OMRONBLEBPDevice getAdvertisingName:type].length]]) {
                            [weakSelf.bpDevice->manager stopScan];
                            success((OMRONBLEBPDevice *)bleDevice);
                        }
                    }
                }
            }
        }];
        
        [weakSelf.bpDevice scanForPeripherals:weakSelf.timeout retryTimes:weakSelf.retryTimes isLoop:weakSelf.isLoop];
    };
    if (self.bpDevice->manager.state == CBCentralManagerStatePoweredOn) {
        scanBlock();
    }
    else
    {
        [self.bpDevice setBlockOnPeripheralDidUpdateState:^(CBCentralManager *central, OMRONBLEErrMsg *error) {
            if (error.isExistError) {
                failture(error);
            }
            else
            {
                scanBlock();
            }
        }];
    }
}

/**
 *  扫描超时时间
 *
 *  @param timeout timeout description
 */
-(void)setScanTime:(int)timeout
{
    if (timeout>0) {
        _timeout = timeout;
    }
}

/**
 *  从新扫描次数
 *
 *  @param count <#count description#>
 */
-(void)setScanRetry:(int)count
{
    if (count>0) {
        _retryTimes = count;
    }
}

/**
 *  是否循环扫描
 *
 *  @param isLoop isLoop description
 */
-(void)setScanLoop:(BOOL)loop
{
    _isLoop =loop;
}

/**
 *  停止扫描
 */
-(void)stopScan
{
    [self.bpDevice stopScanPeripherals];
}

-(void)unbindDevice:(NSString *)uuid
{
    [self.bpDevice resetPeripherals];
}
#pragma mark private method

@end
