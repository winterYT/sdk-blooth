//
//  LogManager.m
//  OMRONLib
//
//  Created by Calvin on 2019/5/31.
//  Copyright © 2019 Calvin. All rights reserved.
//
//https://www.cnblogs.com/xgao/p/6553334.html
#import "LogManager.h"
// 日志保留最大天数
static const int LogMaxSaveDay = 7;
// 日志文件保存目录
static NSString* LogFilePath = @"/Documents/OLog/";
static NSString* LogErrorFilePath = @"/Documents/OLog/error/";
@interface LogManager()
// 日期格式化
@property (nonatomic,retain) NSDateFormatter* dateFormatter;
// 时间格式化
@property (nonatomic,retain) NSDateFormatter* timeFormatter;

// 日志的目录路径
@property (nonatomic,copy) NSString* basePath;
@end
@implementation LogManager
+ (NSString *)curTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss sss"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    return timeString;
}
+ (NSString *)curDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    return timeString;
}
+ (void)logInfo:(NSString*)module logStr:(NSString*)logStr, ...
{
    NSMutableString* parmaStr = [NSMutableString string];
    @try {
        if (logStr) {
            [parmaStr appendString:logStr];
            // 定义一个指向个数可变的参数列表指针；
            va_list args;
            // 用于存放取出的参数
            NSString *arg;
            // 初始化上面定义的va_list变量，这个宏的第二个参数是第一个可变参数的前一个参数，是一个固定的参数
            va_start(args, logStr);
            // 遍历全部参数 va_arg返回可变的参数(a_arg的第二个参数是你要返回的参数的类型)
            while ((arg = va_arg(args, NSString *))) {
                [parmaStr appendString:[NSString stringWithFormat:@" - %@",arg]];
            }
            // 清空参数列表，并置参数指针args无效
            va_end(args);
        }
    } @catch (NSException *exception) {
        [parmaStr appendString:@"【记录日志异常】"];
    }
//    NSLog(@"%@", parmaStr);
    // 异步执行
    dispatch_async(dispatch_queue_create("writeLog", nil), ^{
        // 获取当前日期做为文件名
        NSString* fileName = [NSString stringWithFormat:@"%@.log",[LogManager curDate]];
        NSString* filePath = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogFilePath],fileName];
        // [时间]-[模块]-日志内容
        NSString* timeStr = [LogManager curTime];
        NSString* writeStr = [NSString stringWithFormat:@"[%@] [%@] %@\n",timeStr,module,parmaStr];
        // 写入数据
//        NSLog(@"%@", writeStr);
        [LogManager writeFile:filePath stringData:writeStr];
    });
}

+ (void)logErrorInfo:(NSString*)module logStr:(NSString*)logStr, ...
{
    @try {
        NSMutableString* parmaStr = [NSMutableString string];
        @try {
            if (logStr) {
                [parmaStr appendString:logStr];
                // 定义一个指向个数可变的参数列表指针；
                va_list args;
                // 用于存放取出的参数
                NSString *arg;
                // 初始化上面定义的va_list变量，这个宏的第二个参数是第一个可变参数的前一个参数，是一个固定的参数
                va_start(args, logStr);
                // 遍历全部参数 va_arg返回可变的参数(a_arg的第二个参数是你要返回的参数的类型)
                while ((arg = va_arg(args, NSString *))) {
                    [parmaStr appendString:[NSString stringWithFormat:@" - %@",arg]];
                }
                // 清空参数列表，并置参数指针args无效
                va_end(args);
            }
        } @catch (NSException *exception) {
            [parmaStr appendString:@"【记录日志异常】"];
        }
//        NSLog(@"%@", parmaStr);
        // 异步执行
        dispatch_async(dispatch_queue_create("writeLog", nil), ^{
            // 获取当前日期做为文件名
            NSString* fileName = [NSString stringWithFormat:@"%@.crash",[LogManager curDate]];
            NSString* filePath = [NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogErrorFilePath],fileName];
            // [时间]-[模块]-日志内容
            NSString* timeStr = [LogManager curTime];
            NSString* writeStr = [NSString stringWithFormat:@"[%@] [%@] %@\n",timeStr,module,parmaStr];
            // 写入数据
//            NSLog(@"%@", writeStr);
//            NSLog(@"filepath: %@", filePath);
            [LogManager writeFile:filePath stringData:writeStr];
        });
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

+ (void)writeFile:(NSString*)filePath stringData:(NSString*)stringData{
    @try {
        // 待写入的数据
        if(stringData==nil||stringData.length==0)
        {
            return;
        }
        if([stringData canBeConvertedToEncoding:NSUTF8StringEncoding])
        {
            NSString *tempStr = [[NSString alloc] initWithCString:[stringData UTF8String] encoding:NSUTF8StringEncoding];
            NSData* writeData = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
            // NSFileManager 用于处理文件
            BOOL createPathOk = YES;
            if (![[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByDeletingLastPathComponent] isDirectory:&createPathOk]) {
                // 目录不存先创建
                [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                // 文件不存在，直接创建文件并写入
                [writeData writeToFile:filePath atomically:YES];
            }else{
                // NSFileHandle 用于处理文件内容
                // 读取文件到上下文，并且是更新模式
                NSFileHandle* fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
                // 跳到文件末尾
                [fileHandler seekToEndOfFile];
                // 追加数据
                [fileHandler writeData:writeData];
                // 关闭文件
                [fileHandler closeFile];
            }
        }
    } @catch (NSException *exception) {
       
    } @finally {
        
    }
}

+ (void)clearExpiredLog
{
    @try {
        // 获取日志目录下的所有文件
        NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogFilePath] error:nil];
        [LogManager clearLog:files isAll:false logPath:LogFilePath];
        
        NSArray *fileErrors = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogErrorFilePath] error:nil];
        [LogManager clearLog:fileErrors isAll:false logPath:LogErrorFilePath];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

+ (void)clearLocalLog
{
    @try {
        // 获取日志目录下的所有文件
        NSArray *fileErrors = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogErrorFilePath] error:nil];
        NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),LogFilePath] error:nil];
        [LogManager clearLog:files isAll:true logPath:LogFilePath];
        [LogManager clearLog:fileErrors isAll:true logPath:LogErrorFilePath];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

+(void)clearLog:(NSArray *)files isAll:(BOOL)isAll logPath:(NSString *)logPath
{
    for (NSString* file in files) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *tempFile = @"";
        if([file containsString:@".log"])
        {
            tempFile  = [file stringByReplacingOccurrencesOfString:@".log" withString:@""];
        }
        else if([file containsString:@".crash"])
        {
            tempFile  = [file stringByReplacingOccurrencesOfString:@".crash" withString:@""];
        }
        NSDate* date = [dateFormatter dateFromString:tempFile];
        if (date) {
            NSTimeInterval oldTime = [date timeIntervalSince1970];
            NSTimeInterval currTime = [[LogManager getCurrDate] timeIntervalSince1970];
            
            NSTimeInterval second = currTime - oldTime;
            int day = (int)second / (24 * 3600);
            if(isAll)
            {
                // 删除该文件
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),logPath],file] error:nil];
            }
            else
            {
                if (day >= LogMaxSaveDay) {
                    // 删除该文件
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),logPath],file] error:nil];
                }
            }
            
        }
    }
}

+ (NSDate*)getCurrDate{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    return localeDate;
}

+(NSString *)toJasonString:(id)obj
{
    NSString *result = @"";
    @try {
        if(obj==nil)
        {
            return @"";
        }
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsonTemp = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        //    NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        result = jsonTemp;
    } @catch (NSException *exception) {
        
    } @finally {
        return result;
    }
    
}
@end
