//
//  OMRONLib.h
//  OMRONLib
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/**
 *  血压设备
 */
typedef NS_ENUM(NSInteger, OMRONDeviceType){
    /*
     BLEsmart_00000116
     */
    OMRON_BLOOD_9200T=0,
    OMRON_BLOOD_U32J,
    OMRON_BLOOD_J750,
    OMRON_BLOOD_J730,
    OMRON_BLOOD_J761,
    OMRON_BLOOD_9200L,
    OMRON_BLOOD_U32K,
    OMRON_BLOOD_J750L,
    OMRON_HBF_219T,
    OMRON_BLOOD_U18,
    OMRON_BLOOD_J760,//&&新增设备
    OMRON_BLOOD_T50,//&&新增设备
    OMRON_BLOOD_U32,//&&新增设备
    OMRON_BLOOD_J732,//&&新增设备
    OMRON_BLOOD_J751,//&&新增设备
    OMRON_BLOOD_U36J,//&&新增设备
    OMRON_BLOOD_U36T,//&&新增设备
    OMRON_HEM_6231T,//&&新增设备
    OMRON_HBF_229T,//新增体脂仪
};

/*
 * SDK 状态
 */
typedef NS_ENUM(NSInteger, OMRONSDKStatus){
    /*
     BLEsmart_00000116
     */
    OMRON_SDK_UnRegister,
    OMRON_SDK_InValidKey,
    OMRON_SDK_UnOpenBlueTooth,
    OMRON_SDK_Success,
    OMRON_SDK_UnBind,
    OMRON_SDK_BindFail,
    OMRON_SDK_NoDevice,
    OMRON_SDK_ConnectFail,
    OMRON_SDK_NoNet,
    OMRON_SDK_UnSupportDevice,
    OMRON_SDK_ScanTimeOut,
    OMRON_SDK_ScanCancel
};

typedef NS_ENUM(NSInteger, OMRONBLESStaus)
{
    OMRON_BLE_SCANING,//扫描中
    OMRON_BLE_SCANED,//扫描到设备
    OMRON_BLE_CONNECTING,//链接中
    OMRON_BLE_CONNECTED,//连接上设备
    OMRON_BLE_DISCONNECTING,//正在断开连接
    OMRON_BLE_DISCONNECTED,//断开连接
};

/*
 * 返回对象
 */
@interface OMRONBPObject : NSObject
@property (nonatomic, assign) NSInteger   sbp;
@property (nonatomic, assign) NSInteger   dbp;
@property (nonatomic, assign) NSInteger   pulse;
@property (nonatomic, assign) NSInteger   ihb_flg;// 0: normal; 1 abnormal
@property (nonatomic, assign) NSInteger   bm_flg;// 0:not move; 1 move
@property (nonatomic, assign) NSInteger   cws_flg;// 0: normal; 1 abnormal
@property (nonatomic, assign) NSInteger   measureUser;// 0:unset; 1:userA; 2:userB
@property (nonatomic, assign) long        measure_at;
@property (nonatomic, copy) NSString *device_type;
@end

@interface OMRONBFObject: NSObject
@property (nonatomic, copy) NSString *bmi;//bmi
@property (nonatomic, assign) NSInteger basal_metabolism;//基础代谢
@property (nonatomic, assign) NSInteger body_age;//体年龄
@property (nonatomic, assign) CGFloat fat_rate;//体脂率
@property (nonatomic, assign) CGFloat weight;//体重
@property (nonatomic, assign) NSInteger userIndex;
@property (nonatomic, assign) NSInteger visceral_fat;//内脏脂肪水平
@property (nonatomic, assign) CGFloat skeletal_muscles_rate;//骨骼肌率
@property (nonatomic, assign) long measure_at;//测量时间
@property (nonatomic, copy) NSString *device_type;//设备类型
@property (nonatomic, assign) CGFloat height;//身高
@property (nonatomic, copy) NSString *birthday;//生日
@property (nonatomic, copy) NSString *gender;//0.男, 1.女
@end
@protocol OMRONBFAppendUserIndexDelegate
-(void)appendUserIndex:(NSInteger)index;
@end
@interface OMRONLib : NSObject<NSCoding>
/*
 *  获取OMRONLib 对象
 *  @return  返回OBROMLib 对象
 */
+ (instancetype)shareInstance;

/*
 *  @appid OMRON 开发者Id
 */
- (BOOL)registerApp:(NSString *)appid;

/*
 *  取消注册
 */
-(void)unRegister;

/*
 *  获取设备列表(可使用的设备列表)
 */
- (NSArray<NSString *> *)getOMRONDeviceList;

/*
*  血压设备绑定
*/
- (void)bindDevice:(OMRONDeviceType)deviceType complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete;


/*
*  体脂设备绑定
*/
- (void)bindBFDevice:(OMRONDeviceType)deviceType status:(void(^)(OMRONBLESStaus statue))status userIndexBlock:(void(^)(NSString *deviceId,id<OMRONBFAppendUserIndexDelegate> indexData))userIndexBlock birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSInteger userIndex,NSString *advertisingName,NSDictionary *userInfo))complete;


/*
 *  获取血压设备数据
 */
- (void)getDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSArray<OMRONBPObject *> *datas))complete;


/*
 *  获取体脂设备数据
 */
-(void)getBFDeviceData:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum userIndex:(NSInteger)userIndex birthday:(NSDate *)birthday height:(CGFloat)height isMale:(BOOL)isMale complete:(void(^)(OMRONSDKStatus status,NSArray<OMRONBFObject *> *datas, NSDictionary *userInfo))complete;

/*
*  停止绑定设备
*/
-(void)stopConnect:(void(^)(BOOL isCancel))complete;

//设置是否监听
- (void)setlistening:(BOOL)isListen;
//获取监听
- (BOOL)listening;

//app是否注册
- (BOOL)isRegistered;

//扫描周围设备
- (void)scanAllDevicescomplete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete;

//根据deviceSerialNum绑定设备
- (void)bindBPDevice:(OMRONDeviceType)deviceType deviceSerialNum:(NSString *)deviceSerialNum complete:(void(^)(OMRONSDKStatus status,NSString *deviceName,NSString *deviceId,NSString *advertisingName))complete;

@end

NS_ASSUME_NONNULL_END
