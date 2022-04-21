//
//  OMRONDeviceManager.m
//  OMRONLib
//
//  Created by Calvin on 2019/8/29.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "OMRONDeviceManager.h"
#import "OHQReferenceCode.h"
#import "OMRONLib.h"
#import "OMRONKeychainTool.h"
#import "OMRONBLEBPDevice.h"
typedef NS_ENUM(NSUInteger, SessionViewState) {
    SessionViewStateInitial,
    SessionViewStateWaitingForBluetoothToTurnOn,
    SessionViewStateConnecting,
    SessionViewStateProcessing,
    SessionViewStateCanceled,
    SessionViewStateTimedOut,
    SessionViewStateFinished,
};
static void * const KVOContext = (void *)&KVOContext;

@implementation OMRONBFAppendUserIndexData
-(void)appendUserIndex:(NSInteger)index
{
    if(self.block)
    {
        [self block](index);
    }
}
@end

@interface OMRONDeviceManager()


@property (assign, nonatomic) BSOProtocol protocol;
@property (strong, nonatomic) NSNumber *userIndex;
@property (assign, nonatomic) BOOL omronExtensionSupported;
@property (strong, nonatomic) BSOSessionData *data;
@property (assign, nonatomic) SessionViewState state;
@property (nullable, copy, nonatomic) NSDictionary<OHQUserDataKey,id> *userData;
@property (nullable, copy, nonatomic) NSDictionary<OHQSessionOptionKey,id> *options;
@property (strong, nonatomic) NSUUID *deviceIdentifier;
@property (strong, nonatomic) NSDictionary<OHQDeviceInfoKey,id> * deviceInfo;

@property (nullable, copy, nonatomic) NSArray<NSUUID *> *registeredDeviceUUIDs;
@property (assign, nonatomic) BOOL advertisementDataViewMode;
@property (assign, nonatomic) BOOL allowUserInteractionOfCategoryFilterSetting;
@property (assign, nonatomic) BOOL pairingModeDeviceOnly;
@property (assign, nonatomic) OHQDeviceCategory categoryToFilter;
@property (assign, nonatomic) NSInteger scanCount;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation OMRONDeviceManager
-(instancetype)init
{
    if(self = [super init])
    {
        
        _advertisementDataViewMode = NO;
        _allowUserInteractionOfCategoryFilterSetting = NO;
        _pairingModeDeviceOnly = YES;
        _categoryToFilter = OHQDeviceCategoryAny;
        self.deviceIdentifier = [[NSUUID alloc] init];
        self.deviceInfo = [[NSDictionary alloc] init];
        self.omronExtensionSupported = YES;
        self.protocol = (self.omronExtensionSupported ? BSOProtocolOmronExtension : BSOProtocolBluetoothStandard);
        self.userIndex = (self.omronExtensionSupported ? @1 : nil);
    }
    return self;
}

//扫描周围设备
- (void)scanAllBPDevicesComplete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete{
    _scanCount = 0;
    [[OHQDeviceManager sharedManager] scanForAllDevicesWithCategory:OHQDeviceCategoryBloodPressureMonitor usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        self->_scanCount ++;
        if (self->_scanCount > 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(deviceInfo!=nil)
                {
                    self.deviceInfo = deviceInfo;
                    NSString *localName = [[self.deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                    complete(OMRON_SDK_Success,self.deviceInfo[@"modelName"],deviceInfo[@"identifier"],localName);
                }
            });
        }
        
    } completion:^(OHQCompletionReason aReason) {
//        NSLog(@"reason====%lu",(unsigned long)aReason);
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled:
                {
//                    complete(OMRON_SDK_ScanTimeOut,@"",@"",@"");
                    [[OHQDeviceManager sharedManager] stopScan];
                    return;
                }
                    break;
                case OHQCompletionReasonBusy:
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                }
                    break;
                case OHQCompletionReasonPoweredOff:
                {
                    complete(OMRON_SDK_UnOpenBlueTooth,@"",@"",@"");
                    return;
                }
                    break;
                case OHQCompletionReasonConnectionTimedOut:
                {
                    complete(OMRON_SDK_ScanTimeOut,@"",@"",@"");
                    [[OHQDeviceManager sharedManager] stopScan];
                    return;
                }
                    break;
                default:
                    break;
            }
            
            if(self.deviceInfo==nil)
            {
                complete(OMRON_SDK_NoDevice,@"",@"",@"");
            }
            
        });
    }];
}

//血压根据deviceSerialNum绑定
- (void)bingBPDevice:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete {
    void(^readDataBlock)(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) = ^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo){
        NSUUID *uuid = deviceInfo[OHQDeviceInfoIdentifierKey];
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"uuid"];
//        NSLog(@"绑定-%@",uuid);
        self.options = [self bpDevice_bso_makeOptions:deviceInfo];
        self.data = [[BSOSessionData alloc] initWithIdentifier:uuid options:self.options];
        self.state = SessionViewStateConnecting;
        [[OHQDeviceManager sharedManager] startSessionWithDevice:uuid usingDataObserver:^(OHQDataType aDataType, id  _Nonnull data) {
            [self.data addSessionData:data withType:aDataType];
        } connectionObserver:^(OHQConnectionState aState) {
            if (aState == OHQConnectionStateConnected) {
                self.state = SessionViewStateProcessing;
            }
//            NSLog(@"绑定+++%lu",(unsigned long)aState);
        }completion:^(OHQCompletionReason aReason) {
            self.data.completionReason = aReason;
            
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonCanceled) {
                self.state = SessionViewStateCanceled;
                //                        complete(OMRON_SDK_ConnectFail,@"绑定血压设备:连接中取消",nil,nil,nil);
                complete(OMRON_SDK_ConnectFail,nil,nil,nil);
                return;
            }
            
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonConnectionTimedOut) {
                self.state = SessionViewStateTimedOut;
                //                        complete(OMRON_SDK_ConnectFail,@"绑定血压设备:连接中超时",nil,nil,nil);
                complete(OMRON_SDK_ConnectFail,nil,nil,nil);
                return;
            }
            self.state = SessionViewStateFinished;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BSOSessionData *data = self.data;
                
                NSString *advertisingName;
                if([deviceInfo objectForKey:@"advertisementData"]!=nil)
                {
                    advertisingName = [[deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
                }
                if (data.currentTime == nil) {
                    //                          complete(OMRON_SDK_ConnectFail,@"绑定血压设备:currentTime为nil",nil,nil,nil);
                    complete(OMRON_SDK_ConnectFail,nil,nil,nil);
                }else{                      complete(OMRON_SDK_Success,data.modelName,data.deviceId,advertisingName);
                }
            });
        }options:self.options];
    };
    _scanCount = 0;
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryBloodPressureMonitor usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        self->_scanCount ++;
        if (self->_scanCount > 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(deviceInfo!=nil)
                {
                    NSString *localName = [[deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                    if (localName != nil) {
                        if([deviceSerialNum isEqual:@""]) {
                            if ([[OMRONBLEBPDevice getAdvertisingName:deviceType]  containsString:[localName substringToIndex:17] ]) {
                                if (localName.length>[OMRONBLEBPDevice getAdvertisingName:deviceType].length) {
                                    [[OHQDeviceManager sharedManager] stopScan];
                                    self.deviceInfo = deviceInfo;
                                }
                            }
                        }else {
                            if([[localName uppercaseString] isEqualToString:[deviceSerialNum uppercaseString]])
                            {
                                [[OHQDeviceManager sharedManager] stopScan];
                                self.deviceInfo = deviceInfo;
                            }
                        }
                    }
                }
            });
        }
        
    } completion:^(OHQCompletionReason aReason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled:
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                }
                    break;
                case OHQCompletionReasonBusy:
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                }
                    break;
                case OHQCompletionReasonPoweredOff:
                {
                    complete(OMRON_SDK_UnOpenBlueTooth,@"",@"",@"");
                    return;
                }
                    break;
                default:
                    break;
            }
            
            if(self.deviceInfo!=nil)
            {
                NSString *localName = [[self.deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                if (localName != nil) {
                    if ([deviceSerialNum isEqual:@""]) {
                        if ([[OMRONBLEBPDevice getAdvertisingName:deviceType] containsString:[localName substringToIndex:17]]) {
                            if (localName.length>[OMRONBLEBPDevice getAdvertisingName:deviceType].length) {
                                readDataBlock(self.deviceInfo);
                            }
                        }
                    }else {
                        if([[localName uppercaseString] isEqualToString:[deviceSerialNum uppercaseString]]) {
                            readDataBlock(self.deviceInfo);
                        }
                    }
                    
                }
            }
            else
            {
                complete(OMRON_SDK_NoDevice,@"",@"",@"");
            }
            
        });
    }];
}

//血压计绑定
- (void)bingBPDevice:(OMRONDeviceType)deviceType complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete{
    [self bingBPDevice:deviceType deviceSerialNum:@"" complete:complete];
}

- (void)bindBFDevice:(OMRONDeviceType)deviceType status:(void(^)(OMRONBLESStaus statue))status userIndexBlock:(void(^)(NSString *deviceId,id<OMRONBFAppendUserIndexDelegate> indexData))userIndexBlock birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete
{
    __block BOOL isPairing = false;
    void(^readDataBlock)(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo,NSInteger index) = ^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo,NSInteger index){
        NSUUID *uuid = deviceInfo[OHQDeviceInfoIdentifierKey];
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"uuid"];
        NSInteger userIndex = index;
        self.userIndex = [NSNumber numberWithInteger:userIndex];
        self.options = [self bso_makeOptions:deviceInfo];
        self.data = [[BSOSessionData alloc] initWithIdentifier:uuid options:self.options];
        self.state = SessionViewStateConnecting;
        
        [[OHQDeviceManager sharedManager] startSessionWithDevice:uuid usingDataObserver:^(OHQDataType aDataType, id  _Nonnull data) {
            [self.data addSessionData:data withType:aDataType];
        } connectionObserver:^(OHQConnectionState aState) {
            if (aState == OHQConnectionStateConnected) {
                self.state = SessionViewStateProcessing;
                status(OMRON_BLE_CONNECTED);
            }
            else if(aState==OHQConnectionStateConnecting)
            {
                status(OMRON_BLE_CONNECTING);
            }
            else if(aState==OHQConnectionStateDisconnecting)
            {
                if(!isPairing)
                {
                    status(OMRON_BLE_DISCONNECTING);
                }
            }
        } completion:^(OHQCompletionReason aReason) {
            if(aReason==OHQCompletionReasonFailedToRegisterUser)
            {
                isPairing = false;
                return;
            }
            else
            {
                isPairing = true;
            }
            
            self.data.completionReason = aReason;
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonCanceled) {
                self.state = SessionViewStateCanceled;
                return;
            }
            
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonConnectionTimedOut) {
                self.state = SessionViewStateTimedOut;
                return;
            }
            
            self.state = SessionViewStateFinished;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BSOSessionData *data = self.data;
                if (data.currentTime) {
                    NSString *advertisingName;
                    if([deviceInfo objectForKey:@"advertisementData"]!=nil)
                    {
                        advertisingName = [[deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
                    }
                    NSMutableDictionary *userDatas = [[NSMutableDictionary alloc] initWithDictionary:data.userData];
                    NSNumber *lastSequenceNumber = data.sequenceNumberOfLatestRecord;
                    [self storeLastSequenceNumber:[NSString stringWithFormat:@"LastSequenceNumber-%@-%ld",advertisingName,(long)userIndex] lastSequenceNumber:lastSequenceNumber.integerValue];
                    [self storeDatabaseChangeIncrementNumber:data.databaseChangeIncrement deviceNum:[NSString stringWithFormat:@"DatabaseChangeIncrementNumber-%@-%ld",advertisingName,(long)userIndex]];
                    if(userDatas.count==0)
                    {
                        userDatas = [NSMutableDictionary dictionaryWithDictionary:self.userData];
                    }
                    else
                    {
                        if([userDatas objectForKey:@"gender"])
                        {
                            if([[userDatas objectForKey:@"gender"] isEqualToString:@"male"])
                            {
                                [userDatas setObject:@"0" forKey:@"gender"];
                            }
                            else if([[userDatas objectForKey:@"gender"] isEqualToString:@"female"])
                            {
                                [userDatas setObject:@"1" forKey:@"gender"];
                            }
                        }
                    }
                    [self storeUserInfo:userDatas];
                    complete(OMRON_SDK_Success,data.modelName,userIndex,advertisingName,userDatas);
                }
                else
                {
                    complete(OMRON_SDK_BindFail,@"",0,@"",@{});
                }
                
            });
        } options:self.options];
    };
    status(OMRON_BLE_SCANING);
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryBodyCompositionMonitor usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(deviceInfo!=nil)
            {
                NSString *localName = [[deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                if([localName containsString:@"BLEsmart_0001030E"]||[localName containsString:@"BLEsmart_0001030F"])
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                    
                    self.deviceInfo = deviceInfo;
                    status(OMRON_BLE_SCANED);
                }
            }
        });
    } completion:^(OHQCompletionReason aReason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled:
                case OHQCompletionReasonBusy:
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                }
                    break;
                case OHQCompletionReasonPoweredOff:
                {
                    complete(OMRON_SDK_UnOpenBlueTooth,@"",0,@"",@{});
                    return;
                }
                    break;
                default:
                    break;
            }
            if(self.deviceInfo!=nil)
            {
                NSString *localName = [[self.deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                if([localName containsString:@"BLEsmart_0001030E"]||[localName containsString:@"BLEsmart_0001030F"])
                {
                    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionary];
                    [userInfoDic setObject:birthday forKey:@"dateOfBirth"];
                    [userInfoDic setValue:[NSString stringWithFormat:@"%.1f",height] forKey:@"height"];
                    [userInfoDic setValue:isMale?@"male":@"female" forKey:@"gender"];
                    self.userData = userInfoDic;
                    if(userIndexBlock)
                    {
                        OMRONBFAppendUserIndexData *userIndexData = [[OMRONBFAppendUserIndexData alloc] init];
                        [userIndexData setBlock:^(NSInteger index) {
                            readDataBlock(self.deviceInfo,index);
                        }];
                        userIndexBlock(localName,userIndexData);
                    }
                }
                else
                {
                    complete(OMRON_SDK_BindFail,@"",0,@"",@{});
                }
            }
            else
            {
                complete(OMRON_SDK_NoDevice,@"",0,@"",@{});
            }
        });
    }];
}

- (void)bindBFDevice:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete
{
    void(^readDataBlock)(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo,NSInteger index) = ^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo,NSInteger index){
        NSUUID *uuid = deviceInfo[OHQDeviceInfoIdentifierKey];
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"uuid"];
        self.userIndex = [NSNumber numberWithInteger:userIndex];
        self.options = [self bso_makeOptions:deviceInfo];
        self.data = [[BSOSessionData alloc] initWithIdentifier:uuid options:self.options];
        self.state = SessionViewStateConnecting;
        [[OHQDeviceManager sharedManager] startSessionWithDevice:uuid usingDataObserver:^(OHQDataType aDataType, id  _Nonnull data) {
            [self.data addSessionData:data withType:aDataType];
        } connectionObserver:^(OHQConnectionState aState) {
            if (aState == OHQConnectionStateConnected) {
                self.state = SessionViewStateProcessing;
            }
        } completion:^(OHQCompletionReason aReason) {
            self.data.completionReason = aReason;
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonCanceled) {
                self.state = SessionViewStateCanceled;
                return;
            }
            
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonConnectionTimedOut) {
                self.state = SessionViewStateTimedOut;
                return;
            }
            
            self.state = SessionViewStateFinished;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BSOSessionData *data = self.data;
                if (data.currentTime) {
                    NSString *advertisingName;
                    if([deviceInfo objectForKey:@"advertisementData"]!=nil)
                    {
                        advertisingName = [[deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
                    }
                    NSMutableDictionary *userDatas = [[NSMutableDictionary alloc] initWithDictionary:data.userData];
                    NSNumber *lastSequenceNumber = data.sequenceNumberOfLatestRecord;
                    [self storeLastSequenceNumber:[NSString stringWithFormat:@"LastSequenceNumber-%@-%ld",advertisingName,(long)userIndex] lastSequenceNumber:lastSequenceNumber.integerValue];
                    [self storeDatabaseChangeIncrementNumber:data.databaseChangeIncrement deviceNum:[NSString stringWithFormat:@"DatabaseChangeIncrementNumber-%@-%ld",advertisingName,(long)userIndex]];
                    if(userDatas.count==0)
                    {
                        userDatas = [NSMutableDictionary dictionaryWithDictionary:self.userData];
                    }
                    else
                    {
                        if([userDatas objectForKey:@"gender"])
                        {
                            if([[userDatas objectForKey:@"gender"] isEqualToString:@"male"])
                            {
                                [userDatas setObject:@"0" forKey:@"gender"];
                            }
                            else if([[userDatas objectForKey:@"gender"] isEqualToString:@"female"])
                            {
                                [userDatas setObject:@"1" forKey:@"gender"];
                            }
                        }
                    }
                    [self storeUserInfo:userDatas];
                    complete(OMRON_SDK_Success,data.modelName,userIndex,advertisingName,userDatas);
                }
                else
                {
                    complete(OMRON_SDK_BindFail,@"",0,@"",@{});
                }
            });
        } options:self.options];
    };
    
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryBodyCompositionMonitor usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(deviceInfo!=nil)
            {
                NSString *localName = [[deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                if([localName containsString:@"BLEsmart_0001030E"]||[localName containsString:@"BLEsmart_0001030F"])
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                    
                    self.deviceInfo = deviceInfo;
                }
            }
        });
    } completion:^(OHQCompletionReason aReason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled:
                case OHQCompletionReasonBusy:
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                }
                    break;
                case OHQCompletionReasonPoweredOff:
                {
                    complete(OMRON_SDK_UnOpenBlueTooth,@"",0,@"",@{});
                    return;
                }
                    break;
                default:
                    break;
            }
            if(self.deviceInfo!=nil)
            {
                NSString *localName = [[self.deviceInfo valueForKey:@"advertisementData"] valueForKey:@"localName"];
                if([localName containsString:@"BLEsmart_0001030E"]||[localName containsString:@"BLEsmart_0001030F"])
                {
                    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionary];
                    [userInfoDic setObject:birthday forKey:@"dateOfBirth"];
                    [userInfoDic setValue:[NSString stringWithFormat:@"%.1f",height] forKey:@"height"];
                    [userInfoDic setValue:isMale?@"male":@"female" forKey:@"gender"];
                    self.userData = userInfoDic;
                    readDataBlock(self.deviceInfo,userIndex);
                }
                else
                {
                    complete(OMRON_SDK_BindFail,@"",0,@"",@{});
                }
            }
            else
            {
                
                complete(OMRON_SDK_NoDevice,@"",0,@"",@{});
            }
        });
    }];
}

- (void)getBpDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSArray<NSDictionary *> *measurementRecords))complete{
    
    void(^readDataBlock)(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) = ^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo){
        NSUUID *uuid = deviceInfo[OHQDeviceInfoIdentifierKey];
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"uuid"];
        self.options = [self bpDevice_bso_makeOptions:deviceInfo];
        self.data = [[BSOSessionData alloc] initWithIdentifier:uuid options:self.options];
        self.state = SessionViewStateConnecting;
        [[OHQDeviceManager sharedManager] startSessionWithDevice:uuid usingDataObserver:^(OHQDataType aDataType, id  _Nonnull data) {
            [self.data addSessionData:data withType:aDataType];
        } connectionObserver:^(OHQConnectionState aState) {
            if (aState == OHQConnectionStateConnected) {
                self.state = SessionViewStateProcessing;
            }
//            NSLog(@"获取数据+++%lu",(unsigned long)aState);
        }completion:^(OHQCompletionReason aReason) {
            self.data.completionReason = aReason;
            NSLog(@"&&&OHQCompletionReason&&&===%zd",aReason);
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonCanceled) {
                self.state = SessionViewStateCanceled;
                return;
            }
            
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonConnectionTimedOut) {
                self.state = SessionViewStateTimedOut;
                return;
            }
            
            self.state = SessionViewStateFinished;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BSOSessionData *data = self.data;
                if (data.currentTime == nil) {
                    //                       complete(OMRON_SDK_ConnectFail,@"获取血压数据:currentTime为空",nil);
                    complete(OMRON_SDK_ConnectFail,nil);
                    NSLog(@"****OMRON_SDK_ConnectFail****");
                }else{
                    complete(OMRON_SDK_Success,data.measurementRecords);
                    NSLog(@"^^^^^OMRON_SDK_Success^^^^");
                }
            });
        }options:self.options];
    };
    
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"scanStatus"] isEqualToString:@"1"]) {
        //停止绑定scanStatus：1 不走扫描，
        //注册：scanStatus：0 走扫描
    }else{
        //        if (@available(iOS 10.0, *)) {
        //            self.timer =[NSTimer scheduledTimerWithTimeInterval:30 repeats:NO block:^(NSTimer * _Nonnull timer) {
        //                NSLog(@"扫描超时");
        //                [[OHQDeviceManager sharedManager]stopScan];
        //                [self.timer invalidate];
        //                self.timer=nil;
        //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ////                         NSLog(@"stopConnect");
        //                        complete(OMRON_SDK_ScanTimeOut,nil);
        //                });
        //            }];
        //    //        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        //        } else {
        //            // Fallback on earlier versions
        //        }
        [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryBloodPressureMonitor usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
//            NSLog(@"扫描");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(deviceInfo!=nil)
                {
                    NSString *advertisingName;
                    if([deviceInfo objectForKey:@"advertisementData"]!=nil)
                    {
                        advertisingName = [[deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
                    }
                    
                    if([[advertisingName uppercaseString] isEqualToString:[deviceSerialNum uppercaseString]])
                    {
                        [[OHQDeviceManager sharedManager] stopScan];
                        self.deviceInfo = deviceInfo;
                        readDataBlock(self.deviceInfo);
                    }
                }
            });
        } completion:^(OHQCompletionReason aReason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (aReason) {
                    case OHQCompletionReasonCanceled:
                    {
                        complete(OMRON_SDK_ScanCancel,nil);
                        [[OHQDeviceManager sharedManager] stopScan];
                    }
                        break;
                    case OHQCompletionReasonBusy:
                    {
//                        [self.timer invalidate];
//                        self.timer=nil;
                        complete(OMRON_SDK_ScanTimeOut,nil);
                        [[OHQDeviceManager sharedManager] stopScan];
                    }
                        break;
                    case OHQCompletionReasonPoweredOff:
                    {
//                        [self.timer invalidate];
//                        self.timer=nil;
                        [[OHQDeviceManager sharedManager] stopScan];
                        complete(OMRON_SDK_UnOpenBlueTooth,nil);
                        return;
                    }
                        break;
                    case OHQCompletionReasonConnectionTimedOut:
                    {
                        NSLog(@"timeout");
                        [[OHQDeviceManager sharedManager]stopScan];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            complete(OMRON_SDK_ScanTimeOut,nil);
//                            return;
//                        });
                        
                    }
                        break;
                    default:
                        break;
                }
//                if(self.deviceInfo)
//                {
//                    NSString *advertisingName;
//                    if([self.deviceInfo objectForKey:@"advertisementData"])
//                    {
//                        advertisingName = [[self.deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
//                    }
//                    if([[advertisingName uppercaseString] isEqualToString:[deviceSerialNum uppercaseString]])
//                    {
//
//                    }
//                }
//                else
//                {
//                    [self.timer invalidate];
//                    self.timer=nil;
//                    complete(OMRON_SDK_NoDevice,nil);
//                }
            });
        }];
        
    }
    
}

-(void)hideHud{
    [[OHQDeviceManager sharedManager]stopScan];
}

-(void)getBFDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSArray<NSDictionary *> *measurementRecords,NSDictionary *userInfo))complete
{
    void(^readDataBlock)(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo,NSInteger index) = ^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo,NSInteger index){
        NSUUID *uuid = deviceInfo[OHQDeviceInfoIdentifierKey];
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"uuid"];
        self.userIndex = [NSNumber numberWithInteger:userIndex];
        NSMutableDictionary<OHQSessionOptionKey,id> *options = [@{OHQSessionOptionReadMeasurementRecordsKey: @YES,OHQSessionOptionConnectionWaitTimeKey: @30.0} mutableCopy];
        options[OHQSessionOptionUserIndexKey] = self.userIndex;
        options[OHQSessionOptionUserDataKey] = self.userData;
        options[OHQSessionOptionUserDataUpdateFlagKey] = @0;
        options[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] = @YES;
        options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] = @YES;
        options[OHQSessionOptionSequenceNumberOfFirstRecordToReadKey] = @([self getDeviceLastSequenceNumber:[NSString stringWithFormat:@"LastSequenceNumber-%@-%ld",deviceSerialNum,(long)userIndex]] + 1);
        //        options[OHQSessionOptionSequenceNumberOfFirstRecordToReadKey] = @0;
        options[OHQSessionOptionDatabaseChangeIncrementValueKey] = @([self getDatabaseChangeIncrementNumber:birthday height:height isMale:isMale deviceNum:[NSString stringWithFormat:@"DatabaseChangeIncrementNumber-%@-%ld",deviceSerialNum,(long)userIndex]]);
        self.options = options;
        self.data = [[BSOSessionData alloc] initWithIdentifier:uuid options:self.options];
        self.state = SessionViewStateConnecting;
        [[OHQDeviceManager sharedManager] startSessionWithDevice:uuid usingDataObserver:^(OHQDataType aDataType, id  _Nonnull data) {
            [self.data addSessionData:data withType:aDataType];
        } connectionObserver:^(OHQConnectionState aState) {
            if (aState == OHQConnectionStateConnected) {
                self.state = SessionViewStateProcessing;
            }
//            NSLog(@"体脂%lu",(unsigned long)aState);
        } completion:^(OHQCompletionReason aReason) {
            self.data.completionReason = aReason;
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonCanceled) {
                self.state = SessionViewStateCanceled;
                return;
            }
            
            if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonConnectionTimedOut) {
                self.state = SessionViewStateTimedOut;
                return;
            }
            
            self.state = SessionViewStateFinished;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BSOSessionData *data = self.data;
                if (data.currentTime != nil) {
                    NSNumber *lastSequenceNumber = data.sequenceNumberOfLatestRecord;
                    [self storeLastSequenceNumber:[NSString stringWithFormat:@"LastSequenceNumber-%@-%ld",deviceSerialNum,(long)userIndex] lastSequenceNumber:lastSequenceNumber.integerValue];
                    NSMutableDictionary *userDatas = [[NSMutableDictionary alloc] initWithDictionary:data.userData];
                    [self storeDatabaseChangeIncrementNumber:data.databaseChangeIncrement deviceNum:[NSString stringWithFormat:@"DatabaseChangeIncrementNumber-%@-%ld",deviceSerialNum,(long)userIndex]];
                    if(userDatas.count==0)
                    {
                        userDatas = [NSMutableDictionary dictionaryWithDictionary:self.userData];
                    }
                    else
                    {
                        if([userDatas objectForKey:@"gender"])
                        {
                            if([[userDatas objectForKey:@"gender"] isEqualToString:@"male"])
                            {
                                [userDatas setObject:@"0" forKey:@"gender"];
                            }
                            else if([[userDatas objectForKey:@"gender"] isEqualToString:@"female"])
                            {
                                [userDatas setObject:@"1" forKey:@"gender"];
                            }
                        }
                    }
                    [self storeUserInfo:userDatas];
                    complete(OMRON_SDK_Success,data.measurementRecords,userDatas);
                }else{
                    complete(OMRON_SDK_ConnectFail,nil,@{});
                }
            });
        } options:self.options];
    };
    //            NSTimer *timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(hideHud) userInfo:@"hide" repeats:NO];
    NSTimer *timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(hideHud) userInfo:@"hide" repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryBodyCompositionMonitor usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(deviceInfo!=nil)
            {
                NSString *advertisingName;
                if([deviceInfo objectForKey:@"advertisementData"]!=nil)
                {
                    advertisingName = [[deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
                }
                
                if([[advertisingName uppercaseString] isEqualToString:[deviceSerialNum uppercaseString]])
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                    self.deviceInfo = deviceInfo;
                }
            }
        });
    } completion:^(OHQCompletionReason aReason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled:
                case OHQCompletionReasonBusy:
                {
                    [[OHQDeviceManager sharedManager] stopScan];
                }
                    break;
                case OHQCompletionReasonPoweredOff:
                {
                    //                            dispatch_source_cancel(timer);
                    complete(OMRON_SDK_UnOpenBlueTooth,nil,nil);
                    return;
                }
                    break;
                case OHQCompletionReasonConnectionTimedOut:
                {
                    [self.timer invalidate];
                    self.timer=nil;
                    [[OHQDeviceManager sharedManager]stopScan];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        complete(OMRON_SDK_ScanTimeOut,nil,nil);
                        return;
                    });
                    
                }
                    break;
                default:
                    break;
            }
            if(self.deviceInfo)
            {
                NSString *advertisingName;
                if([self.deviceInfo objectForKey:@"advertisementData"])
                {
                    advertisingName = [[self.deviceInfo objectForKey:@"advertisementData"] objectForKey:@"localName"];
                }
                if([[advertisingName uppercaseString] isEqualToString:[deviceSerialNum uppercaseString]])
                {
                    //                            dispatch_source_cancel(timer);
                    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionary];
                    [userInfoDic setObject:birthday forKey:@"dateOfBirth"];
                    [userInfoDic setValue:[NSString stringWithFormat:@"%.1f",height] forKey:@"height"];
                    [userInfoDic setValue:isMale?@"male":@"female" forKey:@"gender"];
                    self.userData = userInfoDic;
                    readDataBlock(self.deviceInfo,userIndex);
                }
            }
            else
            {
                //                        dispatch_source_cancel(timer);
                complete(OMRON_SDK_NoDevice,nil,nil);
            }
        });
    }];
}

- (NSDictionary<OHQSessionOptionKey,id> *)bpDevice_bso_makeOptions:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo
{
    NSMutableDictionary<OHQSessionOptionKey,id> *ret = [@{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                                                          OHQSessionOptionConnectionWaitTimeKey: @30.0,OHQAdvertisementDataIsConnectable:@YES} mutableCopy];
    return [ret copy];
}



- (NSDictionary<OHQSessionOptionKey,id> *)bso_makeOptions:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo
{
    NSMutableDictionary<OHQSessionOptionKey,id> *ret = [@{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                                                          OHQSessionOptionConnectionWaitTimeKey: @30.0} mutableCopy];
    
    if (self.protocol == BSOProtocolBluetoothStandard) {
        OHQDeviceCategory category = [deviceInfo[OHQDeviceInfoCategoryKey] unsignedShortValue];
        switch (category) {
            case OHQDeviceCategoryWeightScale:
            case OHQDeviceCategoryBodyCompositionMonitor:
                ret[OHQSessionOptionRegisterNewUserKey] = @YES;
                ret[OHQSessionOptionUserDataKey] = self.userData;
                ret[OHQSessionOptionUserDataUpdateFlagKey] = @YES;
                ret[OHQSessionOptionDatabaseChangeIncrementValueKey] = @0;
                break;
            default:
                break;
        }
    }
    else if (self.protocol == BSOProtocolOmronExtension) {
        ret[OHQSessionOptionAllowAccessToBeaconIdentifierKey] = @YES;
        ret[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] = @YES;
        ret[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] = @YES;
        ret[OHQSessionOptionRegisterNewUserKey] = @YES;
        ret[OHQSessionOptionUserDataKey] = self.userData;
        ret[OHQSessionOptionUserDataUpdateFlagKey] = @YES;
        ret[OHQSessionOptionDatabaseChangeIncrementValueKey] = @0;
        ret[OHQSessionOptionConnectionWaitTimeKey] = @30.0;
        if (self.userIndex && ![self.userIndex isEqualToNumber:@0]) {
            ret[OHQSessionOptionUserIndexKey] = self.userIndex;
        }
    }
    
    return [ret copy];
}

- (void)setState:(SessionViewState)state {
    if (_state != state) {
        _state = state;
    }
}

// 是否注册成功
- (BOOL)bso_validateSessionWithData:(BSOSessionData *)data {
    if (data.completionReason != OHQCompletionReasonDisconnected) {
        return NO;
    }
    if (!data.currentTime && !data.batteryLevel && !data.measurementRecords.count) {
        return NO;
    }
    if ([data.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] && !data.measurementRecords) {
        return NO;
    }
    if (self.protocol == BSOProtocolOmronExtension) {
        if ([data.options[OHQSessionOptionRegisterNewUserKey] boolValue] && !data.registeredUserIndex) {
            return NO;
        }
    }
    if (data.registeredUserIndex && data.options[OHQSessionOptionDatabaseChangeIncrementValueKey] && !data.databaseChangeIncrement) {
        return NO;
    }
    return YES;
}

-(void)storeLastSequenceNumber:(NSString *)deviceNum lastSequenceNumber:(NSInteger)lastSequenceNumber
{
    NSUserDefaults *devicelastSequenceNumber = [NSUserDefaults standardUserDefaults];
    [devicelastSequenceNumber setValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:lastSequenceNumber]] forKey:deviceNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getDeviceLastSequenceNumber:(NSString *)deviceNum
{
    NSUserDefaults *devicelastSequenceNumber = [NSUserDefaults standardUserDefaults];
    if([devicelastSequenceNumber objectForKey:deviceNum])
    {
        return ((NSNumber *)[devicelastSequenceNumber objectForKey:deviceNum]).integerValue;
    }
    return 0;
}

-(void)storeDatabaseChangeIncrementNumber:(NSNumber *)num deviceNum:(NSString *)deviceNum
{
    NSUserDefaults *databaseChangeIncrementNumber = [NSUserDefaults standardUserDefaults];
    [databaseChangeIncrementNumber setValue:num forKey:deviceNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getDatabaseChangeIncrementNumber:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale deviceNum:(NSString *)deviceNum
{
    BOOL hasChange = [self getUserInfoHasChange:birthday height:height isMale:isMale];
    NSUserDefaults *databaseChangeIncrementNumber = [NSUserDefaults standardUserDefaults];
    NSInteger flag = ((NSNumber *)[databaseChangeIncrementNumber valueForKey:deviceNum]).integerValue;
    if(hasChange)
    {
        return flag+1;
    }
    
    return flag;
}

-(void)storeUserInfo:(NSDictionary *)userInfo
{
    NSUserDefaults *userInfos = [NSUserDefaults standardUserDefaults];
    [userInfos setValue:userInfo forKey:[OMRONKeychainTool getDeviceIDInKeychain]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDictionary *)getUserInfo
{
    NSUserDefaults *userInfos = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userInfos valueForKey:[OMRONKeychainTool getDeviceIDInKeychain]];
    return dic;
}

-(BOOL)getUserInfoHasChange:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale
{
    NSDictionary *oldUserInfo = [self getUserInfo];
    BOOL hasChange = false;
    
    NSInteger oldGender = [[oldUserInfo valueForKey:@"gender"] integerValue];
    NSDate *oldBirthday = [oldUserInfo valueForKey:@"dateOfBirth"];
    NSString *oldHeight = [oldUserInfo valueForKey:@"height"];
    
    if(oldGender != (isMale?0:1))
    {
        hasChange = YES;
    }
    
    if(oldBirthday!=birthday)
    {
        hasChange = YES;
    }
    
    if(oldHeight!=[NSString stringWithFormat:@"%.1f",height])
    {
        hasChange = YES;
    }
    return hasChange;
}

-(void)dealloc{
    //    NSLog(@"timer 销毁");
    [[OHQDeviceManager sharedManager]stopScan];
    [self.timer invalidate];
    self.timer=nil;
}
-(void)stopConnect:(void(^)(BOOL isCancel))complete{
    
    [[OHQDeviceManager sharedManager]stopScan];
    [self.timer invalidate];
    self.timer=nil;
    NSData * data = [[NSUserDefaults standardUserDefaults] valueForKey:@"uuid"];
    NSUUID * uuid = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [[OHQDeviceManager sharedManager]cancelSessionWithDevice:uuid complete:^(BOOL isCancel) {
        if (isCancel) {
            complete(YES);
        }else{
            complete(NO);
        }
    }];
    
}
@end
