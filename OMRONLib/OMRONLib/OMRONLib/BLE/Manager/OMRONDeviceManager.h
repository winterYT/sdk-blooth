//
//  OMRONDeviceManager.h
//  OMRONLib
//
//  Created by Calvin on 2019/8/29.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMRONLib.h"
NS_ASSUME_NONNULL_BEGIN

@interface OMRONBFAppendUserIndexData : NSObject<OMRONBFAppendUserIndexDelegate>
@property (nonatomic, strong) void(^block)(NSInteger index);
-(void)appendUserIndex:(NSInteger)index;
@end

@interface OMRONDeviceManager : NSObject

//体脂计不可选使用者绑定
- (void)bindBFDevice:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete;
//血压计绑定
- (void)bingBPDevice:(OMRONDeviceType)deviceType complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete;

//体脂计可选使用者绑定
- (void)bindBFDevice:(OMRONDeviceType)deviceType status:(void(^)(OMRONBLESStaus statue))status userIndexBlock:(void(^)(NSString *deviceId,id<OMRONBFAppendUserIndexDelegate> indexData))userIndexBlock birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete;
//获取血压计数据
- (void)getBpDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSArray<NSDictionary *> *measurementRecords))complete;

//获取体脂计数据
-(void)getBFDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSArray<NSDictionary *> *measurementRecords,NSDictionary *userInfo))complete;
//停止绑定
-(void)stopConnect:(void(^)(BOOL isCancel))complete;

//扫描周围设备
- (void)scanAllBPDevicesComplete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete;

//血压根据deviceSerialNum绑定
- (void)bingBPDevice:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete;

@end

NS_ASSUME_NONNULL_END
