//
//  UIViewController+BackButtonHandler.h
//  OMRONLibDemo
//
//  Created by 郭子龙 on 2022/4/3.
//  Copyright © 2022 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// UIViewController+BackButtonHandler.h
@protocol BackButtonHandlerProtocol <NSObject>
@optional
// 重写下面的方法以拦截导航栏返回按钮点击事件，返回 YES 则 pop，NO 则不 pop
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end

@interface UINavigationController (ShouldPopOnBackButton)

@end

NS_ASSUME_NONNULL_END
