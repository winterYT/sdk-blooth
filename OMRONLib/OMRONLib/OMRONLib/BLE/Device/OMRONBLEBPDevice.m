//
//  OMRONBLEBPDevice.m
//  OMRONBLELib
//
//  Created by Calvin on 14/11/2016.
//  Copyright © 2016 Calvin. All rights reserved.
//

#import "OMRONBLEBPDevice.h"
#import "OMRONBLECallbackBase.h"
#import "OMRONLib.h"
@interface OMRONBLEBPDevice()
@property (nonatomic, strong) NSMutableDictionary* measureData;
@end

@implementation OMRONBLEBPDevice
+(id)shareInstance
{
    static id shareInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

-(instancetype)init
{
    if (self=[super init]) {
        self.measureData= [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(NSString *)getAdvertisingName:(OMRONDeviceType)deviceType
{
    if (deviceType==OMRON_BLOOD_9200T) {
        return @"BLEsmart_00000116";
    }
    else if(deviceType==OMRON_BLOOD_U32J)
    {
        return @"BLEsmart_0000033A";
    }
    else if(deviceType==OMRON_BLOOD_J750)
    {
        return @"BLEsmart_00000328";
    }
    else if(deviceType==OMRON_BLOOD_J730)
    {
        return @"BLEsmart_0000033C";
    }
    else if(deviceType==OMRON_BLOOD_J761)
    {
        return @"BLEsmart_00000340";
    }
    else if(deviceType==OMRON_BLOOD_9200L)
   {
       return @"BLEsmart_00000325";
   }else if(deviceType==OMRON_BLOOD_U32K)
   {
       return @"BLEsmart_0000033B";
   }else if(deviceType==OMRON_BLOOD_J750L)
   {
       return @"BLEsmart_00000332";
   }else if(deviceType==OMRON_BLOOD_U18)
   {
       return @"BLEsmart_00000357";
   }else if(deviceType==OMRON_BLOOD_J760)
   {
       return @"BLEsmart_00000341";
   }else if(deviceType==OMRON_BLOOD_T50)
   {
       return @"BLEsmart_0000034E";
   }else if(deviceType==OMRON_BLOOD_U32)
   {
       return @"BLEsmart_00000339";
   }else if(deviceType==OMRON_BLOOD_J732)
   {
       return @"BLEsmart_00000336";
   }else if(deviceType==OMRON_BLOOD_J751)
   {
       return @"BLEsmart_00000335";
   }else if(deviceType==OMRON_BLOOD_U36J)
   {
       return @"BLEsmart_00000377";
   }else if(deviceType==OMRON_BLOOD_U36T)
   {
       return @"BLEsmart_00000376";
   }else if(deviceType==OMRON_HEM_6231T)
   {
       return @"BLEsmart_0000034B";
   }
    
    
    return @"";
}

+(NSString *)getDeviceTypeName:(OMRONDeviceType)deviceType
{
    if (deviceType==OMRON_BLOOD_9200T) {
        return @"BLOOD_9200T";
    }
    else if (deviceType==OMRON_BLOOD_U32J) {
        return @"BLOOD_U32J";
    }
    else if (deviceType==OMRON_BLOOD_J750) {
        return @"BLOOD_J750";
    }
    else if(deviceType==OMRON_BLOOD_J730)
    {
        return @"BLOOD_J730";
    }
    else if(deviceType==OMRON_BLOOD_J761)
    {
       return @"BLOOD_J761";
    }
    else if(deviceType==OMRON_BLOOD_9200L)
    {
       return @"BLOOD_9200L";
    }else if(deviceType==OMRON_BLOOD_U32K)
    {
       return @"BLOOD_U32K";
    }else if(deviceType==OMRON_BLOOD_J750L)
    {
       return @"BLOOD_J750L";
    }else if(deviceType==OMRON_BLOOD_U18)
    {
       return @"BLOOD_U18";
    }else if(deviceType==OMRON_BLOOD_J760)
    {
       return @"BLOOD_J760";
    }else if(deviceType==OMRON_BLOOD_T50)
    {
       return @"BLOOD_T50";
    }else if(deviceType==OMRON_BLOOD_U32)
    {
       return @"BLOOD_U32";
    }else if(deviceType==OMRON_BLOOD_J732)
    {
       return @"BLOOD_J732";
    }else if(deviceType==OMRON_BLOOD_J751)
    {
       return @"BLOOD_J751";
    }else if(deviceType==OMRON_BLOOD_U36J)
    {
       return @"BLOOD_U36J";
    }else if(deviceType==OMRON_BLOOD_U36T)
    {
       return @"BLOOD_U36T";
    }else if(deviceType==OMRON_HEM_6231T)
    {
       return @"BLOOD_HEM_6231T";
    }
    
    
    return @"";
}

-(void)readData:(void(^)(NSArray *bpDatas))success failture:(void(^)(OMRONBLEErrMsg *errorMsg))failture
{
    __weak typeof(self) weakDevice = self;
    [weakDevice setBlockOnDiscoverPressureService:^(OMRONBLEDevice *device, CBService *service) {
        [weakDevice.basebleDevice discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:Pressure_Measure_Characteristic]] forService:service];
        [weakDevice setBlockOnDiscoverMesaureCharcteristics:^(CBCharacteristic *measureCharacteristic) {
            const uint8_t bytes[] = {0x0002};
            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            [weakDevice.basebleDevice writeValue:data forCharacteristic:measureCharacteristic type:CBCharacteristicWriteWithoutResponse];
            [weakDevice setBlockOnMesaureCharcteristicsResponse:^(NSMutableArray *resultCharacteristics) {
                NSMutableArray *result = [[NSMutableArray alloc] init];
                for (NSData *d in resultCharacteristics) {
                    OMRONBPObject *bpData =[weakDevice analyseMeasureData:d];
                    if (bpData.measure_at>0) {
                        [result addObject:bpData];
                    }
                }
                success(result);
            }];
        }];
    }];
    [weakDevice.baseCallBack setBlockFailture:failture];
    if(weakDevice.basebleDevice.state==CBPeripheralStateConnected)
    {
        [weakDevice.basebleDevice discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:Pressure_Service]]];
    }
    else
    {
        if(weakDevice.baseCallBack.blockFailture)
        {
            [self.baseCallBack blockFailture]([OMRONBLEErrMsg errorWithMsdAndId:10003 msg:@"连接断开"]);
        }
    }
}

-(void)readDeviceSerialNumber:(OMRONDeviceType)deviceType success:(void(^)(NSString *serialNum,NSString *macAddress,NSString *deviceName,NSString *advertisingName))success failture:(void(^)(OMRONBLEErrMsg *errorMsg))failture
{
    __weak typeof(self) weakDevice = self;
    [weakDevice setBlockOnDiscoverDeviceInfoService:^(OMRONBLEDevice *device, CBService *service) {
        [weakDevice.basebleDevice discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:SerialNumber]] forService:service];
        [weakDevice setBlockOnDiscoverDeviceInfoCharcteristics:^(CBCharacteristic *deviceInfocharacteristic) {
            NSString *result;
            if(deviceType==OMRON_BLOOD_9200T)
            {
                result= [NSString stringWithFormat:@"HEM-9200T%s",(Byte *)[deviceInfocharacteristic.value bytes]];
                success(result,weakDevice.macAddress,@"HEM-9200T",weakDevice.advertisingName);
            }
            else if(deviceType==OMRON_BLOOD_U32J)
            {
                result= [NSString stringWithFormat:@"U32J%s",(Byte *)[deviceInfocharacteristic.value bytes]];
                success(result,weakDevice.macAddress,@"U32J",weakDevice.advertisingName);
            }
            else if(deviceType==OMRON_BLOOD_J750)
            {
                result= [NSString stringWithFormat:@"J750%s",(Byte *)[deviceInfocharacteristic.value bytes]];
                success(result,weakDevice.macAddress,@"J750",weakDevice.advertisingName);
            }
            else if(deviceType==OMRON_BLOOD_J730)
            {
                result= [NSString stringWithFormat:@"J730%s",(Byte *)[deviceInfocharacteristic.value bytes]];
                success(result,weakDevice.macAddress,@"J730",weakDevice.advertisingName);
            }
            else if(deviceType==OMRON_BLOOD_J761)
           {
               result= [NSString stringWithFormat:@"J761%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"J761",weakDevice.advertisingName);
           }
            else if(deviceType==OMRON_BLOOD_9200L)
          {
              result= [NSString stringWithFormat:@"HEM-9200L%s",(Byte *)[deviceInfocharacteristic.value bytes]];
              success(result,weakDevice.macAddress,@"HEM-9200L",weakDevice.advertisingName);
          }
            else if(deviceType==OMRON_BLOOD_U18)
            {
                result= [NSString stringWithFormat:@"U18%s",(Byte *)[deviceInfocharacteristic.value bytes]];
                success(result,weakDevice.macAddress,@"U18",weakDevice.advertisingName);
            }
            else if(deviceType==OMRON_BLOOD_J760)
           {
               result= [NSString stringWithFormat:@"J760%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"J760",weakDevice.advertisingName);
           }else if(deviceType==OMRON_BLOOD_T50)
           {
               result= [NSString stringWithFormat:@"T50%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"T50",weakDevice.advertisingName);
           }else if(deviceType==OMRON_BLOOD_U32)
           {
               result= [NSString stringWithFormat:@"U32%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"U32",weakDevice.advertisingName);
           }else if(deviceType==OMRON_BLOOD_J732)
           {
               result= [NSString stringWithFormat:@"J732%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"J732",weakDevice.advertisingName);
           }else if(deviceType==OMRON_BLOOD_J751)
           {
               result= [NSString stringWithFormat:@"J751%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"J751",weakDevice.advertisingName);
           }else if(deviceType==OMRON_BLOOD_U36J)
           {
               result= [NSString stringWithFormat:@"U36J%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"U36J",weakDevice.advertisingName);
           }else if(deviceType==OMRON_BLOOD_U36T)
           {
               result= [NSString stringWithFormat:@"U36T%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"U36T",weakDevice.advertisingName);
           }else if(deviceType==OMRON_HEM_6231T)
           {
               result= [NSString stringWithFormat:@"HEM_6231T%s",(Byte *)[deviceInfocharacteristic.value bytes]];
               success(result,weakDevice.macAddress,@"HEM_6231T",weakDevice.advertisingName);
           }
            
        }];
    }];
    [weakDevice.baseCallBack setBlockFailture:failture];
    [weakDevice.basebleDevice discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:Pressure_Device_Info]]];
}

-(void)readBatteryLevel:(void(^)(int battery))success failture:(void(^)(OMRONBLEErrMsg *errorMsg))failture
{
    __weak typeof(self) weakDevice = self;
    [weakDevice setBlockOnDiscoverPressureBatteryService:^(OMRONBLEDevice *device, CBService *service) {
        [weakDevice.basebleDevice discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:Battery_UUID]] forService:service];
        [weakDevice setBlockOnDiscoverGluCoseBatteryCharacteristics:^(CBCharacteristic *characteristic) {
            if (characteristic.value!=nil) {
                success([weakDevice analyzeBattrtyCharacteristic:characteristic]);
            }
        }];
    }];
    [weakDevice.baseCallBack setBlockFailture:failture];
    [weakDevice disCoverService:[NSArray arrayWithObject:[CBUUID UUIDWithString:Battery_Service]]];
}

#pragma mark private method
-(int)analyzeBattrtyCharacteristic:(CBCharacteristic *)batteryCharacteristic
{
    NSData *data = [batteryCharacteristic.value subdataWithRange:NSMakeRange(0, 1)];
    int value =*(UInt8*)([data bytes]);
    return value;
}

#pragma mark private method
-(int) ToInt:(Byte) value
{
    return value & 0xFF;
}

-(int) bytesToInt:(Byte*) src  len:(int)len
{
    int value=0;
    for(int i= 0;i<len;i++)
    {
        value |= ((src[i] & 0xFF)<<8*i);
    }
    return value;
}

-(OMRONBPObject *)analyseMeasureData:(NSData*)data
{
    //    NSLog(@"Data is %@",data);
    //167b0058 006300e0 070b0f0f 34245000 0000
    OMRONBPObject *bpData = [[OMRONBPObject alloc] init];
    NSInteger offset = 0;
    Byte flag[1]  ;
    [data getBytes:flag range:NSMakeRange(offset,1)];
    offset+=1;
//    BOOL bloodPressureUnitsFlag = (flag[0] & 0x01)==0?FALSE:TRUE;
    BOOL timeStampFlag = (flag[0] & 0x02)==0?FALSE:TRUE;
    BOOL pulseRateFlag = (flag[0] & 0x04)==0?FALSE:TRUE;
    BOOL userIdFlag = (flag[0] & 0x08)==0?FALSE:TRUE;
    BOOL measurementStatusFlag = (flag[0] & 0x10)==0?FALSE:TRUE;
//    NSInteger systolic;
//    NSInteger diastolic;
//    NSInteger meanArterialPressure;
    Byte systolicNumber[2];
    [data getBytes:systolicNumber range:NSMakeRange(offset, sizeof(systolicNumber))];
    offset+=sizeof(systolicNumber);
    NSInteger systolicNumberValue = [self bytesToInt:systolicNumber len:sizeof(systolicNumber)];
    bpData.sbp=systolicNumberValue;
    Byte diastolicNumber[2];
    [data getBytes:diastolicNumber range:NSMakeRange(offset, sizeof(diastolicNumber))];
    offset+=sizeof(diastolicNumber);
    NSInteger diastolicNumberValue = [self bytesToInt:diastolicNumber len:sizeof(diastolicNumber)];
    bpData.dbp=diastolicNumberValue;
    Byte meanArterialPressureNumber[2];
    [data getBytes:meanArterialPressureNumber range:NSMakeRange(offset, sizeof(meanArterialPressureNumber))];
    offset+=sizeof(meanArterialPressureNumber);
//    NSInteger meanArterialPressureNumberValue = [self bytesToInt:meanArterialPressureNumber len:sizeof(meanArterialPressureNumber)];
    //    NSLog(@"systolic: %ld, diastolic: %ld, meanArterialPressure: %ld",systolicNumberValue,diastolicNumberValue,meanArterialPressureNumberValue);
    if (timeStampFlag) {
        Byte year[2];
        [data getBytes:year range:NSMakeRange(offset,sizeof(year))];
        offset+=sizeof(year);
        NSInteger yearValue = [self bytesToInt:year len:2];
        Byte month[1];
        [data getBytes:month range:NSMakeRange(offset,sizeof(month))];
        offset+=sizeof(month);
        NSInteger monthValue = [self bytesToInt:month len:1];
        Byte day[1];
        [data getBytes:day range:NSMakeRange(offset,sizeof(day))];
        NSInteger dayValue = [self bytesToInt:day len:1];
        offset+=sizeof(day);
        Byte houre[1];
        [data getBytes:houre range:NSMakeRange(offset,sizeof(houre))];
        NSInteger houreValue = [self bytesToInt:houre len:1];
        offset+=sizeof(houre);
        Byte minute[1];
        [data getBytes:minute range:NSMakeRange(offset,sizeof(minute))];
        NSInteger minuteValue = [self bytesToInt:minute len:1];
        offset+=sizeof(minute);
        Byte second[1];
        [data getBytes:second range:NSMakeRange(offset,sizeof(second))];
        NSInteger secondValue = [self bytesToInt:second len:1];
        offset+=sizeof(second);
        NSDate* date;
        //修改当前时间区
        //    NSTimeZone* localzone = [NSTimeZone localTimeZone];
        //    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //    [formatter setTimeZone:GTMzone];
        NSString* time = [NSString stringWithFormat:@"%4d-%2d-%2d %2d:%2d:%2d",(int)yearValue,(int)monthValue,(int)dayValue,(int)houreValue,(int)minuteValue,(int)secondValue];
        date = [formatter dateFromString:time];
        //        NSLog(@"Measure Time %@",date);
        bpData.measure_at=[date timeIntervalSince1970];;
        if (yearValue==0) {
            bpData.measure_at=0;
        }
        //    [formatter setTimeZone:localzone];
    }
    
    if (pulseRateFlag) {
        Byte pulseRateFlagNumber[1];
        [data getBytes:pulseRateFlagNumber range:NSMakeRange(offset,sizeof(pulseRateFlagNumber))];
        offset+=2;
        NSInteger pulseRateFlagNumberValue = [self bytesToInt:pulseRateFlagNumber len:sizeof(pulseRateFlagNumber)];
        //        NSLog(@"pulseRateFlag:%ld",pulseRateFlagNumberValue);
        bpData.pulse=pulseRateFlagNumberValue;
    }
    if (userIdFlag) {
        Byte userIdFlagNumber[1];
        [data getBytes:userIdFlagNumber range:NSMakeRange(offset,sizeof(userIdFlagNumber))];
        offset+=sizeof(userIdFlagNumber);
//        NSInteger userIdFlagNumberValue = [self bytesToInt:userIdFlagNumber len:sizeof(userIdFlagNumberValue)];
        //        NSLog(@"userIdFlag:%ld",userIdFlagNumberValue);
    }
    if (measurementStatusFlag) {
        Byte measurementStatusFlagNumber[1];
        [data getBytes:measurementStatusFlagNumber range:NSMakeRange(offset,sizeof(measurementStatusFlagNumber))];
//        offset+=sizeof(measurementStatusFlagNumber);
        NSInteger measurementStatusFlagNumberValue = [self bytesToInt:measurementStatusFlagNumber len:sizeof(measurementStatusFlagNumber)];
        NSInteger bodyMovementFlag = (measurementStatusFlagNumberValue & 0x01)>0?1:0;
        int cuffFitFlag = (measurementStatusFlagNumberValue & 0x02)>0?1:0;
        int irregularPulseFlag = (measurementStatusFlagNumberValue & 0x04)>0?1:0;
        bpData.bm_flg=bodyMovementFlag;
        bpData.cws_flg=cuffFitFlag;
        bpData.ihb_flg=irregularPulseFlag;
        //        NSLog(@"measurementStatusFlag:%ld",measurementStatusFlagNumberValue);
    }
    return bpData;
}
@end
