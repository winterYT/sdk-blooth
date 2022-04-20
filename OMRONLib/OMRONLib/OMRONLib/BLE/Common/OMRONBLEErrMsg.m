//
//  OMRONBLEErrMsg.m
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import "OMRONBLEErrMsg.h"

@implementation OMRONBLEErrMsg
+(OMRONBLEErrMsg *)errorWithMsg:(NSString *)msg
{
    OMRONBLEErrMsg *error = [[OMRONBLEErrMsg alloc] initWithMsg:msg];
    return error;
}

+(OMRONBLEErrMsg *)errorWithMsdAndId:(NSInteger)errorId msg:(NSString *)msg
{
    OMRONBLEErrMsg *error = [[OMRONBLEErrMsg alloc] initWithMsgAndId:errorId msg:msg];
    return error;
}

-(OMRONBLEErrMsg *)initWithMsgAndId:(NSInteger)errorId msg:(NSString *)msg
{
    if (self=[super init]) {
        self.errorId = errorId;
        self.errorMsg = msg;
        if (msg !=nil && ![msg isEqualToString:@""]) {
            self.isExistError = YES;
        }
    }
    return self;
}

-(OMRONBLEErrMsg *)initWithMsg:(NSString *)msg
{
    if (self=[super init]) {
        self.errorMsg = msg;
        if (msg !=nil && ![msg isEqualToString:@""]) {
            self.isExistError = YES;
        }
    }
    return self;
}
@end
