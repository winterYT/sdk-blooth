//
//  ViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "ViewController.h"
#import <OMRONLib/OMRONLib.h>
#import "ToastUtil.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bp_btn;
@property (weak, nonatomic) IBOutlet UIButton *bf_btn;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bp_btn.layer.borderWidth=1;
    self.bp_btn.layer.borderColor = [UIColor blackColor].CGColor;
    self.bf_btn.layer.borderWidth=1;
    self.bf_btn.layer.borderColor = [UIColor blackColor].CGColor;
    BOOL result = [[OMRONLib shareInstance] registerApp:@"123456"];
    if(!result)
    {
        [ToastUtil showToast:@"初始化失败"];
    }
}
@end
