//
//  LoadingView.m
//  Mall
//
//  Created by Calvin on 15/11/19.
//  Copyright © 2015年 iss. All rights reserved.
//

#import "LoadingView.h"
#import "Masonry.h"
#import <OMRONLib/OMRONLib.h>
#import "ToastUtil.h"
#define Screen_Height           [UIScreen mainScreen].bounds.size.height
#define Screen_Width            [UIScreen mainScreen].bounds.size.width
@interface LoadingView()
@property (nonatomic, assign) BOOL isCloseLoadingView;
@end

@implementation LoadingView

#pragma mark - ShareInstance
+(id)shareInstance
{
    static id shareInstance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        //添加手势，点击屏幕其他区域关闭键盘的操作
         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenLoading)];
         self.userInteractionEnabled = YES;
         [self addGestureRecognizer:gesture];
        self.isCloseLoadingView = false;
        count = 0;
        timeout = 0;
        [self setFrame:[[UIScreen mainScreen] bounds]];
        [self setBackgroundColor:[UIColor clearColor]];
        //ContentView
        contentView = [[UIView alloc] init];
        [contentView.layer setCornerRadius:10.0];
        [contentView.layer setMasksToBounds:YES];
        [contentView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:contentView];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(Screen_Width / 4, Screen_Width / 4));
            make.center.equalTo(self);
        }];
        
        //背景
        UIView *contentBackground = [[UIView alloc] init];
        [contentBackground setBackgroundColor:[UIColor blackColor]];
        [contentBackground setAlpha:0.6];
        [contentView addSubview:contentBackground];
        
        [contentBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        //UIActivityIndicatorView
        indicator = [[UIActivityIndicatorView alloc] init];
        [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicator stopAnimating];
        [contentView addSubview:indicator];
        
        [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
        }];
        
        msgLabel = [[UILabel alloc] init];
        [msgLabel setTextColor:[UIColor whiteColor]];
        [msgLabel setNumberOfLines:0];
        [msgLabel setTextAlignment:NSTextAlignmentCenter];
        [msgLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [msgLabel setFont:[UIFont systemFontOfSize:14]];
        [contentView addSubview:msgLabel];
        [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(contentView.mas_centerX);
            make.bottom.equalTo(contentView).with.offset(-3);
            make.height.mas_equalTo(30);
        }];
        
     
      
    }
    return self;
}

-(void)hidenLoading{
//    [[OMRONLib shareInstance]stopConnect:^(BOOL isCancel) {
//        if (isCancel) {
//            [self hiddenLoadingView];
//        }else{
////           NSLog(@"设备已连接，取消失败");
//
//        }
//    }];
}

#pragma mark - 显示
-(void)showLoadingView
{
    [self showLoadingView:@"Loading..."];
}

-(void)showLoadingView:(NSString *)message
{
    if (self.isCloseLoadingView) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (count == 0)
        {
            [self setAlpha:0.0];
            [[[UIApplication sharedApplication] keyWindow] addSubview:self];
            [UIView animateWithDuration:0.2 animations:^{
                [self setAlpha:1.0];
            }];
            
            [msgLabel setText:message];
            CGSize msgSize = [self getSizeToFit:msgLabel];
            [msgLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(msgSize.height);
            }];
            
            [self mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo([[UIApplication sharedApplication] keyWindow]).insets(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            
            [indicator startAnimating];
        }
        count ++;
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self];
//        [self performSelector:@selector(hiddenLoadingView) withObject:nil afterDelay:30];
    });
}

-(void)hiddenLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (count > 0)
        {
            count --;
        }
        else
        {
            count = 0;
        }
        
        if (count == 0 && self && self.superview)
        {
            [UIView animateWithDuration:0.5 animations:^{
            }completion:^(BOOL finished) {
                [indicator stopAnimating];
                [self removeFromSuperview];
            }];
            
//            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenLoadingView) object:nil];
        }
    });
}

-(void)closeLoadingView
{
    self.isCloseLoadingView = true;
}

-(void)openLoadingView
{
    self.isCloseLoadingView = false;
}

-(CGSize)getSizeToFit:(UILabel *)label
{
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(label.bounds.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:label.font, NSFontAttributeName, nil] context:nil].size;
    
    return size;
}

-(CGFloat)getTextHeight:(NSString *)text font:(UIFont *)font width:(CGFloat)width
{
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName, nil] context:nil];
    return textSize.size.height + 17;
}

-(CGFloat)getTextWidth:(NSString *)text font:(UIFont *)font height:(CGFloat)height
{
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName, nil] context:nil];
    return textSize.size.width;
}

@end
