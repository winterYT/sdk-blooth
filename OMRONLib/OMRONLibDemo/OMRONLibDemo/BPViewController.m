//
//  BPViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/8/29.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "BPViewController.h"
#import <OMRONLib/OMRONLib.h>
#import "HistoryViewController.h"
#import "ToastUtil.h"
#import "DeviceListViewController.h"
#import "LogViewController.h"
#import "UIViewController+BackButtonHandler.h"
#define OMRON_CURRENT_BP_DEVICE    @"OMRON_CURRENT_BP_DEVICE"
#define OMRON_HISTORY_BPDATAS_FILE  [NSString stringWithFormat:@"%@/Documents/history.data",NSHomeDirectory()]
typedef void (^HandleBlock) (void);
@interface BPViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lab_curdevice;
@property (weak, nonatomic) IBOutlet UIButton *btn_bindDevice;
@property (weak, nonatomic) IBOutlet UIButton *btn_sync;
@property (weak, nonatomic) IBOutlet UIButton *btn_data;
@property (weak, nonatomic) IBOutlet UILabel *lab_measuretime;
@property (weak, nonatomic) IBOutlet UILabel *lab_systolic;
@property (weak, nonatomic) IBOutlet UILabel *lab_diastolic;
@property (weak, nonatomic) IBOutlet UILabel *lab_pulse;
@property (weak, nonatomic) IBOutlet UILabel *lab_arrhythmiaFlg;
@property (weak, nonatomic) IBOutlet UILabel *lab_bmFlg;
@property (weak, nonatomic) IBOutlet UILabel *lab_cwsFlg;
@property (nonatomic, weak)NSTimer * connentTimer;
@property (nonatomic, assign)NSInteger getDataStatus;

@property (weak, nonatomic) IBOutlet UIButton *listenBtn;

@end

@implementation BPViewController
{
    NSMutableArray *hisObjs;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCurrentDevice:) name:@"NOTIFICATION_CURRENT_BP_DEVICE" object:nil];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;   //禁用侧滑手势
    // Do any additional setup after loading the view.
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    BOOL result = [[OMRONLib shareInstance] registerApp:@"123456"];
    //    if(!result)
    //    {
    //        [ToastUtil showToast:@"初始化失败"];
    //    }
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [device valueForKey:OMRON_CURRENT_BP_DEVICE];
    if(dic!=nil)
    {
        self.lab_curdevice.text = [dic valueForKey:@"name"];
        [self.btn_bindDevice setTitle:@"切换设备" forState:UIControlStateNormal];
    }
    else
    {
        self.lab_curdevice.text = @"-";
        [self.btn_bindDevice setTitle:@"绑定设备" forState:UIControlStateNormal];
    }
}

-(void)setCurrentDevice:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    if(dic!=nil)
    {
        self.lab_curdevice.text = [dic valueForKey:@"name"];
        NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
        [device setValue:dic forKey:OMRON_CURRENT_BP_DEVICE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.btn_bindDevice setTitle:@"切换设备" forState:UIControlStateNormal];
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

- (void)setGetDataStatus:(NSInteger)getDataStatus {
    _getDataStatus = getDataStatus;
    if ([[OMRONLib shareInstance] isRegistered]==NO) {
        [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
        [[OMRONLib shareInstance] setlistening:NO];
        return;
    }
    if (getDataStatus == 1) {
        NSLog(@"开启数据监听=====");
        [self listentingData];
        [[OMRONLib shareInstance] setlistening:YES];
        [self.listenBtn setTitle:@"停止数据监听" forState:UIControlStateNormal];
    }else if(getDataStatus == 0){
        [[OMRONLib shareInstance] setlistening:YES];
        [self.listenBtn setTitle:@"停止数据监听" forState:UIControlStateNormal];
    }else {
        NSLog(@"停止数据监听======");
        [[OMRONLib shareInstance] setlistening:NO];
        [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
    }
}



- (IBAction)btn_watch_click:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if ([btn.currentTitle isEqual:@"开启数据监听"]) {
        [[OMRONLib shareInstance] setlistening:YES];
        [self.listenBtn setTitle:@"停止数据监听" forState:UIControlStateNormal];
        [self listentingData];
    }else {
        [[OMRONLib shareInstance] setlistening:NO];
        [self.listenBtn setTitle:@"开启数据监听" forState:UIControlStateNormal];
    }

}


//监听血压计数据
- (void)watchBPData {
    [self listentingData];
}

- (IBAction)btn_sync_click:(id)sender {
    [self scandevice];

}

//同步数据
-(void)scandevice{
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [device valueForKey:OMRON_CURRENT_BP_DEVICE];
    if(dic!=nil)
    {
        NSString *name = [dic valueForKey:@"name"];
        NSString *serialNum = [dic valueForKey:@"num"];
     
        OMRONDeviceType deviceType = [self getDeviceType:name];
        [ToastUtil showLoadingView:@"同步数据……"];
        [[OMRONLib shareInstance] getDeviceData:deviceType deviceSerialNum:serialNum complete:^(OMRONSDKStatus status, NSArray<OMRONBPObject *> * _Nonnull datas)  {
            if(status==OMRON_SDK_Success)
            {
                if(datas.count>0)
                {
                    OMRONBPObject *item = (OMRONBPObject *)datas.lastObject;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.measure_at];
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    self.lab_measuretime.text = [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
                    self.lab_systolic.text = [NSString stringWithFormat:@"%ld",(long)item.sbp];
                    self.lab_diastolic.text = [NSString stringWithFormat:@"%ld",(long)item.dbp];
                    self.lab_pulse.text = [NSString stringWithFormat:@"%ld",(long)item.pulse];
                    self.lab_arrhythmiaFlg.text = [NSString stringWithFormat:@"%@",item.ihb_flg==1?@"是":@"否"];
                    self.lab_bmFlg.text = [NSString stringWithFormat:@"%@",item.bm_flg==1?@"是":@"否"];
                    self.lab_cwsFlg.text = [NSString stringWithFormat:@"%@",item.cws_flg==1?@"是":@"否"];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isExists = [fileManager fileExistsAtPath:OMRON_HISTORY_BPDATAS_FILE];
                    NSMutableArray *historyDatas = [NSMutableArray array];
                    if(isExists)
                    {
                        historyDatas = [NSMutableArray arrayWithContentsOfFile:OMRON_HISTORY_BPDATAS_FILE];
                    }
                    for (OMRONBPObject *obj in datas) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.sbp] forKey:@"sbp"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.dbp] forKey:@"dbp"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.pulse] forKey:@"pulse"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.ihb_flg] forKey:@"ihb_flg"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.bm_flg] forKey:@"bm_flg"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.cws_flg] forKey:@"cws_flg"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.measureUser] forKey:@"measureUser"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.measure_at] forKey:@"measure_at"];
                        [dic setValue:[NSString stringWithFormat:@"%@",obj.device_type] forKey:@"device_type"];
                        [historyDatas addObject:dic];
                    }
                    [historyDatas writeToFile:OMRON_HISTORY_BPDATAS_FILE atomically:YES];
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
-(void)listentingData{
    NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [device valueForKey:OMRON_CURRENT_BP_DEVICE];
    if(dic!=nil)
    {
        NSString *name = [dic valueForKey:@"name"];
        NSString *serialNum = [dic valueForKey:@"num"];
     
        OMRONDeviceType deviceType = [self getDeviceType:name];
        self.getDataStatus = 0;
        [[OMRONLib shareInstance] getDeviceData:deviceType deviceSerialNum:serialNum complete:^(OMRONSDKStatus status, NSArray<OMRONBPObject *> * _Nonnull datas)  {
            if(status==OMRON_SDK_Success)
            {
                if(datas.count>0)
                {
                    OMRONBPObject *item = (OMRONBPObject *)datas.lastObject;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.measure_at];
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    self.lab_measuretime.text = [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
                    self.lab_systolic.text = [NSString stringWithFormat:@"%ld",(long)item.sbp];
                    self.lab_diastolic.text = [NSString stringWithFormat:@"%ld",(long)item.dbp];
                    self.lab_pulse.text = [NSString stringWithFormat:@"%ld",(long)item.pulse];
                    self.lab_arrhythmiaFlg.text = [NSString stringWithFormat:@"%@",item.ihb_flg==1?@"是":@"否"];
                    self.lab_bmFlg.text = [NSString stringWithFormat:@"%@",item.bm_flg==1?@"是":@"否"];
                    self.lab_cwsFlg.text = [NSString stringWithFormat:@"%@",item.cws_flg==1?@"是":@"否"];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isExists = [fileManager fileExistsAtPath:OMRON_HISTORY_BPDATAS_FILE];
                    NSMutableArray *historyDatas = [NSMutableArray array];
                    if(isExists)
                    {
                        historyDatas = [NSMutableArray arrayWithContentsOfFile:OMRON_HISTORY_BPDATAS_FILE];
                    }
                    for (OMRONBPObject *obj in datas) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.sbp] forKey:@"sbp"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.dbp] forKey:@"dbp"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.pulse] forKey:@"pulse"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.ihb_flg] forKey:@"ihb_flg"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.bm_flg] forKey:@"bm_flg"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.cws_flg] forKey:@"cws_flg"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.measureUser] forKey:@"measureUser"];
                        [dic setValue:[NSString stringWithFormat:@"%ld",obj.measure_at] forKey:@"measure_at"];
                        [dic setValue:[NSString stringWithFormat:@"%@",obj.device_type] forKey:@"device_type"];
                        [historyDatas addObject:dic];
                    }
                    [historyDatas writeToFile:OMRON_HISTORY_BPDATAS_FILE atomically:YES];
                }
                else
                {
                    [ToastUtil showToast:@"无数据"];
         
                }
//                self.getDataStatus = 1;
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
                else if(status==OMRON_SDK_ConnectFail )
                {
                    [ToastUtil showToast:@"连接失败"];
                }else if(status==OMRON_SDK_ScanTimeOut)
                {
                    self.getDataStatus = 1;
//                    [ToastUtil hiddenLoadingView];
                    return;
                }
                self.getDataStatus = 2;
            }
//            [ToastUtil hiddenLoadingView];
        }];
    }
    else
    {
        self.getDataStatus = 2;
        [ToastUtil showToast:@"请先绑定设备"];
    }
}
//-(void)hideHud{
//    [ToastUtil hiddenLoadingView];
//    [ToastUtil showToast:@"扫描超时"];
//}

-(IBAction)historyData:(id)sender
{
    NSMutableArray *historyDatas = [NSMutableArray arrayWithContentsOfFile:OMRON_HISTORY_BPDATAS_FILE];
    if(historyDatas!=nil)
    {
        hisObjs = [NSMutableArray array];
        for (NSDictionary *dic in historyDatas) {
            OMRONBPObject *model = [OMRONBPObject new];
            model.sbp = [[dic valueForKey:@"sbp"] integerValue];
            model.dbp = [[dic valueForKey:@"dbp"] integerValue];
            model.pulse = [[dic valueForKey:@"pulse"] integerValue];
            model.ihb_flg = [[dic valueForKey:@"ihb_flg"] integerValue];
            model.bm_flg = [[dic valueForKey:@"bm_flg"] integerValue];
            model.cws_flg = [[dic valueForKey:@"cws_flg"] integerValue];
            model.measureUser = [[dic valueForKey:@"measureUser"] integerValue];
            model.measure_at = (long)[[dic valueForKey:@"measure_at"] longLongValue];
            model.device_type = [dic valueForKey:@"device_type"];
            [hisObjs addObject:model];
        }
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
       if ([segue.identifier isEqualToString:@"BPBind"]) {
        DeviceListViewController *receive = segue.destinationViewController;
        receive.deviceListType = 1;
    }
    else if ([segue.identifier isEqualToString:@"BPHistory"]) {
        HistoryViewController *receive = segue.destinationViewController;
        receive.hisDatas = hisObjs;
        receive.hisIndex = 2;
    }
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

- (OMRONDeviceType)getDeviceType:(NSString*)name {
    OMRONDeviceType deviceType;
    if([name isEqualToString:@"HEM-9200T"]){
        deviceType = OMRON_BLOOD_9200T;
    }
    else if([name isEqualToString:@"U32J"]) {
        deviceType = OMRON_BLOOD_U32J;
    }
    else if([name isEqualToString:@"J730"]) {
        deviceType = OMRON_BLOOD_J730;
    }
    else if([name isEqualToString:@"U32K"]) {
        deviceType = OMRON_BLOOD_U32K;
    }
    else if([name isEqualToString:@"J750L"]) {
        deviceType = OMRON_BLOOD_J750L;
    }
    else if([name isEqualToString:@"J761"]) {
        deviceType = OMRON_BLOOD_J761;
    }
    else if([name isEqualToString:@"HEM-9200L"]) {
        deviceType = OMRON_BLOOD_9200L;
    }
    else if([name isEqualToString:@"U18"]) {
        deviceType = OMRON_BLOOD_U18;
    }
    else if([name isEqualToString:@"J760"]) {
        deviceType = OMRON_BLOOD_J760;
    } else if([name isEqualToString:@"T50"]) {
        deviceType = OMRON_BLOOD_T50;
    } else if([name isEqualToString:@"U32"]) {
        deviceType = OMRON_BLOOD_U32;
    } else if([name isEqualToString:@"J732"]) {
        deviceType = OMRON_BLOOD_J732;
    } else if([name isEqualToString:@"J751"]) {
        deviceType = OMRON_BLOOD_J751;
    } else if([name isEqualToString:@"U36J"]) {
        deviceType = OMRON_BLOOD_U36J;
    } else if([name isEqualToString:@"U36T"]) {
        deviceType = OMRON_BLOOD_U36T;
    } else if([name isEqualToString:@"HEM_6231T"]) {
        deviceType = OMRON_HEM_6231T;
    }
    else {
        deviceType = OMRON_BLOOD_J750;
    }
    return  deviceType;
}
@end
