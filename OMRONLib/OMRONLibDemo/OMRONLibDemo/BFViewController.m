//
//  BFViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/8/29.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "BFViewController.h"
#import <OMRONLib/OMRONLib.h>
#import "DeviceListViewController.h"
#import "BFUserInfoViewController.h"
#import "HistoryViewController.h"
#import "ToastUtil.h"
#import "LocalStore.h"
#import "UIViewController+BackButtonHandler.h"
#define OMRON_CURRENT_BF_DEVICE    @"OMRON_CURRENT_BF_DEVICE"
#define OMRON_HISTORY_BFDATAS_FILE  [NSString stringWithFormat:@"%@/Documents/bfhistory.data",NSHomeDirectory()]
typedef void (^HandleBlock) (void);
/**
 *  获取数据状态状态
 */
typedef NS_ENUM(NSInteger, GETDATAStatus){
    DATA_PROCESS = 0,
    DATA_SUCCESS,
    DATA_ERROR,
};
@interface BFViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lab_curdevice;
@property (weak, nonatomic) IBOutlet UIButton *btn_bindDevice;
@property (weak, nonatomic) IBOutlet UILabel *lab_measure_at;
@property (weak, nonatomic) IBOutlet UILabel *lab_weight;
@property (weak, nonatomic) IBOutlet UILabel *lab_bodyFatPercentage;
@property (weak, nonatomic) IBOutlet UILabel *lab_skeletalMusclePercentage;
@property (weak, nonatomic) IBOutlet UILabel *lab_basalMetabolism;
@property (weak, nonatomic) IBOutlet UILabel *lab_bmi;
@property (weak, nonatomic) IBOutlet UILabel *lab_bodyAge;
@property (weak, nonatomic) IBOutlet UILabel *lab_visceralFatLevel;

@property (weak, nonatomic) IBOutlet UIButton *listenBtn;
@property (nonatomic, weak)NSTimer * connentTimer;
@property (nonatomic, assign)NSInteger getDataStatus;
@end

@implementation BFViewController
{
    NSMutableArray *hisObjs;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCurrentDevice:) name:@"NOTIFICATION_CURRENT_BF_DEVICE" object:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;   //禁用侧滑手势

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserver:self forKeyPath:@"getDataStatus" options:(NSKeyValueObservingOptionNew) context:nil];
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [device valueForKey:OMRON_CURRENT_BF_DEVICE];
    if(dic!=nil)
    {
        self.lab_curdevice.text = [NSString stringWithFormat:@"%@#%@",[dic valueForKey:@"name"],[dic valueForKey:@"userIndex"]];
        [self.btn_bindDevice setTitle:@"切换设备" forState:UIControlStateNormal];
    }
    else
    {
        self.lab_curdevice.text = @"-";
        [self.btn_bindDevice setTitle:@"绑定设备" forState:UIControlStateNormal];
    }
}

//- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"getDataStatus"];
//    NSLog(@"dealloc");
//}
- (void)viewDidDisappear:(BOOL)animated {
    [self removeObserver:self forKeyPath:@"getDataStatus"];
    NSLog(@"dealloc");
}

-(void)setCurrentDevice:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    if(dic)
    {
        self.lab_curdevice.text = [NSString stringWithFormat:@"%@#%@",[dic valueForKey:@"name"],[dic valueForKey:@"userIndex"]];
        NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
        [device setValue:dic forKey:OMRON_CURRENT_BF_DEVICE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.btn_bindDevice setTitle:@"切换设备" forState:UIControlStateNormal];
        [self clearData];
    }
}


-(void)clearData
{
    self.lab_weight.text = @"- kg";
    self.lab_measure_at.text = @"-";
    self.lab_bodyFatPercentage.text = @"- %";
    self.lab_skeletalMusclePercentage.text = @"- %";
    self.lab_basalMetabolism.text = @"-";
    self.lab_bmi.text = @"-";
    self.lab_bodyAge.text = @"-";
    self.lab_visceralFatLevel.text = @"-";
}

- (IBAction)btn_userInfo_click:(id)sender {
    if ([[OMRONLib shareInstance] listening] == YES) {
        // UI更新代码
         [self showAlert:^{
             [self pushUseInfo];
         }cancelBlock:nil];
        return;
    }
    [self pushUseInfo];
}

//个人信息
- (void)pushUseInfo {
    BFUserInfoViewController *vc = [[BFUserInfoViewController alloc] init];
    [vc setUserInfoBlock:^(NSDictionary * result) {
        [LocalStore storeUserInfo:result];
    }];
    vc.isBindDevice = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btn_sync_click:(id)sender {
    [self getData];
}

//同步数据
- (void)getData {
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [device valueForKey:OMRON_CURRENT_BF_DEVICE];
    if(dic!=nil)
    {
        NSString *name = [dic valueForKey:@"name"];
        NSString *serialNum = [dic valueForKey:@"num"];
        NSInteger userIndex = [[dic valueForKey:@"userIndex"] integerValue];
        NSDictionary *userInfo = [LocalStore getUserInfo];
        
        OMRONDeviceType deviceType;
        if([name isEqualToString:@"HBF-219T"])
        {
            deviceType = OMRON_HBF_219T;
        }else if ([name isEqualToString:@"HBF-229T"]) {
            deviceType = OMRON_HBF_229T;
        }
        if(userInfo.count==0)
        {
            [ToastUtil showToast:@"个人信息不完整，请先完成个人信息"];
            return;
        }
        [ToastUtil showLoadingView:@"同步数据……"];
        [[OMRONLib shareInstance] getBFDeviceData:deviceType deviceSerialNum:serialNum userIndex:userIndex birthday:[userInfo objectForKey:@"dateOfBirth"] height:[[userInfo objectForKey:@"height"] floatValue] isMale:[[userInfo objectForKey:@"gender"] isEqualToString:@"0"]?YES:NO complete:^(OMRONSDKStatus status, NSArray<OMRONBFObject *> * _Nonnull datas,NSDictionary *userInfo) {
            if(status==OMRON_SDK_Success)
            {
                if(userInfo)
                {
                    [LocalStore storeUserInfo:userInfo];
                }
                if(datas.count>0)
                {
                    OMRONBFObject *obj = [datas lastObject];
                    self.lab_weight.text = [NSString stringWithFormat:@"%@ kg",[NSNumber numberWithFloat:obj.weight]];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.measure_at];
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    self.lab_measure_at.text = [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
                    self.lab_bodyFatPercentage.text = [NSString stringWithFormat:@"%.1f%%",obj.fat_rate];
                    self.lab_skeletalMusclePercentage.text = [NSString stringWithFormat:@"%.1f%%",obj.skeletal_muscles_rate];
                    self.lab_basalMetabolism.text = [NSString stringWithFormat:@"%ld",(long)obj.basal_metabolism];
                    self.lab_bmi.text = [NSString stringWithFormat:@"%.1f",[obj.bmi floatValue]];
                    self.lab_bodyAge.text = [NSString stringWithFormat:@"%ld",(long)obj.body_age];;
                    self.lab_visceralFatLevel.text = [NSString stringWithFormat:@"%ld",(long)obj.visceral_fat];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isExists = [fileManager fileExistsAtPath:OMRON_HISTORY_BFDATAS_FILE];
                    NSMutableArray *historyDatas = [NSMutableArray array];
                    if(isExists)
                    {
                        historyDatas = [NSMutableArray arrayWithContentsOfFile:OMRON_HISTORY_BFDATAS_FILE];
                    }
                    for (OMRONBFObject *obj in datas) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:[NSString stringWithFormat:@"%@",obj.bmi] forKey:@"bmi"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.basal_metabolism] forKey:@"basal_metabolism"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.body_age] forKey:@"body_age"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.fat_rate] forKey:@"fat_rate"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.height] forKey:@"height"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.weight] forKey:@"weight"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.userIndex] forKey:@"userIndex"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.visceral_fat] forKey:@"visceral_fat"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.skeletal_muscles_rate] forKey:@"skeletal_muscles_rate"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.measure_at] forKey:@"measure_at"];
                        [dic setValue:[NSString stringWithFormat:@"%@",obj.device_type] forKey:@"device_type"];
                        [historyDatas addObject:dic];
                    }
                    [historyDatas writeToFile:OMRON_HISTORY_BFDATAS_FILE atomically:YES];
                }
                else
                {
                    [ToastUtil showToast:@"无数据"];
                }
            }else {
                if(status==OMRON_SDK_UnBind)
                {
                    [ToastUtil showToast:@"请先绑定正确的设备"];
                }
                else if(status==OMRON_SDK_NoDevice)
                {
                    [ToastUtil showToast:@"未找到设备"];
                }
                else if(status==OMRON_SDK_UnOpenBlueTooth)
                {
                    [ToastUtil showToast:@"蓝牙未开启,请开启蓝牙"];
                }
                else if(status==OMRON_SDK_UnRegister)
                {
                    [ToastUtil showToast:@"未注册"];
                }
                else if(status==OMRON_SDK_InValidKey)
                {
                    [ToastUtil showToast:@"厂商ID 无效"];
                }
                else if(status==OMRON_SDK_ConnectFail)
                {
                    [ToastUtil showToast:@"连接失败"];
                }else if(status==OMRON_SDK_ScanTimeOut)
                {
                    [ToastUtil showToast:@"扫描超时"];
                }
            }
            [ToastUtil hiddenLoadingView];
        }];
    }
    else
    {
        [ToastUtil showToast:@"请先绑定设备"];
    }
}

//监听数据
- (void)listeningData {
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [device valueForKey:OMRON_CURRENT_BF_DEVICE];
    if(dic!=nil)
    {
        NSString *name = [dic valueForKey:@"name"];
        NSString *serialNum = [dic valueForKey:@"num"];
        NSInteger userIndex = [[dic valueForKey:@"userIndex"] integerValue];
        NSDictionary *userInfo = [LocalStore getUserInfo];
        
        OMRONDeviceType deviceType;
        if([name isEqualToString:@"HBF-219T"])
        {
            deviceType = OMRON_HBF_219T;
        }else if ([name isEqualToString:@"HBF-229T"]) {
            deviceType = OMRON_HBF_229T;
        }
        if(userInfo.count==0)
        {
            [ToastUtil showToast:@"个人信息不完整，请先完成个人信息"];
            return;
        }
        self.getDataStatus = 0;
        [[OMRONLib shareInstance] getBFDeviceData:deviceType deviceSerialNum:serialNum userIndex:userIndex birthday:[userInfo objectForKey:@"dateOfBirth"] height:[[userInfo objectForKey:@"height"] floatValue] isMale:[[userInfo objectForKey:@"gender"] isEqualToString:@"0"]?YES:NO complete:^(OMRONSDKStatus status, NSArray<OMRONBFObject *> * _Nonnull datas,NSDictionary *userInfo) {
            if(status==OMRON_SDK_Success)
            {
                if(userInfo)
                {
                    [LocalStore storeUserInfo:userInfo];
                }
                if(datas.count>0)
                {
                    OMRONBFObject *obj = [datas lastObject];
                    self.lab_weight.text = [NSString stringWithFormat:@"%@ kg",[NSNumber numberWithFloat:obj.weight]];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.measure_at];
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    self.lab_measure_at.text = [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
                    self.lab_bodyFatPercentage.text = [NSString stringWithFormat:@"%.1f%%",obj.fat_rate];
                    self.lab_skeletalMusclePercentage.text = [NSString stringWithFormat:@"%.1f%%",obj.skeletal_muscles_rate];
                    self.lab_basalMetabolism.text = [NSString stringWithFormat:@"%ld",(long)obj.basal_metabolism];
                    self.lab_bmi.text = [NSString stringWithFormat:@"%.1f",[obj.bmi floatValue]];
                    self.lab_bodyAge.text = [NSString stringWithFormat:@"%ld",(long)obj.body_age];;
                    self.lab_visceralFatLevel.text = [NSString stringWithFormat:@"%ld",(long)obj.visceral_fat];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isExists = [fileManager fileExistsAtPath:OMRON_HISTORY_BFDATAS_FILE];
                    NSMutableArray *historyDatas = [NSMutableArray array];
                    if(isExists)
                    {
                        historyDatas = [NSMutableArray arrayWithContentsOfFile:OMRON_HISTORY_BFDATAS_FILE];
                    }
                    for (OMRONBFObject *obj in datas) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:[NSString stringWithFormat:@"%@",obj.bmi] forKey:@"bmi"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.basal_metabolism] forKey:@"basal_metabolism"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.body_age] forKey:@"body_age"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.fat_rate] forKey:@"fat_rate"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.height] forKey:@"height"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.weight] forKey:@"weight"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.userIndex] forKey:@"userIndex"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",(long)obj.visceral_fat] forKey:@"visceral_fat"];
                        [dic setValue:[NSString stringWithFormat:@"%.1f",obj.skeletal_muscles_rate] forKey:@"skeletal_muscles_rate"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.measure_at] forKey:@"measure_at"];
                        [dic setValue:[NSString stringWithFormat:@"%@",obj.device_type] forKey:@"device_type"];
                        [historyDatas addObject:dic];
                    }
                    [historyDatas writeToFile:OMRON_HISTORY_BFDATAS_FILE atomically:YES];
                }
                else
                {
                    [ToastUtil showToast:@"无数据"];
                }
                self.getDataStatus = 1;
            }else {
                if(status==OMRON_SDK_UnBind)
                {
                    [ToastUtil showToast:@"请先绑定正确的设备"];
                }
                else if(status==OMRON_SDK_NoDevice)
                {
                    [ToastUtil showToast:@"未找到设备"];
                }
                else if(status==OMRON_SDK_UnOpenBlueTooth)
                {
                    [ToastUtil showToast:@"蓝牙未开启,请开启蓝牙"];
                }
                else if(status==OMRON_SDK_UnRegister)
                {
                    [ToastUtil showToast:@"未注册"];
                }
                else if(status==OMRON_SDK_InValidKey)
                {
                    [ToastUtil showToast:@"厂商ID 无效"];
                }
                else if(status==OMRON_SDK_ConnectFail)
                {
                    [ToastUtil showToast:@"连接失败"];
                }else if(status==OMRON_SDK_ScanTimeOut)
                {
                    self.getDataStatus = 1;
                    [ToastUtil hiddenLoadingView];
                    return;
                }
                self.getDataStatus = 2;
            }
            [ToastUtil hiddenLoadingView];
        }];
    }
    else
    {
        self.getDataStatus = 2;
        [ToastUtil showToast:@"请先绑定设备"];
    }
}
- (IBAction)btn_watch_click:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if ([btn.currentTitle isEqual:@"开启数据监听"]) {
        [self invalidateTimer];
        [self beginTimer];
    }else {
        [[OMRONLib shareInstance] setlistening:NO];
        [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
        [self invalidateTimer];
    }
}
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BFBind"]) {
        DeviceListViewController *receive = segue.destinationViewController;
        receive.deviceListType = 2;
    }
    else if ([segue.identifier isEqualToString:@"BFHistory"]) {
        HistoryViewController *receive = segue.destinationViewController;
        receive.hisIndex = 1;
        NSMutableArray *historyDatas = [NSMutableArray arrayWithContentsOfFile:OMRON_HISTORY_BFDATAS_FILE];
        if(historyDatas)
        {
            hisObjs = [NSMutableArray array];
            for (NSDictionary *dic in historyDatas) {
                OMRONBFObject *model = [OMRONBFObject new];
                model.bmi = [dic objectForKey:@"bmi"];
                model.basal_metabolism = [[dic valueForKey:@"basal_metabolism"] integerValue];
                model.body_age = [[dic valueForKey:@"body_age"] integerValue];
                model.fat_rate = [[dic valueForKey:@"fat_rate"] floatValue];
                model.height = [[dic valueForKey:@"height"] floatValue];
                model.weight = [[dic valueForKey:@"weight"] floatValue];
                model.userIndex = [[dic valueForKey:@"userIndex"] integerValue];
                model.visceral_fat = [[dic valueForKey:@"visceral_fat"] integerValue];
                model.skeletal_muscles_rate = [[dic valueForKey:@"skeletal_muscles_rate"] floatValue];
                model.measure_at = (long)[[dic valueForKey:@"measure_at"] longLongValue];
                model.device_type = [dic valueForKey:@"device_type"];
                [hisObjs addObject:model];
            }
        }
        receive.hisDatas = hisObjs;
    }
}


//如果是监听状态不能点击
-(void)showAlert:(HandleBlock)confirmBlock cancelBlock:(HandleBlock)cancelBlock{
       UIAlertController *ListenAlertController=[UIAlertController alertControllerWithTitle:@"" message:@"是否停止监听？" preferredStyle:UIAlertControllerStyleAlert];
       //创建actions
       UIAlertAction *Action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
           if (confirmBlock) {
               [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
               [[OMRONLib shareInstance] setlistening:NO];
               [self invalidateTimer];
               confirmBlock();
           }
       }];
       UIAlertAction *Action1=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
           if (cancelBlock) {
               cancelBlock();
           }
           
       }];
       [self presentViewController:ListenAlertController animated:YES completion:nil ];
       [ListenAlertController addAction:Action];
       [ListenAlertController addAction:Action1];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([@"getDataStatus" isEqualToString:keyPath]) { //0 开始请求 1 请求成功 2 请求错误
        if ([[OMRONLib shareInstance] isRegistered]==NO) {
            [self invalidateTimer];
            [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
            [[OMRONLib shareInstance] setlistening:NO];
            return;
        }
        if ([[change objectForKey:@"new"] integerValue] == 0) {
            NSLog(@"%ld+++++监听数据状态开始扫描",[[change objectForKey:@"new"] integerValue]);
            [self.listenBtn setTitle:@"停止数据监听" forState:UIControlStateNormal];
            [[OMRONLib shareInstance] setlistening:YES];
            [self invalidateTimer];
        }else if ([[change objectForKey:@"new"] integerValue] == 1){
            NSLog(@"%ld+++++监听数据状态扫描成功",[[change objectForKey:@"new"] integerValue]);
            [self beginTimer];
            [self.listenBtn setTitle:@"停止数据监听" forState:UIControlStateNormal];
        }else {
            NSLog(@"%ld-----监听数据状态扫描错误",[[change objectForKey:@"new"] integerValue]);
            [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
            [[OMRONLib shareInstance] setlistening:NO];
            [self invalidateTimer];
        }
    }
}
- (void)invalidateTimer {
    if (self.connentTimer!=nil) {
        [self.connentTimer invalidate];
        self.connentTimer = nil;
    }
}
- (void)beginTimer {
    [[OMRONLib shareInstance] setlistening:YES];
    self.connentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(watchBFData) userInfo:@{@"peripheral":@"TIMER"} repeats:YES];
    [self.connentTimer fire];
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([[OMRONLib shareInstance] listening] == YES) {
        // UI更新代码
         [self showAlert:^{
             [self performSegueWithIdentifier:identifier sender:sender];
         } cancelBlock:^{
         }];
        return NO;
    }else {
        return YES;
    }
}
-(void)hideHud{
    [ToastUtil hiddenLoadingView];
}

- (IBAction)btn_unregister_click:(id)sender {
    if ([[OMRONLib shareInstance] listening] == YES) {
        // UI更新代码
         [self showAlert:^{
             [[OMRONLib shareInstance] unRegister];
             [ToastUtil showToast:@"取消注册成功"];
         } cancelBlock:^{
         }];
        return;
    }
    [[OMRONLib shareInstance] unRegister];
    [ToastUtil showToast:@"取消注册成功"];
}

- (BOOL)navigationShouldPopOnBackButton{
    if ([[OMRONLib shareInstance] listening] == YES) {
        // UI更新代码
         [self showAlert:^{
             [self.navigationController popViewControllerAnimated:YES];
         }cancelBlock:nil];
        return NO;
    }else {
        return YES;
    }
}
//定时器轮训方法
- (void)watchBFData {
    [self listeningData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
