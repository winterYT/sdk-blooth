//
//  OMRONLib.m
//  OMRONLib
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "OMRONLib.h"
#import "OMRONBLEDevice.h"
#import "OMRONBLEDeviceManager.h"
#import "NetTool.h"
#import "OMRONKeychainTool.h"
#import "LogManager.h"
#import <UIKit/UIKit.h>
#import "OMRONDeviceManager.h"
#import "OHQDefines.h"
#define BASE_URL    @"https://api-test.omronhealthcare.com.cn/"
//#define BASE_URL    @"https://api-stg.omronhealthcare.com.cn/"
//#define BASE_URL      @"https://api.omronhealthcare.com.cn/"
#define ISPOSTDATA  YES


#define OLOG(log) [NSString stringWithFormat:@"[%@ %@] %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),log]
#define OMRONLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
#define OMRON_OBJ_UUID  @"OmronObjUuid"
#define OMRON_OBJ_DEVICE_LIST  @"OmronObjDeviceList"
#define OMRON_BPDATAS_FILE  [NSString stringWithFormat:@"%@/Documents/data.data",NSHomeDirectory()]
#define OMRON_BFDATAS_FILE  [NSString stringWithFormat:@"%@/Documents/BFData.data",NSHomeDirectory()]
@interface OMRONBPObject()
@property (nonatomic, copy) NSString *device_digital_id;
@property (nonatomic, copy) NSString *device_ble_cmn_id;
//@property (nonatomic, copy) NSString *device_type;
-(NSDictionary *)modelToDic:(OMRONBPObject *)model;
+(OMRONBPObject *)dicToModel:(NSDictionary *)dic;
@end
@implementation OMRONBPObject
-(NSDictionary *)modelToDic:(OMRONBPObject *)model
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.sbp] forKey:@"sbp"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.dbp] forKey:@"dbp"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.pulse] forKey:@"pulse"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.ihb_flg] forKey:@"ihb_flg"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.bm_flg] forKey:@"bm_flg"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.cws_flg] forKey:@"cws_flg"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.measureUser] forKey:@"measureUser"];
    [dic setValue:[NSString stringWithFormat:@"%ld",self.measure_at] forKey:@"measure_at"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.device_digital_id] forKey:@"device_digital_id"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.device_ble_cmn_id] forKey:@"device_ble_cmn_id"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.device_type] forKey:@"device_type"];
    return dic;
}

+(OMRONBPObject *)dicToModel:(NSDictionary *)dic
{
    OMRONBPObject *model = [OMRONBPObject new];
    model.sbp = [[dic valueForKey:@"sbp"] integerValue];
    model.dbp = [[dic valueForKey:@"dbp"] integerValue];
    model.pulse = [[dic valueForKey:@"pulse"] integerValue];
    model.ihb_flg = [[dic valueForKey:@"ihb_flg"] integerValue];
    model.bm_flg = [[dic valueForKey:@"bm_flg"] integerValue];
    model.cws_flg = [[dic valueForKey:@"cws_flg"] integerValue];
    model.measureUser = [[dic valueForKey:@"measureUser"] integerValue];
    model.measure_at = (long)[[dic valueForKey:@"measure_at"] longLongValue];
    model.device_digital_id = [dic valueForKey:@"device_digital_id"];
    model.device_ble_cmn_id = [dic valueForKey:@"device_ble_cmn_id"];
    model.device_type = [dic valueForKey:@"device_type"];
    return model;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.sbp forKey:@"sbp"];
    [aCoder encodeInteger:self.dbp forKey:@"dbp"];
    [aCoder encodeInteger:self.pulse forKey:@"pulse"];
    [aCoder encodeInteger:self.ihb_flg forKey:@"ihb_flg"];
    [aCoder encodeInteger:self.bm_flg forKey:@"bm_flg"];
    [aCoder encodeInteger:self.cws_flg forKey:@"cws_flg"];
    [aCoder encodeInteger:self.measureUser forKey:@"measureUser"];
    [aCoder encodeInteger:self.measure_at forKey:@"measure_at"];
    [aCoder encodeObject:self.device_digital_id forKey:@"device_digital_id"];
    [aCoder encodeObject:self.device_ble_cmn_id forKey:@"device_ble_cmn_id"];
    [aCoder encodeObject:self.device_type forKey:@"device_type"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.sbp = [aDecoder decodeIntegerForKey:@"sbp"];
        self.dbp = [aDecoder decodeIntegerForKey:@"dbp"];
        self.pulse = [aDecoder decodeIntegerForKey:@"pulse"];
        self.ihb_flg = [aDecoder decodeIntegerForKey:@"ihb_flg"];
        self.bm_flg = [aDecoder decodeIntegerForKey:@"bm_flg"];
        self.cws_flg = [aDecoder decodeIntegerForKey:@"cws_flg"];
        self.measureUser = [aDecoder decodeIntegerForKey:@"measureUser"];
        self.measure_at = [aDecoder decodeIntegerForKey:@"measure_at"];
        self.device_digital_id = [aDecoder decodeObjectForKey:@"device_digital_id"];
        self.device_ble_cmn_id = [aDecoder decodeObjectForKey:@"device_ble_cmn_id"];
        self.device_type = [aDecoder decodeObjectForKey:@"device_type"];
    }
    return self;
}
@end

@interface OMRONBFObject()
@property (nonatomic, copy) NSString *device_digital_id;
@property (nonatomic, copy) NSString *device_ble_cmn_id;
-(NSDictionary *)modelToDic:(OMRONBFObject *)model;
+(OMRONBFObject *)dicToModel:(NSDictionary *)dic;
@end
@implementation OMRONBFObject
-(NSDictionary *)modelToDic:(OMRONBFObject *)model
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSString stringWithFormat:@"%@",self.bmi] forKey:@"bmi"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.basal_metabolism] forKey:@"basal_metabolism"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.body_age] forKey:@"body_age"];
    [dic setValue:[NSString stringWithFormat:@"%.1f",self.fat_rate] forKey:@"fat_rate"];
    [dic setValue:[NSString stringWithFormat:@"%.1f",self.height] forKey:@"height"];
    [dic setValue:[NSString stringWithFormat:@"%.1f",self.weight] forKey:@"weight"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.userIndex] forKey:@"userIndex"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)self.visceral_fat] forKey:@"visceral_fat"];
    [dic setValue:[NSString stringWithFormat:@"%.1f",self.skeletal_muscles_rate] forKey:@"skeletal_muscles_rate"];
    [dic setValue:[NSString stringWithFormat:@"%ld",self.measure_at] forKey:@"measure_at"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.device_type] forKey:@"device_type"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.device_digital_id] forKey:@"device_digital_id"];
    [dic setValue:[NSString stringWithFormat:@"%@",self.device_ble_cmn_id] forKey:@"device_ble_cmn_id"];
    [dic setValue:self.birthday forKey:@"birthday"];
    [dic setValue:self.gender forKey:@"gender"];
    return dic;
}

+(OMRONBFObject *)dicToModel:(NSDictionary *)dic
{
    OMRONBFObject *model = [OMRONBFObject new];
    model.bmi = [dic objectForKey:@"bmi"];
    model.basal_metabolism = [[dic valueForKey:@"basal_metabolism"] integerValue];
    model.body_age = [[dic valueForKey:@"body_age"] integerValue];
    model.fat_rate = [[dic valueForKey:@"fat_rate"] floatValue];
    model.height = [[dic valueForKey:@"height"] floatValue];
    model.weight = [[dic valueForKey:@"weight"] floatValue];
    model.userIndex = [[dic valueForKey:@"userIndex"] integerValue];
    model.visceral_fat = [[dic valueForKey:@"visceral_fat"] integerValue];
    model.skeletal_muscles_rate = [[dic valueForKey:@"skeletal_muscles_rate"] floatValue];
    model.measure_at = ((NSDate *)[dic valueForKey:@"measure_at"]).timeIntervalSince1970;
    model.device_type = [dic valueForKey:@"device_type"];
    model.device_digital_id = [dic valueForKey:@"device_digital_id"];
    model.device_ble_cmn_id = [dic valueForKey:@"device_ble_cmn_id"];
    model.birthday = [dic valueForKey:@"birthday"];
    model.gender = [dic valueForKey:@"gender"];
    return model;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bmi forKey:@"bmi"];
    [aCoder encodeInteger:self.basal_metabolism forKey:@"basal_metabolism"];
    [aCoder encodeInteger:self.body_age forKey:@"body_age"];
    [aCoder encodeInteger:self.fat_rate forKey:@"fat_rate"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeFloat:self.weight forKey:@"weight"];
    [aCoder encodeInteger:self.userIndex forKey:@"userIndex"];
    [aCoder encodeInteger:self.visceral_fat forKey:@"visceral_fat"];
    [aCoder encodeInteger:self.skeletal_muscles_rate forKey:@"skeletal_muscles_rate"];
    [aCoder encodeInteger:self.measure_at forKey:@"measure_at"];
    [aCoder encodeObject:self.device_type forKey:@"device_type"];
    [aCoder encodeObject:self.device_digital_id forKey:@"device_digital_id"];
    [aCoder encodeObject:self.device_ble_cmn_id forKey:@"device_ble_cmn_id"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.bmi = [aDecoder decodeObjectForKey:@"bmi"];
        self.basal_metabolism = [aDecoder decodeIntegerForKey:@"basal_metabolism"];
        self.body_age = [aDecoder decodeIntegerForKey:@"body_age"];
        self.fat_rate = [aDecoder decodeIntegerForKey:@"fat_rate"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.weight = [aDecoder decodeFloatForKey:@"weight"];
        self.userIndex = [aDecoder decodeIntegerForKey:@"userIndex"];
        self.visceral_fat = [aDecoder decodeIntegerForKey:@"visceral_fat"];
        self.skeletal_muscles_rate = [aDecoder decodeIntegerForKey:@"skeletal_muscles_rate"];
        self.measure_at = [aDecoder decodeIntegerForKey:@"measure_at"];
        self.device_type = [aDecoder decodeObjectForKey:@"device_type"];
        self.device_digital_id = [aDecoder decodeObjectForKey:@"device_digital_id"];
        self.device_ble_cmn_id = [aDecoder decodeObjectForKey:@"device_ble_cmn_id"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
    }
    return self;
}
@end

@implementation OMRONLib
{
    OMRONLib *omronLib;
    BOOL isRegister;
    NSInteger stopStatus;
    BOOL isListening;
}

+(instancetype)shareInstance
{
    
    static OMRONLib *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OMRONLib alloc] init];
        // [instance redirectNSlogToDocumentFolder];
    });
    
    return instance;
}

- (void)redirectNSlogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"dr.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (NSDate*)getCurrDate{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    return localeDate;
}

-(void)unRegister
{
    NSUserDefaults *uuidDefaults = [NSUserDefaults standardUserDefaults];
    [uuidDefaults setObject:nil forKey:OMRON_OBJ_UUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [OMRONKeychainTool deleteDeviceUUID];
    isRegister = false;
    
}

- (BOOL)registerApp:(NSString *)appid
{
    if (ISPOSTDATA) {
        __block BOOL resultRegister = false;
        @try {
            if(appid!=nil)
            {
                if([[NetTool shareInstance] isHasNet])
                {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setValue:[self getDeviceInfo] forKey:@"expansion_info"];
                    [dic setValue:appid forKey:@"company_key"];
                    [dic setValue:@"1" forKey:@"equipment_identity"];
                    if(!IsStrEmpty([OMRONKeychainTool getDeviceIDInKeychain]))
                    {
                        [dic setValue:[OMRONKeychainTool getDeviceIDInKeychain] forKey:@"uuid"];
                        NSLog(@"dic uuid--%@",[OMRONKeychainTool getDeviceIDInKeychain]);
                    }
                    [LogManager logInfo:OLOG(@"register") logStr:@"begin to register",[LogManager toJasonString:dic],nil];
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    [[NetTool shareInstance] post:[NSString stringWithFormat:@"%@%@",BASE_URL,@"v1/Sdk/identifier"] params:dic success:^(id  _Nonnull responseObj) {
                        if([responseObj isKindOfClass:[NSDictionary class]])
                        {
                            [LogManager logInfo:OLOG(@"register") logStr:@"response",[LogManager toJasonString:responseObj],nil];
                            NSInteger code = [[responseObj valueForKey:@"code"] integerValue];
                            NSDictionary *result = [responseObj valueForKey:@"data"];
                            if(code==1)
                            {
                                [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"scanStatus"];
                                resultRegister = YES;
                                NSString *uuid = [result valueForKey:@"uuid"];
//                                NSLog(@"uuid--%@",uuid);
                                NSMutableArray *diviceList = [result valueForKey:@"device_list"];
                                NSUserDefaults *uuidDefaults = [NSUserDefaults standardUserDefaults];
                                [uuidDefaults setObject:uuid forKey:OMRON_OBJ_UUID];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                NSUserDefaults *deviceDefaults = [NSUserDefaults standardUserDefaults];
                                [deviceDefaults setObject:diviceList forKey:OMRON_OBJ_DEVICE_LIST];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                [OMRONKeychainTool saveDeviceUUID:uuid];
                                [self uploadLocalBPData:^(bool result) {
                                    
                                }];
                                [self uploadLocalBFData:^(bool result) {
                                    
                                }];
                            }
                        }
                        dispatch_semaphore_signal(semaphore);
                    } failture:^(NSError * _Nonnull error,id  _Nonnull responseObj) {
                        [LogManager logErrorInfo:OLOG(@"register") logStr:@"register api error",[LogManager toJasonString:error.userInfo],nil];
                        resultRegister = NO;
                        dispatch_semaphore_signal(semaphore);
           
                    }];
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    [LogManager logInfo:OLOG(@"register") logStr:@"To complete the registration",nil];
                   
                }
                else
                {
                    [LogManager logInfo:OLOG(@"register") logStr:@"register failed",@"no network",nil];
                    resultRegister = NO;
                }
            }else {
                NSLog(@"无网络");

            }
            [self uploadLog:YES];
        } @catch (NSException *exception) {
            [LogManager logErrorInfo:OLOG(@"register") logStr:@"register exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
        } @finally {
            [LogManager clearExpiredLog];
            isRegister = resultRegister;
            return resultRegister;
        }
    }else{
        NSArray *deviceList = @[@"U32J",@"HEM-9200T",@"J750",@"J730",@"J761",@"HEM-9200L",@"HBF-219T",@"U18",@"J760",@""];
        NSUserDefaults *deviceDefaults = [NSUserDefaults standardUserDefaults];
        [deviceDefaults setObject:deviceList forKey:OMRON_OBJ_DEVICE_LIST];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
}

- (NSArray *)newDevice {
    return @[@""];
}

//扫描周围设备
- (void)scanAllDevicescomplete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete{
    if (ISPOSTDATA) {
        @try {
        if([self isRegister])
            {
                [[[OMRONDeviceManager alloc]init]scanAllBPDevicesComplete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName)  {
                    if(status==OMRON_SDK_Success)
                       {
                         [self bindDeviceService:advertisingName deviceName:deviceName advertisingName:advertisingName userIndex:1 complete:^(OMRONSDKStatus status, NSString *deviceName, NSString *deviceId, NSString *advertisingName) {
                             complete(status,deviceName,deviceId,advertisingName);
                         }];
                        }
                        else
                        {
                            complete(status,deviceName,deviceId,advertisingName);
                        }
                }];
                return;

            }
             else
             {
                 [LogManager logInfo:OLOG(@"binding equipment") logStr:@"SDK unregister",nil];
                 complete(OMRON_SDK_UnRegister,nil,nil,nil);
             }

             } @catch (NSException *exception) {
                 [LogManager logErrorInfo:OLOG(@"binding equipment") logStr:@"binding equipment  exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
             } @finally {

             }
    }else{
        @try {
            [[[OMRONDeviceManager alloc]init]scanAllBPDevicesComplete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName)  {
                    if(status==OMRON_SDK_Success)
                    {
                       complete(status,deviceName,deviceId,advertisingName);
                    }
                    else
                    {
                       complete(status,deviceName,deviceId,advertisingName);
                    }
                }];
                return;
             } @catch (NSException *exception) {

             } @finally {
         }
    }

}

//绑定血压计设备
- (void)bindDevice:(OMRONDeviceType)deviceType complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete{
    [self bindBPDevice:deviceType deviceSerialNum:@"" complete:complete];
     
}

//根据seaialNumber绑定血压计设备
- (void)bindBPDevice:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete {
    if (ISPOSTDATA) {
        @try {
        if([self isRegister])
            {
                NSArray *devicelist = [self getOMRONDeviceList];
                if(deviceType==OMRON_BLOOD_U32J)
                 {
                     if(![devicelist containsObject:@"U32J"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U32J",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U32J",nil];
                 }
                 else if(deviceType==OMRON_BLOOD_9200T)
                 {
                     if(![devicelist containsObject:@"HEM-9200T"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HEM-9200T",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HEM-9200T",nil];
                 }
                 else if(deviceType==OMRON_BLOOD_J750)
                 {
                     if(![devicelist containsObject:@"J750"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J750",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J750",nil];
                 }
                 else if(deviceType==OMRON_BLOOD_J730)
                 {
                     if(![devicelist containsObject:@"J730"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J730",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J730",nil];
                 }
                 else if(deviceType==OMRON_BLOOD_J761)
                {
                    if(![devicelist containsObject:@"J761"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J761",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J761",nil];
                 }
                else if(deviceType==OMRON_BLOOD_9200L)
                 {
                     if(![devicelist containsObject:@"HEM-9200L"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HEM-9200L",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HEM-9200L",nil];
                  }
                else if(deviceType==OMRON_BLOOD_U32K)
                {
                    if(![devicelist containsObject:@"U32K"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U32k",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U32K",nil];
                 }
                else if(deviceType==OMRON_BLOOD_J750L)
                {
                    if(![devicelist containsObject:@"J750L"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J750L",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J750L",nil];
                 }
                else if(deviceType==OMRON_BLOOD_U18)
                {
                    if(![devicelist containsObject:@"U18"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U18",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U18",nil];
                } else if(deviceType==OMRON_BLOOD_J760)
                {
                    if(![devicelist containsObject:@"J760"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J760",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J760",nil];
                 }else if(deviceType==OMRON_BLOOD_T50)
                 {
                     if(![devicelist containsObject:@"T50"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"T50",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"T50",nil];
                  }else if(deviceType==OMRON_BLOOD_U32)
                  {
                      if(![devicelist containsObject:@"U32"])
                      {
                          [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U32",nil];
                          complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                          return;
                      }
                      [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U32",nil];
                   }else if(deviceType==OMRON_BLOOD_J732)
                   {
                       if(![devicelist containsObject:@"J732"])
                       {
                           [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J732",nil];
                           complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                           return;
                       }
                       [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J732",nil];
                    }else if(deviceType==OMRON_BLOOD_J751)
                    {
                        if(![devicelist containsObject:@"J751"])
                        {
                            [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J751",nil];
                            complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                            return;
                        }
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J751",nil];
                     }else if(deviceType==OMRON_BLOOD_U36J)
                     {
                         if(![devicelist containsObject:@"U36J"])
                         {
                             [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U36J",nil];
                             complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                             return;
                         }
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U36J",nil];
                      }else if(deviceType==OMRON_BLOOD_U36T)
                      {
                          if(![devicelist containsObject:@"U36T"])
                          {
                              [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U36T",nil];
                              complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                              return;
                          }
                          [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U36T",nil];
                       }else if(deviceType==OMRON_HEM_6231T)
                       {
                           if(![devicelist containsObject:@"6231T"])
                           {
                               [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HEM6231T",nil];
                               complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                               return;
                           }
                           [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HEM6231T",nil];
                        }
                
                 else
                 {
                     complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                     return;
                 }
                [[[OMRONDeviceManager alloc] init] bingBPDevice:deviceType deviceSerialNum:deviceSerialNum complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName) {
                    if(status==OMRON_SDK_Success)
                       {
                         [self bindDeviceService:advertisingName deviceName:deviceName advertisingName:advertisingName userIndex:1 complete:^(OMRONSDKStatus status, NSString *deviceName, NSString *deviceId, NSString *advertisingName) {
                             complete(status,deviceName,deviceId,advertisingName);
                         }];
                        }
                        else
                        {
                            complete(status,deviceName,deviceId,advertisingName);
                        }
                }];
                return;

            }
             else
             {
                 [LogManager logInfo:OLOG(@"binding equipment") logStr:@"SDK unregister",nil];
                 complete(OMRON_SDK_UnRegister,nil,nil,nil);
             }
             
             } @catch (NSException *exception) {
                 [LogManager logErrorInfo:OLOG(@"binding equipment") logStr:@"binding equipment  exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
             } @finally {
                 
             }
    }else{
        @try {
                NSArray *devicelist = [self getOMRONDeviceList];
                if(deviceType==OMRON_BLOOD_U32J)
                 {
                     if(![devicelist containsObject:@"U32J"])
                     {
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                   
                 }
                 else if(deviceType==OMRON_BLOOD_9200T)
                 {
                     if(![devicelist containsObject:@"HEM-9200T"])
                     {
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                 }
                 else if(deviceType==OMRON_BLOOD_J750)
                 {
                     if(![devicelist containsObject:@"J750"])
                     {
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                 }
                 else if(deviceType==OMRON_BLOOD_J730)
                 {
                     if(![devicelist containsObject:@"J730"])
                     {
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                 }
                 else if(deviceType==OMRON_BLOOD_J761)
                {
                    if(![devicelist containsObject:@"J761"])
                    {
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                 }
                else if(deviceType==OMRON_BLOOD_9200L)
                 {
                     if(![devicelist containsObject:@"HEM-9200L"])
                     {
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                  }
                else if(deviceType==OMRON_BLOOD_U18)
                 {
                     if(![devicelist containsObject:@"U18"])
                     {
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                  }
                else if(deviceType==OMRON_BLOOD_J760)
               {
                   if(![devicelist containsObject:@"J760"])
                   {
                       [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J760",nil];
                       complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                       return;
                   }
                   [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J760",nil];
                }else if(deviceType==OMRON_BLOOD_T50)
                {
                    if(![devicelist containsObject:@"T50"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"T50",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"T50",nil];
                 }else if(deviceType==OMRON_BLOOD_U32)
                 {
                     if(![devicelist containsObject:@"U32"])
                     {
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U32",nil];
                         complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                         return;
                     }
                     [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U32",nil];
                  }else if(deviceType==OMRON_BLOOD_J732)
                  {
                      if(![devicelist containsObject:@"J732"])
                      {
                          [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J732",nil];
                          complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                          return;
                      }
                      [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J732",nil];
                   }else if(deviceType==OMRON_BLOOD_J751)
                   {
                       if(![devicelist containsObject:@"J751"])
                       {
                           [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"J751",nil];
                           complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                           return;
                       }
                       [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"J751",nil];
                    }else if(deviceType==OMRON_BLOOD_U36J)
                    {
                        if(![devicelist containsObject:@"U36J"])
                        {
                            [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U36J",nil];
                            complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                            return;
                        }
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U36J",nil];
                     }else if(deviceType==OMRON_BLOOD_U36T)
                     {
                         if(![devicelist containsObject:@"U36T"])
                         {
                             [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"U36T",nil];
                             complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                             return;
                         }
                         [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"U36T",nil];
                      }else if(deviceType==OMRON_HEM_6231T)
                      {
                          if(![devicelist containsObject:@"6231T"])
                          {
                              [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HEM6231T",nil];
                              complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                              return;
                          }
                          [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HEM6231T",nil];
                       }
                 else
                 {
                     complete(OMRON_SDK_UnSupportDevice,@"",@"",@"");
                     return;
                 }
            [[[OMRONDeviceManager alloc]init]bingBPDevice:deviceType complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName)  {
                    if(status==OMRON_SDK_Success)
                    {
                       complete(status,deviceName,deviceId,advertisingName);
                    }
                    else
                    {
                       complete(status,deviceName,deviceId,advertisingName);
                    }
                }];
                return;
             } @catch (NSException *exception) {
                 
             } @finally {
         }
    }
}


- (void)bindBFDevice:(OMRONDeviceType)deviceType status:(void(^)(OMRONBLESStaus statue))status userIndexBlock:(void(^)(NSString *deviceId,id<OMRONBFAppendUserIndexDelegate> indexData))userIndexBlock birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete
{
    if(ISPOSTDATA){
        @try {
            if([self isRegister])
            {
                NSArray *devicelist = [self getOMRONDeviceList];
                if(deviceType==OMRON_HBF_219T)
                {
                    if(![devicelist containsObject:@"HBF-219T"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HBF_219T",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HBF_219T",nil];
                }else if(deviceType==OMRON_HBF_229T) {
                    if(![devicelist containsObject:@"HBF-229T"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HBF_229T",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HBF_229T",nil];
                }
                [[[OMRONDeviceManager alloc] init] bindBFDevice:deviceType status:status userIndexBlock:userIndexBlock birthday:birthday height:height isMale:isMale complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSInteger userIndex, NSString * _Nonnull advertisingName, NSDictionary * _Nonnull userInfo) {
                    if(status==OMRON_SDK_Success)
                    {
                        [self bindDeviceService:advertisingName deviceName:deviceName advertisingName:advertisingName userIndex:userIndex complete:^(OMRONSDKStatus status, NSString *deviceName, NSString *deviceId, NSString *advertisingName) {
                            if(status==OMRON_SDK_Success)
                            {
                                [self uploadUserInfo:userInfo userIndex:userIndex deviceName:deviceName advertisingName:advertisingName complete:^(OMRONSDKStatus status, NSString *deviceName, NSString *deviceId, NSString *advertisingName) {
                         complete(status,deviceName,userIndex,advertisingName,userInfo);
                                }];
                            }
                            else
                            {
                             complete(status,deviceName,userIndex,advertisingName,nil);
                            }
                        }];
                    }
                    else
                    {
                        complete(status,deviceName,userIndex,advertisingName,nil);
                    }
                }];
                return;
            }
            else
            {
                [LogManager logInfo:OLOG(@"binding equipment") logStr:@"SDK unregister",nil];
                complete(OMRON_SDK_UnRegister,nil,0,nil,nil);
            }
        } @catch (NSException *exception) {
            [LogManager logErrorInfo:OLOG(@"binding equipment") logStr:@"binding equipment  exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
        } @finally {
            
        }
    }else{
        @try {
                NSArray *devicelist = [self getOMRONDeviceList];
                if(deviceType==OMRON_HBF_219T)
                {
                    if(![devicelist containsObject:@"HBF-219T"])
                    {
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                }else if (deviceType==OMRON_HBF_229T) {
                    if(![devicelist containsObject:@"HBF-229T"])
                    {
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                }
            [[[OMRONDeviceManager alloc] init] bindBFDevice:deviceType status:status userIndexBlock:userIndexBlock birthday:birthday height:height isMale:isMale complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSInteger userIndex, NSString * _Nonnull advertisingName, NSDictionary * _Nonnull userInfo) {
                if(status==OMRON_SDK_Success)
                {
                     complete(status,deviceName,userIndex,advertisingName,userInfo);
                }
                else
                {
                    complete(status,deviceName,userIndex,advertisingName,nil);
                }
            }];
            return;
           
        } @catch (NSException *exception) {
          
        } @finally {
            
        }
    }
    
    
    
}

- (void)bindBFDevice:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete
{
    if (ISPOSTDATA) {
        @try {
            if([self isRegister])
            {
                NSArray *devicelist = [self getOMRONDeviceList];
                if(deviceType==OMRON_HBF_219T)
                {
                    if(![devicelist containsObject:@"HBF-219T"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HBF_219T",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HBF_219T",nil];
                }else if (deviceType==OMRON_HBF_229T){
                    if(![devicelist containsObject:@"HBF-229T"])
                    {
                        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"unsupport",@"HBF_229T",nil];
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                    [LogManager logInfo:OLOG(@"binding equipment") logStr:@"begin binding",@"HBF_229T",nil];
                }
                [[[OMRONDeviceManager alloc] init] bindBFDevice:deviceType userIndex:userIndex birthday:birthday height:height isMale:isMale complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSInteger userIndex, NSString * _Nonnull advertisingName, NSDictionary * _Nonnull userInfo) {
                    if(status==OMRON_SDK_Success)
                    {
                        [self bindDeviceService:advertisingName deviceName:deviceName advertisingName:advertisingName userIndex:userIndex complete:^(OMRONSDKStatus status, NSString *deviceName, NSString *deviceId, NSString *advertisingName) {
                            if(status==OMRON_SDK_Success)
                            {
                                [self uploadUserInfo:userInfo userIndex:userIndex deviceName:deviceName advertisingName:advertisingName complete:^(OMRONSDKStatus status, NSString *deviceName, NSString *deviceId, NSString *advertisingName) {
                                    complete(status,deviceName,userIndex,advertisingName,userInfo);
                                }];
                            }
                            else
                            {
                                complete(status,deviceName,userIndex,advertisingName,nil);
                            }
                        }];
                    }
                    else
                    {
                        complete(status,deviceName,userIndex,advertisingName,nil);
                    }
                    
                }];
                return;
            }
            else
            {
                [LogManager logInfo:OLOG(@"binding equipment") logStr:@"SDK unregister",nil];
                complete(OMRON_SDK_UnRegister,nil,0,nil,nil);
            }
        } @catch (NSException *exception) {
            [LogManager logErrorInfo:OLOG(@"binding equipment") logStr:@"binding equipment  exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
        } @finally {
            
        }
    }else{
        @try {
                NSArray *devicelist = [self getOMRONDeviceList];
                if(deviceType==OMRON_HBF_219T)
                {
                    if(![devicelist containsObject:@"HBF-219T"])
                    {
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                }else if (deviceType==OMRON_HBF_229T) {
                    if(![devicelist containsObject:@"HBF-229T"])
                    {
                        complete(OMRON_SDK_UnSupportDevice,@"",0,@"",@{});
                        return;
                    }
                }
            [[[OMRONDeviceManager alloc] init] bindBFDevice:deviceType userIndex:userIndex birthday:birthday height:height isMale:isMale complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSInteger userIndex, NSString * _Nonnull advertisingName, NSDictionary * _Nonnull userInfo) {
                if(status==OMRON_SDK_Success)
                {
                    complete(status,deviceName,userIndex,advertisingName,userInfo);
                }
                else
                {
                    complete(status,deviceName,userIndex,advertisingName,nil);
                }
                
            }];
            return;
       
        } @catch (NSException *exception) {
           
        } @finally {
            
        }
    }
    
}

- (void)getDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSArray<OMRONBPObject *> *datas))complete{
    if (ISPOSTDATA) {
        @try {
            if([self isRegister])
           {
               NSString *bPdeviceType;
               if(deviceType==OMRON_BLOOD_9200T)
                  {
                      [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Get device data to start",@"HEM-9200T",nil];
                      bPdeviceType = @"HEM-9200T";
                  }
                  else if(deviceType==OMRON_BLOOD_U32J)
                  {
                      [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"U32J",nil];
                      bPdeviceType = @"U32J";
                  }
                  else if(deviceType==OMRON_BLOOD_J730)
                  {
                      [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J730",nil];
                      bPdeviceType = @"J730";
                  }
                  else if(deviceType==OMRON_BLOOD_J761)
                 {
                     [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J761",nil];
                     bPdeviceType = @"J761";
                 }
                 else if(deviceType==OMRON_BLOOD_9200L)
                  {
                      [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"HEM-9200L",nil];
                      bPdeviceType = @"HEM-9200L";
                  }
               else if(deviceType==OMRON_BLOOD_U32K)
                   {
                       [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"U32K",nil];
                       bPdeviceType = @"U32K";
                   }
               else if(deviceType==OMRON_BLOOD_J750L)
                   {
                       [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J750L",nil];
                       bPdeviceType = @"J750L";
                   }
               else if(deviceType==OMRON_BLOOD_U18)
                   {
                       [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"U18",nil];
                       bPdeviceType = @"U18";
                   }
               else if(deviceType==OMRON_BLOOD_J760)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J760",nil];
                  bPdeviceType = @"J760";
              } else if(deviceType==OMRON_BLOOD_T50)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"T50",nil];
                  bPdeviceType = @"T50";
              } else if(deviceType==OMRON_BLOOD_U32)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"U32",nil];
                  bPdeviceType = @"U32";
              } else if(deviceType==OMRON_BLOOD_J732)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J732",nil];
                  bPdeviceType = @"J732";
              } else if(deviceType==OMRON_BLOOD_J751)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J751",nil];
                  bPdeviceType = @"J751";
              } else if(deviceType==OMRON_BLOOD_U36J)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"U36J",nil];
                  bPdeviceType = @"U36J";
              } else if(deviceType==OMRON_BLOOD_U36T)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"U36T",nil];
                  bPdeviceType = @"U36T";
              } else if(deviceType==OMRON_HEM_6231T)
              {
                  [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"HEM_6231T",nil];
                  bPdeviceType = @"HEM_6231T";
              }
                  else
                  {
                      [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"begin to get device data",@"J750",nil];
                      bPdeviceType = @"J750";
                  }
//                  NSLog(@"-------%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"scanStatus"]);
                   [[[OMRONDeviceManager alloc]init] getBpDeviceData:deviceType deviceSerialNum:deviceSerialNum complete:^(OMRONSDKStatus status, NSArray<NSDictionary *> * _Nonnull measurementRecords){
                       if(status ==OMRON_SDK_Success){
                           
                           NSMutableArray *results = [NSMutableArray array];
                          for (NSDictionary *dic in measurementRecords) {
                              OMRONBPObject *obj = [[OMRONBPObject alloc] init];
                              obj.measure_at = ((NSDate *)[dic valueForKey:@"timeStamp"]).timeIntervalSince1970;
                              obj.sbp = [[dic valueForKey:@"systolic"] integerValue];
                              obj.dbp = [[dic valueForKey:@"diastolic"] integerValue];
                              obj.pulse = [[dic valueForKey:@"pulseRate"] integerValue];
                              NSNumber *bloodPressureMeasurementStatus = dic[OHQMeasurementRecordBloodPressureMeasurementStatusKey];
                              if (bloodPressureMeasurementStatus) {
                                  OHQBloodPressureMeasurementStatus status = bloodPressureMeasurementStatus.unsignedShortValue;
                                  if (status != 0) {
                                      if (status & OHQBloodPressureMeasurementStatusBodyMovementDetected) {
                                          obj.bm_flg = 1;
                                      }
                                      if (status & OHQBloodPressureMeasurementStatusCuffTooLoose) {
                                          obj.cws_flg = 1;
                                      }
                                      if (status & OHQBloodPressureMeasurementStatusIrregularPulseDetected) {
                                          obj.ihb_flg = 1;
                                      }
                                  }
                              }
                              obj.device_type = bPdeviceType;
                              [results addObject:obj];
                          }
                           
                           [self handelBPData:results serialNum:deviceSerialNum deviceType:bPdeviceType advertisingName:deviceSerialNum complete:^(bool result) {
                               if(!result)
                               {
                               [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Device data was read successfully",@"Device data storage completes locally",nil];
                      
                               complete(OMRON_SDK_Success,results);
                                  
                               }
                               else
                               {
                                   [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Device data was read successfully",@"Device data storage completes locally",@"InValidKey",nil];
                                   complete(OMRON_SDK_InValidKey,[NSArray new]);
                               }
                           }];
                       }else{
                           complete(status,nil);
                       }
                     }];
   
               }
               else
               {
                   [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"device unregister",nil];
                   complete(OMRON_SDK_UnRegister,nil);
               }
            
        } @catch (NSException *exception) {
            [LogManager logErrorInfo:OLOG(@"Acquisition of device data") logStr:@"Get device data exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
//            complete(OMRON_SDK_ConnectFail,[NSString stringWithFormat:@"获取血压数据lib datatrue:%@",exception.name],nil);
            complete(OMRON_SDK_ConnectFail,nil);
        } @finally {
            
        }
    }else{
        @try {
               NSString *bPdeviceType;
               if(deviceType==OMRON_BLOOD_9200T)
                  {
                      bPdeviceType = @"HEM-9200T";
                  }
                  else if(deviceType==OMRON_BLOOD_U32J)
                  {
                      bPdeviceType = @"U32J";
                  }
                  else if(deviceType==OMRON_BLOOD_J730)
                  {
                      bPdeviceType = @"J730";
                  }
                  else if(deviceType==OMRON_BLOOD_J761)
                 {
                     bPdeviceType = @"J761";
                 }
                 else if(deviceType==OMRON_BLOOD_9200L)
                  {
                      bPdeviceType = @"HEM-9200L";
                  }
                 else if(deviceType==OMRON_BLOOD_U18)
                 {
                     bPdeviceType = @"U18";
                 }
                 else if(deviceType==OMRON_BLOOD_J760)
                {
                    bPdeviceType = @"J760";
                }else if(deviceType==OMRON_BLOOD_T50)
                {
                    bPdeviceType = @"T50";
                }else if(deviceType==OMRON_BLOOD_U32)
                {
                    bPdeviceType = @"U32";
                }else if(deviceType==OMRON_BLOOD_J732)
                {
                    bPdeviceType = @"J732";
                }else if(deviceType==OMRON_BLOOD_J751)
                {
                    bPdeviceType = @"J751";
                }else if(deviceType==OMRON_BLOOD_U36J)
                {
                    bPdeviceType = @"U36J";
                }else if(deviceType==OMRON_BLOOD_U36T)
                {
                    bPdeviceType = @"U36T";
                }else if(deviceType==OMRON_HEM_6231T)
                {
                    bPdeviceType = @"HEM_6231T";
                }
                  else
                  {
                      bPdeviceType = @"J750";
                  }
               
            [[[OMRONDeviceManager alloc]init] getBpDeviceData:deviceType deviceSerialNum:deviceSerialNum complete:^(OMRONSDKStatus status, NSArray<NSDictionary *> * _Nonnull measurementRecords) {
                   if(status ==OMRON_SDK_Success){
                       
                       NSMutableArray *results = [NSMutableArray array];
                      for (NSDictionary *dic in measurementRecords) {
                          OMRONBPObject *obj = [[OMRONBPObject alloc] init];
                          obj.measure_at = ((NSDate *)[dic valueForKey:@"timeStamp"]).timeIntervalSince1970;
                          obj.sbp = [[dic valueForKey:@"systolic"] integerValue];
                          obj.dbp = [[dic valueForKey:@"diastolic"] integerValue];
                          obj.pulse = [[dic valueForKey:@"pulseRate"] integerValue];
                          NSNumber *bloodPressureMeasurementStatus = dic[OHQMeasurementRecordBloodPressureMeasurementStatusKey];
                          if (bloodPressureMeasurementStatus) {
                              OHQBloodPressureMeasurementStatus status = bloodPressureMeasurementStatus.unsignedShortValue;
                              if (status != 0) {
                                  if (status & OHQBloodPressureMeasurementStatusBodyMovementDetected) {
                                      obj.bm_flg = 1;
                                  }
                                  if (status & OHQBloodPressureMeasurementStatusCuffTooLoose) {
                                      obj.cws_flg = 1;
                                  }
                                  if (status & OHQBloodPressureMeasurementStatusIrregularPulseDetected) {
                                      obj.ihb_flg = 1;
                                  }
                              }
                          }
                          obj.device_type = bPdeviceType;
                          [results addObject:obj];
                      }
                           complete(OMRON_SDK_Success,results);
                   }else{
                       complete(status,nil);
                   }
                 }];
        } @catch (NSException *exception) {
//            complete(OMRON_SDK_ConnectFail,[NSString stringWithFormat:@"获取血压数据lib datafail:%@",exception.name],nil);
            complete(OMRON_SDK_ConnectFail,nil);
        } @finally {
            
        }
    }
    
}


-(void)getBFDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSArray<OMRONBFObject *> *datas,NSDictionary *userInfo))complete
{
    if(ISPOSTDATA){
    @try {
        if([self isRegister])
        {
            if(deviceType==OMRON_HBF_219T)
            {
                [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Get device data to start",@"HBF-2009T",nil];
            }
            if(deviceType==OMRON_HBF_229T)
            {
                [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Get device data to start",@"HBF-229T",nil];
            }
            [[[OMRONDeviceManager alloc] init] getBFDeviceData:deviceType deviceSerialNum:deviceSerialNum userIndex:userIndex birthday:birthday height:height isMale:isMale complete:^(OMRONSDKStatus status,NSArray<NSDictionary *> *measurementRecords,NSDictionary *userInfo) {
                if(status ==OMRON_SDK_Success)
                {
                    NSMutableArray *results = [NSMutableArray array];
                    for (NSDictionary *dic in measurementRecords) {
                        OMRONBFObject *obj = [[OMRONBFObject alloc] init];
                        obj.bmi = [dic valueForKey:@"BMI"];
                        obj.basal_metabolism = roundf([[dic valueForKey:@"basalMetabolism"] integerValue]/4.184);
                        obj.body_age = [[dic valueForKey:@"bodyAge"] integerValue];
                        obj.fat_rate = [[dic valueForKey:@"bodyFatPercentage"] floatValue]*100;
                        obj.weight = [[dic valueForKey:@"weight"] floatValue];
                        obj.userIndex = [[dic valueForKey:@"userIndex"] integerValue];
                        obj.visceral_fat = [[dic valueForKey:@"visceralFatLevel"] floatValue]*2;
                        obj.skeletal_muscles_rate = [[dic valueForKey:@"skeletalMusclePercentage"] floatValue]*100;
                        obj.measure_at = ((NSDate *)[dic valueForKey:@"timeStamp"]).timeIntervalSince1970;
                        obj.device_type = deviceType==OMRON_HBF_229T?@"HNF-229T":@"HNF-219T";
                        NSDate *birthdayStr = [userInfo objectForKey:@"dateOfBirth"];
                        NSDateFormatter *format = [[NSDateFormatter alloc] init];
                        format.dateFormat = @"yyyy-MM-dd";
                        format.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                        NSString *newString = [format stringFromDate:birthdayStr];
                        obj.birthday = newString;
                        obj.gender = [[userInfo objectForKey:@"gender"] isEqualToString:@"male"]?@"0":@"1";
                        obj.height = [[userInfo valueForKey:@"height"] floatValue];
                        [results addObject:obj];
                    }
                    NSString * TYPE = @"HBF-219T";
                    if (deviceType==OMRON_HBF_229T) {
                        TYPE = @"HBF-229T";
                    }
                    [self handelBFData:results serialNum:deviceSerialNum deviceType:TYPE advertisingName:deviceSerialNum complete:^(bool result) {
                        if(!result)
                        {
                            [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Device data was read successfully",@"Device data storage completes locally",nil];
                            complete(OMRON_SDK_Success,results,userInfo);
                        }
                        else
                        {
                            [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"Device data was read successfully",@"Device data storage completes locally",@"InValidKey",nil];
                            complete(OMRON_SDK_InValidKey,[NSArray new],nil);
                        }
                    }];
                }
                else
                {
                    complete(status,nil,nil);
                }
            }];
        }
        else
        {
            [LogManager logInfo:OLOG(@"Acquisition of device data") logStr:@"device unregister",nil];
            complete(OMRON_SDK_UnRegister,[NSArray new],nil);
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    }else{
        @try {
                [[[OMRONDeviceManager alloc] init] getBFDeviceData:deviceType deviceSerialNum:deviceSerialNum userIndex:userIndex birthday:birthday height:height isMale:isMale complete:^(OMRONSDKStatus status,NSArray<NSDictionary *> *measurementRecords,NSDictionary *userInfo) {
                    if(status ==OMRON_SDK_Success)
                    {
                        NSMutableArray *results = [NSMutableArray array];
                        for (NSDictionary *dic in measurementRecords) {
                            OMRONBFObject *obj = [[OMRONBFObject alloc] init];
                            obj.bmi = [dic valueForKey:@"BMI"];
                            obj.basal_metabolism = roundf([[dic valueForKey:@"basalMetabolism"] integerValue]/4.184);
                            obj.body_age = [[dic valueForKey:@"bodyAge"] integerValue];
                            obj.fat_rate = [[dic valueForKey:@"bodyFatPercentage"] floatValue]*100;
                            obj.weight = [[dic valueForKey:@"weight"] floatValue];
                            obj.userIndex = [[dic valueForKey:@"userIndex"] integerValue];
                            obj.visceral_fat = [[dic valueForKey:@"visceralFatLevel"] floatValue]*2;
                            obj.skeletal_muscles_rate = [[dic valueForKey:@"skeletalMusclePercentage"] floatValue]*100;
                            obj.measure_at = ((NSDate *)[dic valueForKey:@"timeStamp"]).timeIntervalSince1970;
                            obj.device_type = deviceType==OMRON_HBF_229T?@"HNF-229T":@"HNF-219T";
                            NSDate *birthdayStr = [userInfo objectForKey:@"dateOfBirth"];
                            NSDateFormatter *format = [[NSDateFormatter alloc] init];
                            format.dateFormat = @"yyyy-MM-dd";
                            format.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                            NSString *newString = [format stringFromDate:birthdayStr];
                            obj.birthday = newString;
                            obj.gender = [[userInfo objectForKey:@"gender"] isEqualToString:@"male"]?@"0":@"1";
                            obj.height = [[userInfo valueForKey:@"height"] floatValue];
                            [results addObject:obj];
                        }
                        complete(OMRON_SDK_Success,results,userInfo);
                    }
                    else
                    {
                        complete(status,nil,nil);
                    }
                }];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }

    }
}

- (void)unBindDevice:(NSString *)uuid
{
    OMRONBLEDeviceManager *bleDeviceManager = [OMRONBLEDeviceManager getBLEDevManager];
    [bleDeviceManager unbindDevice:uuid];
}

//获取可用设备列表
- (NSArray<NSString *> *)getOMRONDeviceList
{
    NSArray *array = [NSArray array];
    @try {
        NSUserDefaults *deviceDefaults = [NSUserDefaults standardUserDefaults];
        array = [deviceDefaults valueForKey:OMRON_OBJ_DEVICE_LIST];
    } @catch (NSException *exception) {
        [LogManager logErrorInfo:OLOG(@"Get the list of authorized devices") logStr:@"Get authorized device list exception",exception.name,exception.reason,exception.debugDescription,nil];
    } @finally {
        return array;
    }
}

-(BOOL)isRegister;
{
    if(isRegister)
    {
        if(IsStrEmpty([self getUUID]))
        {
            return false;
        }
        
        return true;
    }
    
    return false;
}

-(NSString *)getUUID
{
    NSUserDefaults *uuidDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [uuidDefaults valueForKey:OMRON_OBJ_UUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(IsStrEmpty(result))
    {
        result = [OMRONKeychainTool getDeviceIDInKeychain];
    }
    return result;
}

-(void)handelBPData:(NSArray *)datas serialNum:(NSString *)serialNum deviceType:(NSString *)deviceType advertisingName:(NSString *)advertisingName complete:(void(^)(bool))complete
{
    /*
     * 1.存储血压数据到本地.     2.a判断当前是否有网络.   3.有网络上传本地数据 成功之后删除本地数据 失败之后保存本地等待下次上传
     */
    //
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    BOOL isExists = [fileManager fileExistsAtPath:OMRON_BPDATAS_FILE];
    if(isExists)
    {
        NSMutableDictionary *localData = [NSMutableDictionary dictionaryWithContentsOfFile:OMRON_BPDATAS_FILE];
        NSMutableArray *result = [localData valueForKey:[self getUUID]];
        if(result==nil)
        {
            result = [NSMutableArray array];
        }
        for (OMRONBPObject *obj in datas) {
            obj.device_digital_id = serialNum;
            obj.device_type = deviceType;
            obj.device_ble_cmn_id = advertisingName;
            [result addObject:[obj modelToDic:obj]];
        }
        [fileDic setObject:result forKey:[self getUUID]];
    }
    else
    {
        NSMutableArray *result = [NSMutableArray array];
        for (OMRONBPObject *obj in datas) {
            obj.device_digital_id = serialNum;
            obj.device_type = deviceType;
            obj.device_ble_cmn_id = advertisingName;
            [result addObject:[obj modelToDic:obj]];
        }
        [fileDic setObject:result forKey:[self getUUID]];
    }
    [fileDic writeToFile:OMRON_BPDATAS_FILE atomically:YES];
    [self uploadLocalBPData:complete];
}

-(void)handelBFData:(NSArray *)datas serialNum:(NSString *)serialNum deviceType:(NSString *)deviceType advertisingName:(NSString *)advertisingName complete:(void(^)(bool))complete
{
    /*
     * 1.存储体脂数据到本地.     2.判断当前是否有网络.   3.有网络上传本地数据 成功之后删除本地数据 失败之后保存本地等待下次上传
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    BOOL isExists = [fileManager fileExistsAtPath:OMRON_BFDATAS_FILE];
    if(isExists)
    {
        NSMutableDictionary *localData = [NSMutableDictionary dictionaryWithContentsOfFile:OMRON_BFDATAS_FILE];
        NSMutableArray *result = [localData valueForKey:[self getUUID]];
        if(result==nil)
        {
            result = [NSMutableArray array];
        }
        for (OMRONBFObject *obj in datas) {
            obj.device_digital_id = serialNum;
            obj.device_type = deviceType;
            obj.device_ble_cmn_id = advertisingName;
            [result addObject:[obj modelToDic:obj]];
        }
        [fileDic setObject:result forKey:[self getUUID]];
    }
    else
    {
        NSMutableArray *result = [NSMutableArray array];
        for (OMRONBFObject *obj in datas) {
            obj.device_digital_id = serialNum;
            obj.device_type = deviceType;
            obj.device_ble_cmn_id = advertisingName;
            [result addObject:[obj modelToDic:obj]];
        }
        [fileDic setObject:result forKey:[self getUUID]];
    }
    [fileDic writeToFile:OMRON_BFDATAS_FILE atomically:YES];
    [self uploadLocalBFData:complete];
}

-(void)bindDeviceService:(NSString *)serialNum deviceName:(NSString*)deviceName advertisingName:(NSString*)advertisingName userIndex:(NSInteger)userIndex complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete
{
    if([[NetTool shareInstance] isHasNet])
    {
        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Clear device data complete",nil];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[self getUUID] forKey:@"uuid"];
        [dic setValue:serialNum forKey:@"device_digital_id"];
        [dic setValue:deviceName forKey:@"device_type"];
        [dic setValue:advertisingName forKey:@"device_ble_cmn_id"];
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)userIndex] forKey:@"device_user_type_id"];

        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Binding devices invoke apis",[LogManager toJasonString:dic],nil];
        [[NetTool shareInstance] post:[NSString stringWithFormat:@"%@%@",BASE_URL,@"v1/Sdk/device_info"] params:dic success:^(id  _Nonnull responseObj) {
            if([responseObj isKindOfClass:[NSDictionary class]])
            {
                [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Binding device call API complete",[LogManager toJasonString:responseObj],nil];
                NSInteger code = [[responseObj valueForKey:@"code"] integerValue];
                if(code==1)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(OMRON_SDK_Success,deviceName,serialNum,advertisingName);
                    });
                }
                else if(code==-740004)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(OMRON_SDK_InValidKey,@"",@"",@"");
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(OMRON_SDK_BindFail,@"",@"",@"");
                    });
                }
            }
        } failture:^(NSError * _Nonnull error,id  _Nonnull responseObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(OMRON_SDK_UnBind,@"",@"",@"");
            });
            [LogManager logErrorInfo:OLOG(@"binding equipment") logStr:@"调用绑定API失败",[LogManager toJasonString:error.userInfo],nil];
        }];
    }
    else
    {
        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Clear device data complete",@"no network",nil];
        complete(OMRON_SDK_NoNet,@"",@"",@"");
    }
}

//绑定体脂设备时 不做个人信息离线缓存功能
-(void)uploadUserInfo:(NSDictionary *)userInfo userIndex:(NSInteger)userIndex deviceName:(NSString*)deviceName advertisingName:(NSString*)advertisingName complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete
{
    if([[NetTool shareInstance] isHasNet])
    {
        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Binding upload userinfo",nil];
        NSDate *birthdayStr = [userInfo objectForKey:@"dateOfBirth"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy-MM-dd";
        format.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        NSString *newString = [format stringFromDate:birthdayStr];
        NSMutableDictionary *userInfos = [NSMutableDictionary dictionary];
        [userInfos setValue:[self getUUID] forKey:@"uuid"];
        [userInfos setValue:newString forKey:@"birthday"];
        [userInfos setValue:advertisingName forKey:@"device_ble_cmn_id"];
        [userInfos setValue:advertisingName forKey:@"device_digital_id"];
        [userInfos setValue:[NSString stringWithFormat:@"%ld",(long)userIndex] forKey:@"device_user_type_id"];
        [userInfos setValue:[userInfo objectForKey:@"height"] forKey:@"height"];
        [userInfos setValue:[[userInfo objectForKey:@"gender"] isEqualToString:@"male"]?@"0":@"1" forKey:@"gender"];
        [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Binding upload userinfo",[LogManager toJasonString:userInfos],nil];
        [[NetTool shareInstance] post:[NSString stringWithFormat:@"%@%@",BASE_URL,@"v1/Sdk/person_info"] params:userInfos success:^(id  _Nonnull responseObj) {
            if([responseObj isKindOfClass:[NSDictionary class]])
            {
                [LogManager logInfo:OLOG(@"binding equipment") logStr:@"Binding upload userinfo",[LogManager toJasonString:responseObj],nil];
                NSInteger code = [[responseObj valueForKey:@"code"] integerValue];
                if(code==1)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(OMRON_SDK_Success,deviceName,advertisingName,advertisingName);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(OMRON_SDK_BindFail,@"",@"",@"");
                    });
                }
            }
        } failture:^(NSError * _Nonnull error,id  _Nonnull responseObj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(OMRON_SDK_UnBind,@"",@"",@"");
            });
            [LogManager logErrorInfo:OLOG(@"binding equipment") logStr:@"调用绑定API失败",[LogManager toJasonString:error.userInfo],nil];
        }];
    }
    else
    {
        [LogManager logInfo:OLOG(@"uploadUserInfo") logStr:@"upload BF userinfo",@"no network",nil];
        complete(OMRON_SDK_NoNet,@"",@"",@"");
    }
}

-(void)uploadLocalBPData:(void(^)(bool))complete
{
    __block BOOL isExpire = false;
    @try {
        [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"To upload",nil];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:OMRON_BPDATAS_FILE];
        if(isExists)
        {
            NSMutableDictionary *localData = [NSMutableDictionary dictionaryWithContentsOfFile:OMRON_BPDATAS_FILE];
            NSMutableArray *result = [localData valueForKey:[self getUUID]];
            if(result==nil)
            {
                result = [NSMutableArray array];
            }
            //判断是否有网络
            if([[NetTool shareInstance] isHasNet])
            {
                //上传成功之后删除本地文件
                if(isExists&&result.count>0)
                {
                    [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"Local blood pressure data exist",[LogManager toJasonString:result],nil];
                    NSInteger groupCount = 500;
                    NSInteger totalGroup=result.count/groupCount;
                    if(result.count%groupCount>0)
                    {
                        totalGroup++;
                    }
                    NSMutableArray *arrayOfArrays = [NSMutableArray array];
                    NSUInteger itemsRemaining = result.count;
                    int j = 0;
                    while(itemsRemaining) {
                        NSRange range = NSMakeRange(j, MIN(1, itemsRemaining));
                        NSArray *subLogArr = [result subarrayWithRange:range];
                        [arrayOfArrays addObject:subLogArr];
                        itemsRemaining-=range.length;
                        j+=range.length;
                    }
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_queue_t queue = dispatch_queue_create("com.omronlib.queue", DISPATCH_QUEUE_CONCURRENT);
                    NSInteger index=1;
                    for (NSArray *a in arrayOfArrays) {
                        NSMutableArray *na = [NSMutableArray array];
                        for (NSDictionary *dic in a) {
                            NSMutableDictionary *nd = [NSMutableDictionary dictionaryWithDictionary:dic];
                            long measureat = (long)[[dic valueForKey:@"measure_at"] longLongValue];
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:measureat];
                            NSDateFormatter *format = [[NSDateFormatter alloc] init];
                            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            [nd setValue:[format stringFromDate:date] forKey:@"measure_at"];
                            [na addObject:nd];
                        }
                        dispatch_group_async(group, queue, ^{
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic setValue:[self getUUID] forKey:@"uuid"];
                            [dic setValue:[LogManager toJasonString:na] forKey:@"data"];
                            [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:[NSString stringWithFormat:@"Local data upload no:%ld",(long)index],[LogManager toJasonString:dic],nil];
                            NSLog(@"%@",dic);
                            [[NetTool shareInstance] post:[NSString stringWithFormat:@"%@%@",BASE_URL,@"v1/Sdk/bp"] params:dic success:^(id  _Nonnull responseObj) {
                                [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:[NSString stringWithFormat:@"Local %ld batch data upload server returns",(long)index],[LogManager toJasonString:responseObj],nil];
                                if([responseObj isKindOfClass:[NSDictionary class]])
                                {
                                    NSInteger code = [[responseObj valueForKey:@"code"] integerValue];
                                    if(code==1)
                                    {
                                        if([((NSDictionary *)responseObj).allKeys containsObject:@"flag"])
                                        {
                                            NSInteger flag = [[responseObj valueForKey:@"flag"] integerValue];
                                            if(flag==1)
                                            {
                                                [self uploadLog:false];
                                            }
                                        }
                                    }
                                    else if([@"-740004" isEqualToString:[NSString stringWithFormat:@"%ld",(long)code]])//厂商密钥已过期
                                    {
                                        isExpire = true;
                                    }
                                }
                                dispatch_semaphore_signal(semaphore);
                            } failture:^(NSError * _Nonnull error,id  _Nonnull responseObj) {
                                [LogManager logErrorInfo:OLOG(@"Upload local blood pressure data") logStr:@"Local data upload error",[LogManager toJasonString:error.userInfo],nil];
                                dispatch_semaphore_signal(semaphore);
                            }];
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        });
                        index++;
                    }
                    dispatch_group_notify(group, queue, ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"Upload successfully deleted local blood pressure data file to start",nil];
                            [fileManager removeItemAtPath:OMRON_BPDATAS_FILE error:nil];
                            [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"Local blood pressure data file was deleted successfully after uploading",nil];
                            complete(isExpire);
                        });
                    });
                }
                else
                {
                    [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"No local blood pressure data exist",nil];
                    complete(isExpire);
                }
            }
            else
            {
                [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"There is no network",nil];
                complete(isExpire);
            }
        }
        else
        {
            [LogManager logInfo:OLOG(@"Upload local blood pressure data") logStr:@"No local blood pressure data exist",nil];
            complete(isExpire);
        }
    } @catch (NSException *exception) {
        [LogManager logErrorInfo:OLOG(@"Upload local blood pressure data") logStr:@"Upload local data exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
    } @finally {
        
    }
}

-(void)uploadLocalBFData:(void(^)(bool))complete
{
    __block BOOL isExpire = false;
    @try {
        [LogManager logInfo:OLOG(@"Upload bodyfat data") logStr:@"To upload",nil];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:OMRON_BFDATAS_FILE];
        if(isExists)
        {
            NSMutableDictionary *localData = [NSMutableDictionary dictionaryWithContentsOfFile:OMRON_BFDATAS_FILE];
            NSMutableArray *result = [localData valueForKey:[self getUUID]];
            if(result==nil)
            {
                result = [NSMutableArray array];
            }
            //判断是否有网络
            if([[NetTool shareInstance] isHasNet])
            {
                //上传成功之后删除本地文件
                if(isExists&&result.count>0)
                {
                    [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:@"Local bodyfat data exist",[LogManager toJasonString:result],nil];
                    NSInteger groupCount = 500;
                    NSInteger totalGroup=result.count/groupCount;
                    if(result.count%groupCount>0)
                    {
                        totalGroup++;
                    }
                    NSMutableArray *arrayOfArrays = [NSMutableArray array];
                    NSUInteger itemsRemaining = result.count;
                    int j = 0;
                    while(itemsRemaining) {
                        NSRange range = NSMakeRange(j, MIN(100, itemsRemaining));
                        NSArray *subLogArr = [result subarrayWithRange:range];
                        [arrayOfArrays addObject:subLogArr];
                        itemsRemaining-=range.length;
                        j+=range.length;
                    }
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_queue_t queue = dispatch_queue_create("com.omronlib.queue", DISPATCH_QUEUE_CONCURRENT);
                    NSInteger index=1;
                    for (NSArray *a in arrayOfArrays) {
                        NSMutableArray *na = [NSMutableArray array];
                        for (NSDictionary *dic in a) {
                            NSMutableDictionary *nd = [NSMutableDictionary dictionaryWithDictionary:dic];
                            long measureat = (long)[[dic valueForKey:@"measure_at"] longLongValue];
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:measureat];
                            NSDateFormatter *format = [[NSDateFormatter alloc] init];
                            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            [nd setValue:[format stringFromDate:date] forKey:@"measure_at"];
                            [na addObject:nd];
                        }
                        dispatch_group_async(group, queue, ^{
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic setValue:[self getUUID] forKey:@"uuid"];
                            [dic setValue:[LogManager toJasonString:na] forKey:@"data"];
                            [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:[NSString stringWithFormat:@"Local data upload no:%ld",(long)index],[LogManager toJasonString:dic],nil];
                            [[NetTool shareInstance] post:[NSString stringWithFormat:@"%@%@",BASE_URL,@"v1/Sdk/fat"] params:dic success:^(id  _Nonnull responseObj) {
                                [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:[NSString stringWithFormat:@"Local %ld bodyfat data upload server returns",(long)index],[LogManager toJasonString:responseObj],nil];
                                if([responseObj isKindOfClass:[NSDictionary class]])
                                {
                                    NSInteger code = [[responseObj valueForKey:@"code"] integerValue];
                                    if(code==1)
                                    {
                                        if([((NSDictionary *)responseObj).allKeys containsObject:@"flag"])
                                        {
                                            NSInteger flag = [[responseObj valueForKey:@"flag"] integerValue];
                                            if(flag==1)
                                            {
                                                [self uploadLog:false];
                                            }
                                        }
                                    }
                                    else if([@"-740004" isEqualToString:[NSString stringWithFormat:@"%ld",(long)code]])//厂商密钥已过期
                                    {
                                        isExpire = true;
                                    }
                                }
                                dispatch_semaphore_signal(semaphore);
                            } failture:^(NSError * _Nonnull error,id  _Nonnull responseObj) {
                                [LogManager logErrorInfo:OLOG(@"Upload local bodyfate data") logStr:@"Local data upload error",[LogManager toJasonString:error.userInfo],nil];
                                dispatch_semaphore_signal(semaphore);
                            }];
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        });
                        index++;
                    }
                    dispatch_group_notify(group, queue, ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:@"Upload successfully deleted local bodyfat data file to start",nil];
                            [fileManager removeItemAtPath:OMRON_BFDATAS_FILE error:nil];
                            [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:@"Local bodyfat data file was deleted successfully after uploading",nil];
                            complete(isExpire);
                        });
                    });
                }
                else
                {
                    [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:@"No local bodyfat data exist",nil];
                    complete(isExpire);
                }
            }
            else
            {
                [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:@"There is no network",nil];
                complete(isExpire);
            }
        }
        else
        {
            [LogManager logInfo:OLOG(@"Upload local bodyfat data") logStr:@"No local bodyfat data exist",nil];
            complete(isExpire);
        }
    } @catch (NSException *exception) {
        [LogManager logErrorInfo:OLOG(@"Upload local bodyfat data") logStr:@"Upload local data exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
    } @finally {
        
    }
}

-(void)uploadLog:(BOOL)isLaunch
{
    @try {
        if([[NetTool shareInstance] isHasNet])
        {
            NSString *base_path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/OLog"];
            NSString *baseerror_path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/OLog/error"];
            NSString *normalLog = [self scanFoolder:base_path];
            NSString *errorLog = [self scanFoolder:baseerror_path];
            if(isLaunch)//启动主动上报错误日志
            {
                if(IsStrEmpty(errorLog))
                {
                    return;
                }
            }
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[self getUUID] forKey:@"uuid"];
            if(!IsStrEmpty(normalLog))
            {
                [dic setValue:normalLog forKey:@"run_content"];
            }
            
            if(!IsStrEmpty(errorLog))
            {
                [dic setValue:errorLog forKey:@"err_content"];
            }
            
            [[NetTool shareInstance] post:[NSString stringWithFormat:@"%@%@",BASE_URL,@"v1/Sdk/log"] params:dic success:^(id  _Nonnull responseObj) {
                [LogManager logInfo:OLOG(@"Upload local log") logStr:[LogManager toJasonString:responseObj],nil];
                [LogManager clearLocalLog];
            } failture:^(NSError * _Nonnull error,id  _Nonnull responseObj) {
                [LogManager logInfo:OLOG(@"Upload local log") logStr:@"Upload local log interface exception",[LogManager toJasonString:error.userInfo],nil];
            }];
        }
    } @catch (NSException *exception) {
        [LogManager logErrorInfo:OLOG(@"Upload local log") logStr:@"Upload local log exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
    } @finally {
        
    }
}

- (NSString *)scanFoolder:(NSString *)targetPath {
    NSString *result= @"";
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *dicEnumerator = [fileManager enumeratorAtPath:targetPath];
        BOOL isDir = NO;
        BOOL isExist = NO;
        NSMutableString *logStr = [NSMutableString string];
        for (NSString *path in dicEnumerator)
        {
            isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", targetPath, path] isDirectory:&isDir];
            if(isExist)
            {
                if(!isDir)
                {
                    if([path containsString:@".log"]||[path containsString:@".crash"])
                    {
                        NSString *temp = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", targetPath, path]  encoding:NSUTF8StringEncoding error:nil];
                        if(temp==nil)
                        {
                            temp = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", targetPath, path]  encoding:NSMacOSRomanStringEncoding error:nil];
                        }
                        if(temp!=nil)
                        {
                            [logStr appendString:temp];
                        }
                    }
                }
            }
        }
        
        result = logStr;
    } @catch (NSException *exception) {
        [LogManager logErrorInfo:OLOG(@"Read local log") logStr:@"Read the local log exception",exception.name,exception.reason,[[exception callStackSymbols] componentsJoinedByString:@"\n"],nil];
    } @finally {
        return result;
    }
}

-(NSString *)getDeviceInfo
{
    //app应用相关信息的获取
    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
    // CFShow(dicInfo);
    NSString *strAppName = [dicInfo objectForKey:@"CFBundleDisplayName"];
    NSString *strAppVersion = [dicInfo objectForKey:@"CFBundleShortVersionString"];
    NSString *strAppBuild = [dicInfo objectForKey:@"CFBundleVersion"];
    //Getting the User’s Language
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *strName = [[UIDevice currentDevice] name];
    NSString *strSysName = [[UIDevice currentDevice] systemName];
    NSString *strSysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *strModel = [[UIDevice currentDevice] model];
    NSString *strLocModel = [[UIDevice currentDevice] localizedModel];
    NSString *phoneModel = [[UIDevice currentDevice] model];
    [dic setValue:strName forKey:@"device_name"];
    [dic setValue:strSysName forKey:@"system_name"];
    [dic setValue:strSysVersion forKey:@"system_version"];
    [dic setValue:strModel forKey:@"system_model"];
    [dic setValue:strLocModel forKey:@"system_localize_model"];
    [dic setValue:strAppName forKey:@"app_name"];
    [dic setValue:strAppVersion forKey:@"app_version"];
    [dic setValue:strAppBuild forKey:@"app_version_build"];
    [dic setValue:language forKey:@"app_language"];
    [dic setValue:country forKey:@"app_country"];
    [dic setValue:phoneModel forKey:@"app_model"];
    return [LogManager toJasonString:dic];
}

-(void)stopConnect:(void(^)(BOOL isCancel))complete{
    [[[OMRONDeviceManager alloc]init]stopConnect:^(BOOL isCancel) {
        if (isCancel) {
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

-(void)setlistening:(BOOL)isListen {
    isListening = isListen;
}

- (BOOL)listening {
    return isListening;
}

- (BOOL)isRegistered {
    return isRegister;
}



@end
