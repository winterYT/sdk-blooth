//
//  LogManager.h
//  OMRONLib
//
//  Created by Calvin on 2019/5/31.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogManager : NSObject
+ (NSString *)curTime;
+ (void)logInfo:(NSString*)module logStr:(NSString*)logStr, ...;
+ (void)logErrorInfo:(NSString*)module logStr:(NSString*)logStr, ...;
+ (void)clearExpiredLog;
+ (void)clearLocalLog;
+(NSString *)toJasonString:(id)obj;
@end

NS_ASSUME_NONNULL_END
