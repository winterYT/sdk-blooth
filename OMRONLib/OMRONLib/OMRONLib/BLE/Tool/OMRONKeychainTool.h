//
//  OMRONKeychainTool.h
//  OMRONLib
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

@interface OMRONKeychainTool : NSObject
/**
 本方法是得到 UUID 后存入系统中的 keychain 的方法
 不用添加 plist 文件
 程序删除后重装,仍可以得到相同的唯一标示
 但是当系统升级或者刷机后,系统中的钥匙串会被清空,此时本方法失效
 */
+(NSString *)getDeviceIDInKeychain;

+(void)saveDeviceUUID:(NSString *)uuid;
+(void)deleteDeviceUUID;
@end

NS_ASSUME_NONNULL_END
