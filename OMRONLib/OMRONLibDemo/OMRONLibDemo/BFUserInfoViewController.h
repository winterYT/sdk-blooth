//
//  BFUserInfoViewController.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFUserInfoViewController : UIViewController
@property (nonatomic, strong) void(^userInfoBlock)(NSDictionary *);
@property (nonatomic, assign) BOOL isBindDevice;
@end

NS_ASSUME_NONNULL_END
