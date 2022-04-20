//
//  ToastUtil.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/6/11.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionSheetPicker.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^choiceCompletionBlock)(int index);
typedef void (^completeBlock)(void);
@interface ToastUtil : NSObject
+(void)showToast:(NSString *)message;
+(void)hiddenLoadingView;
+(void)showLoadingView;
+(void)showLoadingView:(NSString *)message;
+(void)showAlertView:(NSString *)message complete:(completeBlock)complete;
+(void)showDatePickerView:(NSString *)format origin:(id)origin complete:(void(^)(NSString *resolt))complete;
@end

NS_ASSUME_NONNULL_END
