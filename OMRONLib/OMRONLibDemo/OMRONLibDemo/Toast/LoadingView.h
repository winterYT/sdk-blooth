//
//  LoadingView.h
//  Mall
//
//  Created by Calvin on 15/11/19.
//  Copyright © 2015年 iss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
{
    NSInteger count;
    NSInteger timeout;
    NSTimer *timeoutTimer;
    
    UIView *contentView;
    UIActivityIndicatorView *indicator;
    UILabel *msgLabel;
}

+(id)shareInstance;

-(void)showLoadingView;
-(void)showLoadingView:(NSString *)message;
-(void)hiddenLoadingView;
-(void)closeLoadingView;
-(void)openLoadingView;
@end
