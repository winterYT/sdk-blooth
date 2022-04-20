//
//  BluetoothPairingListController.m
//  OMRONLibDemo
//
//  Created by 焦国防 on 2022/4/9.
//  Copyright © 2022 Calvin. All rights reserved.
//

#import "BluetoothPairingListController.h"
#import "UIViewController+BackButtonHandler.h"
#import "BindDeviceTableViewCell.h"
#import <OMRONLib/OMRONLib.h>
#import "LocalStore.h"
#import "ToastUtil.h"
#import "MeasureGuideViewController.h"
#import "DeviceListViewController.h"

@interface OMRONDemoDevice : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *num;
@property (nonatomic, copy) NSString *userIndex;

@end

@implementation OMRONDemoDevice
@end
@interface BluetoothPairingListController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray *datas;

@property (assign, nonatomic) BOOL scaning;


@end

@implementation BluetoothPairingListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设备配对";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;   //禁用侧滑手势
    [self.tableview registerNib:[UINib nibWithNibName:@"BindDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"BindDeviceTableViewCell"];
    self.tableview.delegate = (id)self;
    self.tableview.dataSource = (id)self;
    self.datas = [[NSMutableArray alloc] init];
}
- (IBAction)refresh_click:(id)sender {
    [self scanAllDevices];
}

//刚进入界面扫描周围设备
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self scanAllDevices];
}

//扫描周围设备
- (void)scanAllDevices {
    self.scaning = YES;
    [ToastUtil showLoadingView:@"扫描设备……"];
    NSLog(@"viewwillapperar%@",@(self.scaning));
    [[OMRONLib shareInstance] scanAllDevicescomplete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName,NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName) {
        if(status==OMRON_SDK_Success)
        {
            if(self.datas.count == 0) {
                OMRONDemoDevice *obj = [[OMRONDemoDevice alloc] init];
                obj.name = deviceName;
                obj.num = advertisingName;
                [self.datas addObject:obj];
                
                NSLog(@"*******************start=======");
                NSLog(@"deviceName===%@\\deviceId===%@\\\advertisingName===%@",deviceName,deviceId,advertisingName);
                NSLog(@"*******************end=======");
                [self.tableview reloadData];
            }else {
                BOOL isContain = NO;
                for (int i = 0; i < self.datas.count; i++) {
                    OMRONDemoDevice *obj = self.datas[i];
                    if ([obj.name isEqual:deviceName]) {
                        isContain = true;
                        break;
                    }
                }
                if (isContain == NO) {
                    OMRONDemoDevice *obj = [[OMRONDemoDevice alloc] init];
                    obj.name = deviceName;
                    obj.num = advertisingName;
                    [self.datas addObject:obj];
                    NSLog(@"*******************start=======");
                    NSLog(@"deviceName===%@\\deviceId===%@\\\advertisingName===%@",deviceName,deviceId,advertisingName);
                    NSLog(@"*******************end=======");
                    [self.tableview reloadData];
                }
                
            }
            NSLog(@"数组长度====%ld",self.datas.count);
        }else {
            if(status==OMRON_SDK_NoNet)
            {
                [ToastUtil showToast:@"请在网络连接状态下进行绑定"];
            }
            else if(status==OMRON_SDK_UnOpenBlueTooth)
            {
                [ToastUtil showToast:@"蓝牙未开启,请开启蓝牙"];
            }
            else if(status==OMRON_SDK_UnSupportDevice)
            {
                [ToastUtil showToast:@"不支持当前设备"];
            }
            else if(status==OMRON_SDK_NoDevice)
            {
                [ToastUtil showToast:@"未找到设备"];
            }
            else if(status==OMRON_SDK_UnRegister)
            {
                [ToastUtil showToast:@"未注册"];
            }
            else if(status==OMRON_SDK_BindFail)
            {
                [ToastUtil showToast:@"绑定失败"];
            }
            else if (status==OMRON_SDK_ConnectFail)
            {
                [ToastUtil showToast:@"连接失败"];
            }
            else if (status==OMRON_SDK_InValidKey)
            {
                [ToastUtil showToast:@"厂商id无效"];
            }else if(status == OMRON_SDK_ScanTimeOut) {
                [ToastUtil showToast:@"扫描结束"];
            }
            self.scaning = NO;
            [ToastUtil hiddenLoadingView];

        }
        
        
    }];
}

//根据searinumb配对
- (void)bindBPDevice:(OMRONDemoDevice *)obj {
    [ToastUtil showLoadingView:@"绑定设备……"];
    void(^complete)(OMRONSDKStatus status,NSString * _Nonnull deviceName, NSString * _Nonnull deviceId,NSString *_Nonnull advertisingName,NSDictionary *userInfo) = ^(OMRONSDKStatus status,NSString * _Nonnull deviceName, NSString * _Nonnull deviceId,NSString *_Nonnull advertisingName,NSDictionary *userInfo){
        if(status==OMRON_SDK_Success)
        {
            OMRONDemoDevice *obj = [[OMRONDemoDevice alloc] init];
            obj.name = deviceName;
            obj.num = advertisingName;
            if(deviceId.length>1)
            {
               obj.userIndex = @"0";
            }
            else
            {
                obj.userIndex = deviceId;
            }
            [LocalStore store:advertisingName name:deviceName userIndex:obj.userIndex userInfo:userInfo];
            [self.datas addObject:obj];
//            [self loadData];
            NSLog(@"UserInfo: %@",userInfo);
        }
        else if(status==OMRON_SDK_NoNet)
        {
            [ToastUtil showToast:@"请在网络连接状态下进行绑定"];
        }
        else if(status==OMRON_SDK_UnOpenBlueTooth)
        {
            [ToastUtil showToast:@"蓝牙未开启,请开启蓝牙"];
        }
        else if(status==OMRON_SDK_UnSupportDevice)
        {
            [ToastUtil showToast:@"不支持当前设备"];
        }
        else if(status==OMRON_SDK_NoDevice)
        {
            [ToastUtil showToast:@"未找到设备"];
        }
        else if(status==OMRON_SDK_UnRegister)
        {
            [ToastUtil showToast:@"未注册"];
        }
        else if(status==OMRON_SDK_BindFail)
        {
            [ToastUtil showToast:@"绑定失败"];
        }
        else if (status==OMRON_SDK_ConnectFail)
        {
            [ToastUtil showToast:@"连接失败"];
        }
        else if (status==OMRON_SDK_InValidKey)
        {
            [ToastUtil showToast:@"厂商id无效"];
        }
    };
    OMRONDeviceType deviceType = [self getDeviceType:obj.name];
    [[OMRONLib shareInstance] bindBPDevice:deviceType deviceSerialNum:obj.num complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName) {
        complete(status,deviceName,deviceId,advertisingName,@{});
        [ToastUtil hiddenLoadingView];
        if(status==OMRON_SDK_Success){
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BindDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BindDeviceTableViewCell" forIndexPath:indexPath];
    OMRONDemoDevice *obj = (OMRONDemoDevice *)self.datas[indexPath.row];
    typeof(self) weakSelf = self;
    [cell configCell:obj.name num:obj.num del:^(NSString * _Nonnull num, NSString * _Nonnull userIndex) {
        [weakSelf bindBPDevice:obj];
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (BOOL)navigationShouldPopOnBackButton{
    if (self.scaning) {
        return NO;
    }
    return YES;
}
- (IBAction)all_devices_click:(id)sender {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *devicelist = [[OMRONLib shareInstance] getOMRONDeviceList];
    if(devicelist.count==0)
    {
        [ToastUtil showToast:@"无支持设备"];
        return;
    }
    BOOL isExistsDevices;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"绑定9200T" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_9200T;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_9200T userIndex:0 userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    if([devicelist containsObject:@"HEM-9200T"])
    {
        [actionSheetController addAction:alertAction1];
        isExistsDevices = YES;
    }
    
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"绑定U32J" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_U32J;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_U32J  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"U32J"])
    {
        [actionSheetController addAction:alertAction2];
        isExistsDevices = YES;
    }
    
    UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"绑定J750" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J750;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J750  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J750"])
    {
        [actionSheetController addAction:alertAction3];
        isExistsDevices = YES;
    }
    
    UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"绑定J730" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J730;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J730  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J730"])
    {
        [actionSheetController addAction:alertAction4];
        isExistsDevices = YES;
    }
    
    UIAlertAction *alertAction5 = [UIAlertAction actionWithTitle:@"绑定J761" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J761;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J761  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J761"])
    {
        [actionSheetController addAction:alertAction5];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction6 = [UIAlertAction actionWithTitle:@"绑定9200L" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_9200L;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_9200L  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"HEM-9200L"])
    {
        [actionSheetController addAction:alertAction6];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction7 = [UIAlertAction actionWithTitle:@"绑定U32K" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_U32K;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_U32K  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"U32K"])
    {
        [actionSheetController addAction:alertAction7];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction8 = [UIAlertAction actionWithTitle:@"绑定J750L" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J750L;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J750L  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J750L"])
    {
        [actionSheetController addAction:alertAction8];
        isExistsDevices = YES;
    }
    
    UIAlertAction *alertAction9 = [UIAlertAction actionWithTitle:@"绑定U18" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_U18;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_U18  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"U18"])
    {
        [actionSheetController addAction:alertAction9];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction10 = [UIAlertAction actionWithTitle:@"绑定J760" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J760;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J760  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J760"])
    {
        [actionSheetController addAction:alertAction10];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction11 = [UIAlertAction actionWithTitle:@"绑定T50" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_T50;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_T50  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"T50"])
    {
        [actionSheetController addAction:alertAction11];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction12 = [UIAlertAction actionWithTitle:@"绑定U32" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_U32;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_U32  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"U32"])
    {
        [actionSheetController addAction:alertAction12];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction13 = [UIAlertAction actionWithTitle:@"绑定J732" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J732;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J732  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J732"])
    {
        [actionSheetController addAction:alertAction13];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction14 = [UIAlertAction actionWithTitle:@"绑定J751" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_J751;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_J751  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"J751"])
    {
        [actionSheetController addAction:alertAction14];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction15 = [UIAlertAction actionWithTitle:@"绑定U36J" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_U36J;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_U36J  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"U36J"])
    {
        [actionSheetController addAction:alertAction15];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction16 = [UIAlertAction actionWithTitle:@"绑定U36T" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_BLOOD_U36T;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_BLOOD_U36T  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"U36T"])
    {
        [actionSheetController addAction:alertAction16];
        isExistsDevices = YES;
    }
    UIAlertAction *alertAction17 = [UIAlertAction actionWithTitle:@"绑定HEM6231T" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
        vcGuide.deviceType = OMRON_HEM_6231T;
        [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
            [self goBindGuide:OMRON_HEM_6231T  userIndex:0  userInfo:nil];
        }];
        [self.navigationController pushViewController:vcGuide animated:YES];
    }];
    
    if([devicelist containsObject:@"HEM-6231T"])
    {
        [actionSheetController addAction:alertAction17];
        isExistsDevices = YES;
    }
    if(isExistsDevices)
    {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        actionSheetController.title = @"绑定设备";
        [actionSheetController addAction:cancelAction];
        [self presentViewController:actionSheetController animated:YES completion:^{
            
        }];
    }
    else
    {
        [ToastUtil showToast:@"没有可用设备"];
    }
}

-(void)goBindGuide:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex userInfo:(NSDictionary *)userInfo
{
    [self bindDevice:deviceType userIndex:userIndex userInfo:userInfo];
}

-(void)bindDevice:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex userInfo:(NSDictionary *)userInfo
{
    [ToastUtil showLoadingView:@"绑定设备……"];
    void(^complete)(OMRONSDKStatus status,NSString * _Nonnull deviceName, NSString * _Nonnull deviceId,NSString *_Nonnull advertisingName,NSDictionary *userInfo) = ^(OMRONSDKStatus status,NSString * _Nonnull deviceName, NSString * _Nonnull deviceId,NSString *_Nonnull advertisingName,NSDictionary *userInfo){
        if(status==OMRON_SDK_Success)
        {
            OMRONDemoDevice *obj = [[OMRONDemoDevice alloc] init];
            obj.name = deviceName;
            obj.num = advertisingName;
            if(deviceId.length>1)
            {
                obj.userIndex = @"0";
            }
            else
            {
                obj.userIndex = deviceId;
            }
            [LocalStore store:advertisingName name:deviceName userIndex:obj.userIndex userInfo:userInfo];
            [self.datas addObject:obj];
            //            [self loadData];
            NSLog(@"UserInfo: %@",userInfo);
        }
        else if(status==OMRON_SDK_NoNet)
        {
            [ToastUtil showToast:@"请在网络连接状态下进行绑定"];
        }
        else if(status==OMRON_SDK_UnOpenBlueTooth)
        {
            [ToastUtil showToast:@"蓝牙未开启,请开启蓝牙"];
        }
        else if(status==OMRON_SDK_UnSupportDevice)
        {
            [ToastUtil showToast:@"不支持当前设备"];
        }
        else if(status==OMRON_SDK_NoDevice)
        {
            [ToastUtil showToast:@"未找到设备"];
        }
        else if(status==OMRON_SDK_UnRegister)
        {
            [ToastUtil showToast:@"未注册"];
        }
        else if(status==OMRON_SDK_BindFail)
        {
            [ToastUtil showToast:@"绑定失败"];
        }
        else if (status==OMRON_SDK_ConnectFail)
        {
            [ToastUtil showToast:@"连接失败"];
        }
        else if (status==OMRON_SDK_InValidKey)
        {
            [ToastUtil showToast:@"厂商id无效"];
        }
    };
    [[OMRONLib shareInstance] bindDevice:deviceType complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName,NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName) {
        complete(status,deviceName,deviceId,advertisingName,@{});
        [ToastUtil hiddenLoadingView];
        if(status==OMRON_SDK_Success){
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[DeviceListViewController class]]) {
                    DeviceListViewController *A =(DeviceListViewController *)controller;
                    [self.navigationController popToViewController:A animated:YES];
                }
            }
        }
    }];
    
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
