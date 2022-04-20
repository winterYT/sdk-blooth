//
//  main.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        } @catch (NSException *exception) {
            NSString * message = [NSString stringWithFormat:@"Uncaught exception %@ : %@\n %@", exception.name, exception.reason, [exception callStackSymbols]];
            NSLog(@"%@", message);
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @throw;
            });
        }
        return 0;
    }
}
