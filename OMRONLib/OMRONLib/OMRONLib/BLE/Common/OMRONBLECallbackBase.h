//
//  OMRONBLECallbackBase.h
//  OMRONBLELib
//
//  Created by Calvin on 9/16/15.
//  Copyright (c) 2015 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMRONBLEErrMsg.h"
typedef void(^failture)(OMRONBLEErrMsg *error);

@interface OMRONBLECallbackBase : NSObject
@property (nonatomic, strong) failture blockFailture;
@end
