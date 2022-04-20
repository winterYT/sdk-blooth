//
//  LocalStore.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/17.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface LocalStore : NSObject
+(BOOL)store:(NSString *)num name:(NSString *)name userIndex:(NSString *)userIndex userInfo:(NSDictionary *)userInfo;
+(void)storeUserInfo:(NSDictionary *)userInfo;
+(NSDictionary *)getUserInfo;
+(NSArray *)getDeviceStore;
+(BOOL)delTargetDevice:(NSString *)num;
@end

NS_ASSUME_NONNULL_END
