//
//  OMRONBLEDevice.m
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import "OMRONBLEDevice.h"
#import "OMRONBLECallbackBase.h"

@interface OMRONBLEDevice()
@end

@implementation OMRONBLEDevice
{
    dispatch_source_t      timerScan;
    NSMutableArray         *results;
    BOOL                   isHasData;
}
#pragma mark init method
-(instancetype)init
{
    self = [super init];
    if (self) {
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@NO};
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options];
        self.baseCallBack = [[OMRONBLECallbackBase alloc] init];
        results = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark public mmethods
-(void)scanForPeripherals:(int)timeout retryTimes:(int)retryTimes isLoop:(BOOL)isLoop
{
    self.basebleDevice = nil;
    [manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    __weak typeof(self) weakSelf = self;
    NSDate *SendCodeDate = [NSDate date];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    timerScan = timer;
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), timeout * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        int since =  [[NSDate date] timeIntervalSinceDate:SendCodeDate];
        if (since/timeout<=(retryTimes-1) && since/timeout>0) {
//            NSLog(@"retryTimes is %d",since);
            if (self->manager.state==CBManagerStatePoweredOn) {
                [self->manager stopScan];
                [self->manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
            }
        }
        
        if (since/timeout>=retryTimes|| self.basebleDevice!=nil) {
            [self->manager stopScan];
//            NSLog(@"retryTimes stop is %d",since);
            if (self.basebleDevice==nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.blockOnDIscoverPeripheralsFailed) {
                        [weakSelf blockOnDIscoverPeripheralsFailed]([OMRONBLEErrMsg errorWithMsg:@"未找到设备"]);
                    }
                });
            }
            dispatch_source_cancel(timer);
        }
    });
    
    dispatch_resume(timer);
}

-(void)stopScanPeripherals
{
    self.blockOnDisCoverPeripheralsByDeviceType = nil;
    if (timerScan!=nil) {
        dispatch_source_cancel(timerScan);
    }
    [manager stopScan];
}

-(void)resetPeripherals
{
//    NSArray *array = [manager retrievePeripheralsWithIdentifiers:@[[[NSUUID UUID] initWithUUIDString:@"37B8A4E5-9786-E3E4-C57C-E2E4E4F8D05F"]]];
//    for (CBPeripheral *cb in array) {
//        [manager cancelPeripheralConnection:cb];
//    }
}

-(void)connect:(CBPeripheral *)device success:(void (^)(OMRONBLEDeviceState))success failture:(void (^)(OMRONBLEErrMsg *))failture
{
    if (device.state == CBPeripheralStateConnected) {
        success(STATE_CONNECTED);
        return;
    }
    
    [self setBlockOnConnectPeripheralState:^(OMRONBLEDeviceState state) {
        success(state);
    }];
    [self.baseCallBack setBlockFailture:failture];
    [manager connectPeripheral:device options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES,CBCentralManagerOptionShowPowerAlertKey:@YES,CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}

-(void)disCoverService:(NSArray *)services
{
    [self.basebleDevice discoverServices:services];
}

-(void)disconnect:(void (^)(OMRONBLEDeviceState))bleDeviceState
{
    if (self.basebleDevice!=nil) {
        [manager cancelPeripheralConnection:self.basebleDevice];
        self.basebleDevice = nil;
    }
    
    self.blockOnPeripheralDidUpdateState=nil;
    self.blockOnDisCoverPeripheralsByDeviceType=nil;
    self.blockOnDIscoverPeripheralsFailed=nil;
    self.blockOnConnectPeripheralState=nil;
    self.blockOnDiscoverPressureService=nil;
    self.blockOnDiscoverDeviceInfoService=nil;
    self.blockOnDiscoverDeviceInfoCharcteristics=nil;
    self.blockOnDiscoverMesaureCharcteristics=nil;
    self.blockOnMesaureCharcteristicsResponse=nil;
    self.blockOnDiscoverPressureBatteryService=nil;
    self.blockOnDiscoverGluCoseBatteryCharacteristics=nil;
    bleDeviceState(STATE_DISCONNECTED);
}

-(void)getDevInfo
{
    //#warning 暂不实现
}

#pragma mark 代理方法
/**
 *  设备状态改变
 *
 *  @param central <#central description#>
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *result = @"";
    switch (central.state) {
        case CBManagerStateUnknown:
            result = @"未知状态";
            break;
        case CBManagerStateResetting:
            result = @"重置";
            break;
        case CBManagerStateUnsupported:
            result = @"当前设备不支持蓝牙";
            break;
        case CBManagerStateUnauthorized:
            result = @"蓝牙未授权";
            break;
        case CBManagerStatePoweredOff:
            result = @"蓝牙未开启";
            break;
        case CBManagerStatePoweredOn:
            break;
    }
    if (self.blockOnPeripheralDidUpdateState) {
        [self blockOnPeripheralDidUpdateState](central,[OMRONBLEErrMsg errorWithMsdAndId:10001 msg:result]);
    }
}

/**
 *  扫描到设备
 *
 *  @param central           中心对象
 *  @param peripheral        外设对象
 *  @param advertisementData <#advertisementData description#>
 *  @param RSSI              信号信息
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@",peripheral.name);
    if ([peripheral.name containsString:@"HEM"]||[peripheral.name containsString:@"BLEsmart"]||[peripheral.name containsString:@"U32J"]||[peripheral.name containsString:@"J750"]||[peripheral.name containsString:@"J731"]||[peripheral.name containsString:@"BLEsmart_0000033C"]||[peripheral.name containsString:@"J761"]||[peripheral.name containsString:@"9200L"]||[peripheral.name containsString:@"U18"]||[peripheral.name containsString:@"J760"]||[peripheral.name containsString:@"T50"]||[peripheral.name containsString:@"U32"]||[peripheral.name containsString:@"J732"]||[peripheral.name containsString:@"J751"]||[peripheral.name containsString:@"U36J"]||[peripheral.name containsString:@"U36T"]||[peripheral.name containsString:@"6231T"]) {
        self.basebleDevice = peripheral;
        [self.basebleDevice setDelegate:self];
        if (self.blockOnDisCoverPeripheralsByDeviceType) {
            [self blockOnDisCoverPeripheralsByDeviceType](central,self,advertisementData,RSSI);
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (self.blockOnConnectPeripheralState) {
        switch (peripheral.state) {
            case CBPeripheralStateDisconnected:
                [self blockOnConnectPeripheralState](STATE_DISCONNECTED);
                break;
            case CBPeripheralStateConnecting:
                [self blockOnConnectPeripheralState](STATE_CONNECTING);
                break;
            case CBPeripheralStateConnected:
                [self blockOnConnectPeripheralState](STATE_CONNECTED);
                break;
            case CBPeripheralStateDisconnecting:
                [self blockOnConnectPeripheralState](STATE_DISCONNECTED);
                break;
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    NSLog(@"connect failed error is %@",error);
    if (self.baseCallBack.blockFailture) {
        [self.baseCallBack blockFailture]([OMRONBLEErrMsg errorWithMsdAndId:10002 msg:@"连接失败"]);
    }
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.basebleDevice = nil;
//    NSLog(@"disconnect error is %@",error);
    if (self.blockOnMesaureCharcteristicsResponse) {
        if (results.count>0||!isHasData) {
            [self blockOnMesaureCharcteristicsResponse](results);
        }
    }
    if (self.baseCallBack.blockFailture) {
        [self stopScanPeripherals];
        if(error.code==6)
        {
            [self.baseCallBack blockFailture]([OMRONBLEErrMsg errorWithMsdAndId:10004 msg:@"PIN码错误"]);
        }
        else
        {
            [self.baseCallBack blockFailture]([OMRONBLEErrMsg errorWithMsdAndId:10003 msg:@"连接断开"]);
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
//        NSLog(@"didDiscoverServices error is %@",error);
    }
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:Pressure_Service]) {
            if (self.blockOnDiscoverPressureService) {
                [self blockOnDiscoverPressureService](self,service);
                self.blockOnDiscoverPressureService = nil;
            }
        }
        else if ([service.UUID.UUIDString isEqualToString:Pressure_Device_Info]) {
            if (self.blockOnDiscoverDeviceInfoService) {
                [self blockOnDiscoverDeviceInfoService](self,service);
                self.blockOnDiscoverDeviceInfoService = nil;
            }
        }
        else
        {
            if ([service.UUID.UUIDString isEqualToString:Battery_Service]) {
                if (self.blockOnDiscoverPressureBatteryService) {
                    [self blockOnDiscoverPressureBatteryService](self,service);
                    self.blockOnDiscoverPressureBatteryService = nil;
                }
            }
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
//        NSLog(@"discover Characteristics for service error is %@",error);
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:Battery_UUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            if (characteristic.value!=nil) {
                if (self.blockOnDiscoverGluCoseBatteryCharacteristics) {
                    [self blockOnDiscoverGluCoseBatteryCharacteristics](characteristic);
                    self.blockOnDiscoverGluCoseBatteryCharacteristics=nil;
                }
            }
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:SerialNumber]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [self.basebleDevice readValueForCharacteristic:characteristic];
        }
        else if([characteristic.UUID.UUIDString isEqualToString:Pressure_Measure_Characteristic])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
//        NSLog(@"didUpdateNotificationStateForCharacteristic error is %@",error);
    }
    
    if ([characteristic.UUID.UUIDString isEqualToString:Battery_UUID]) {
        if (characteristic.value!=nil) {
            if (self.blockOnDiscoverGluCoseBatteryCharacteristics) {
                [self blockOnDiscoverGluCoseBatteryCharacteristics](characteristic);
                self.blockOnDiscoverGluCoseBatteryCharacteristics=nil;
            }
        }
        else
        {
            [self.basebleDevice readValueForCharacteristic:characteristic];
        }
    }
    
    if([characteristic.UUID.UUIDString isEqualToString:SerialNumber])
    {
        [self.basebleDevice readValueForCharacteristic:characteristic];
    }
    
    if([characteristic.UUID.UUIDString isEqualToString:Pressure_Measure_Characteristic])
    {
        if (self.blockOnDiscoverMesaureCharcteristics) {
            [self blockOnDiscoverMesaureCharcteristics](characteristic);
            self.blockOnDiscoverMesaureCharcteristics=nil;
            results=[[NSMutableArray alloc] init];
            isHasData=false;
//            NSLog(@"Pressure_Measure_Characteristic Notify is YES");
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
//        NSLog(@"didUpdateValueForCharacteristic error is %@",error);
    }
    
    if([characteristic.UUID.UUIDString isEqualToString:SerialNumber])
    {
        if (characteristic.value!=nil){
            if (self.blockOnDiscoverDeviceInfoCharcteristics) {
                [self blockOnDiscoverDeviceInfoCharcteristics](characteristic);
                self.blockOnDiscoverDeviceInfoCharcteristics=nil;
            }
        }
    }
    
    if ([characteristic.UUID.UUIDString isEqualToString:Pressure_Measure_Characteristic]){
//        NSLog(@"Measure Characteristic is %@",characteristic.value);
        [results addObject:characteristic.value];
        isHasData=true;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    if (error) {
//        NSLog(@"didUpdateValueForDescriptor error is %@",error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
//        NSLog(@"didDiscoverDescriptorsForCharacteristic error is %@",error);
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    if (error) {
//        NSLog(@"didWriteValueForDescriptor error is %@",error);
    }
}
@end
