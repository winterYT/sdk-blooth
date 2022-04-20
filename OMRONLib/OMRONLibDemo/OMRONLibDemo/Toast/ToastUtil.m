//
//  ToastUtil.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/6/11.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "ToastUtil.h"
#import "UIView+Toast.h"
#import "LoadingView.h"
#import <objc/runtime.h>
#import "NSDate+Extension.h"
#import "NSDate+Utilities.h"
#define CustomAlertViewKey @"CustomAlertViewKey"
#define ConfirmAlertViewKey @"ConfirmAlertViewKey"
@implementation ToastUtil
+(void)showToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIApplication sharedApplication] keyWindow] makeToast:message duration:2 position:@"bottom"];
    });
}
+(void)hiddenLoadingView
{
    [[LoadingView shareInstance] hiddenLoadingView];
    
}

+(void)showLoadingView
{
    [[LoadingView shareInstance] showLoadingView];
}

+(void)showLoadingView:(NSString *)message
{
    [[LoadingView shareInstance] showLoadingView:message];
}


+(void)openLoadingView
{
    [[LoadingView shareInstance] openLoadingView];
}

+(void)closeLoadingView
{
    [[LoadingView shareInstance] closeLoadingView];
}

+(void)showAlertView:(NSString *)message complete:(completeBlock)complete
{
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    objc_setAssociatedObject(alert, ConfirmAlertViewKey, complete, OBJC_ASSOCIATION_COPY);
    [alert show];
}

+(void)showDatePickerView:(NSString *)format origin:(id)origin complete:(void(^)(NSString *resolt))complete
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setTitle:@"取消" forState:UIControlStateNormal];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button1.frame = CGRectMake(0, 0, 44, 44);
    [button1 setTitle:@"确定" forState:UIControlStateNormal];
    
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        complete([selectedDate stringWithFormat:format]);
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:origin];
    picker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    //    picker.minimumDate = [NSDate dateWithString:@"1970-01-01" format:@"yyyy-MM-dd"];
//    picker.minimumDate = [NSDate date];
    [picker setCancelButton:[[UIBarButtonItem alloc] initWithCustomView:button]];
    [picker setDoneButton:[[UIBarButtonItem alloc] initWithCustomView:button1]];
    [picker showActionSheetPicker];
}
@end
