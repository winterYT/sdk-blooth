//
//  BSODefines.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import <UIKit/UIKit.h>

BSOAppConfigKey const BSOAppConfigCurrentUserNameKey = @"currentUserName";

NSString * const BSOGuestUserName = @"Guest";

BSONotificationName const BSOBeaconSignalDiscoveryNotification = @"BeaconSignalDiscoveryNotification";

NSString * BSOProtocolDescription(BSOProtocol value) {
    NSString *ret = nil;
    switch (value) {
        case BSOProtocolNone: ret = @"None"; break;
        case BSOProtocolBluetoothStandard: ret = @"Bluetooth Standard"; break;
        case BSOProtocolOmronExtension: ret = @"Omron Extension"; break;
        default: break;
    }
    return ret;
}

NSString * BSOOperationDescription(BSOOperation value) {
    NSString *ret = nil;
    switch (value) {
        case BSOOperationNone: ret = @"None"; break;
        case BSOOperationRegister: ret = @"Register"; break;
        case BSOOperationTransfer: ret = @"Transfer"; break;
        case BSOOperationDelete: ret = @"Delete"; break;
        default: break;
    }
    return ret;
}
