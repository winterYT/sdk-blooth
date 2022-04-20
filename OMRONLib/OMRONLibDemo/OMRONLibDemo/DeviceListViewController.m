//
//  DeviceListViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/16.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "DeviceListViewController.h"
#import "BindDeviceTableViewCell.h"
#import <OMRONLib/OMRONLib.h>
#import "LocalStore.h"
#import "ToastUtil.h"
#import "BFUserInfoViewController.h"
#import "MeasureGuideViewController.h"
#import "BluetoothPairingListController.h"
@interface OMRONDevice : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *num;
@property (nonatomic, copy) NSString *userIndex;

@end

@implementation OMRONDevice
@end

@interface DeviceListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *datas;
@property (nonatomic, strong) NSMutableArray *temp;

@end

@implementation DeviceListViewController
{

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.datas = [[NSMutableArray alloc] init];
    [self.tableview registerNib:[UINib nibWithNibName:@"BindDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"BindDeviceTableViewCell"];
    self.tableview.delegate = (id)self;
    self.tableview.dataSource = (id)self;
    self.temp = [NSMutableArray new];
    // Do any additional setup after loading the view from its nib.
  

}
- (void)viewWillAppear:(BOOL)animated {
    [self loadData];
}

-(void)loadData
{
    NSArray *devices = [LocalStore getDeviceStore];
    [self.datas removeAllObjects];
    for (NSDictionary *dic in devices) {
        OMRONDevice *obj = [[OMRONDevice alloc] init];
        obj.num = dic.allKeys[0];
        obj.name = dic.allValues[0][0];
        obj.userIndex = dic.allValues[0][1];
        if(self.deviceListType==2)
        {
            if([obj.name isEqualToString:@"HBF-219T"]||[obj.name isEqualToString:@"HBF-229T"])
            {
                [self.datas addObject:obj];
            }
        }
        else if(self.deviceListType==1)
        {
            if(![obj.name isEqualToString:@"HBF-219T"]&&![obj.name isEqualToString:@"HBF-229T"])
            {
                [self.datas addObject:obj];
            }
        }
    }
    [self.tableview reloadData];
}

- (IBAction)btn_bind_device_click:(id)sender {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *devicelist = [[OMRONLib shareInstance] getOMRONDeviceList];
    if(devicelist.count==0)
    {
        [ToastUtil showToast:@"无支持设备"];
        return;
    }
    if(self.deviceListType==1) {
        BluetoothPairingListController *vcPair = [[BluetoothPairingListController alloc] init];
        [self.navigationController pushViewController:vcPair animated:YES];
        return;
    }
    BOOL isExistsDevices;
    if(self.deviceListType==1)
    {
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
            
            if([devicelist containsObject:@"6231T"])
            {
                [actionSheetController addAction:alertAction17];
                isExistsDevices = YES;
            }
    }else{
        UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"绑定HBF_219T" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BFUserInfoViewController *vc = [[BFUserInfoViewController alloc] init];
            vc.isBindDevice = YES;
            [vc setUserInfoBlock:^(NSDictionary * result) {
                MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
                vcGuide.deviceType = OMRON_HBF_219T;
                [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
                    [self goBindGuide:OMRON_HBF_219T userIndex:0 userInfo:result];
                }];
                [self.navigationController pushViewController:vcGuide animated:YES];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        if([devicelist containsObject:@"HBF-219T"])
        {
            [actionSheetController addAction:alertAction4];
            isExistsDevices = YES;
        }
        
        UIAlertAction *alertAction5 = [UIAlertAction actionWithTitle:@"绑定HBF_229T" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BFUserInfoViewController *vc = [[BFUserInfoViewController alloc] init];
            vc.isBindDevice = YES;
            [vc setUserInfoBlock:^(NSDictionary * result) {
                MeasureGuideViewController *vcGuide = [[MeasureGuideViewController alloc] init];
                vcGuide.deviceType = OMRON_HBF_229T;
                [vcGuide setGuideBlock:^(OMRONDeviceType deviceType){
                    [self goBindGuide:OMRON_HBF_229T userIndex:0 userInfo:result];
                }];
                [self.navigationController pushViewController:vcGuide animated:YES];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        if([devicelist containsObject:@"HBF-229T"])
        {   
            [actionSheetController addAction:alertAction5];
            isExistsDevices = YES;
        }
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





-(void)bindDevice:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex userInfo:(NSDictionary *)userInfo
{
    [ToastUtil showLoadingView:@"绑定设备……"];
    void(^complete)(OMRONSDKStatus status,NSString * _Nonnull deviceName, NSString * _Nonnull deviceId,NSString *_Nonnull advertisingName,NSDictionary *userInfo) = ^(OMRONSDKStatus status,NSString * _Nonnull deviceName, NSString * _Nonnull deviceId,NSString *_Nonnull advertisingName,NSDictionary *userInfo){
        if(status==OMRON_SDK_Success)
        {
            OMRONDevice *obj = [[OMRONDevice alloc] init];
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
            [self loadData];
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
    if(deviceType==OMRON_HBF_219T || deviceType==OMRON_HBF_229T)
    {
        [[OMRONLib shareInstance] bindBFDevice:deviceType status:^(OMRONBLESStaus statue) {
            if(statue==OMRON_BLE_DISCONNECTING)//蓝牙取消配对
            {
                [ToastUtil hiddenLoadingView];
            }
        } userIndexBlock:^(NSString * _Nonnull deviceId, id<OMRONBFAppendUserIndexDelegate>  _Nonnull indexData) {
            UIAlertController *as = [UIAlertController alertControllerWithTitle:@"请选择设备使用者" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"使用者1" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [indexData appendUserIndex:1];
                [ToastUtil showLoadingView];
            }];
            [as addAction:alertAction1];
            UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"使用者2" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [indexData appendUserIndex:2];
                [ToastUtil showLoadingView];
            }];
            [as addAction:alertAction2];
            UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:@"使用者3" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [indexData appendUserIndex:3];
                [ToastUtil showLoadingView];
            }];
            [as addAction:alertAction3];
            UIAlertAction *alertAction4 = [UIAlertAction actionWithTitle:@"使用者4" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [indexData appendUserIndex:4];
                [ToastUtil showLoadingView];
            }];
            [as addAction:alertAction4];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

            }];
            [as addAction:cancelAction];
            
            [self presentViewController:as animated:YES completion:^{
                
            }];
            [ToastUtil hiddenLoadingView];
        } birthday:[userInfo objectForKey:@"dateOfBirth"] height:[[userInfo objectForKey:@"height"] floatValue] isMale:[[userInfo objectForKey:@"gender"] isEqualToString:@"0"]?YES:NO complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName, NSInteger userIndex, NSString * _Nonnull advertisingName, NSDictionary * _Nonnull userInfo) {
            complete(status,deviceName,[NSString stringWithFormat:@"%ld",(long)userIndex],advertisingName,userInfo);
            [LocalStore storeUserInfo:userInfo];
            [ToastUtil hiddenLoadingView];
            if(status==OMRON_SDK_Success){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    else
    {
        [[OMRONLib shareInstance] bindDevice:deviceType complete:^(OMRONSDKStatus status, NSString * _Nonnull deviceName,NSString * _Nonnull deviceId, NSString * _Nonnull advertisingName) {
            complete(status,deviceName,deviceId,advertisingName,@{});
            [ToastUtil hiddenLoadingView];
            if(status==OMRON_SDK_Success){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];

    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BindDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BindDeviceTableViewCell" forIndexPath:indexPath];
    OMRONDevice *obj = (OMRONDevice *)self.datas[indexPath.row];
    [cell configCell:obj.name num:obj.num userIndex:obj.userIndex del:^(NSString *num,NSString *userIndex) {
        [LocalStore delTargetDevice:num];
        //OMRON_CURRENT_DEVICE
        NSUserDefaults *device = [NSUserDefaults standardUserDefaults];
        NSDictionary *dicBP = [device valueForKey:@"OMRON_CURRENT_BP_DEVICE"];
        NSDictionary *dicBF = [device valueForKey:@"OMRON_CURRENT_BF_DEVICE"];
        if(dicBP)
        {
            if([num isEqualToString:[NSString stringWithFormat:@"%@@%@",[dicBP valueForKey:@"num"],userIndex]])
            {
                [device setValue:nil forKey:@"OMRON_CURRENT_BP_DEVICE"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        if(dicBF)
        {
            if([num isEqualToString:[NSString stringWithFormat:@"%@@%@",[dicBF valueForKey:@"num"],userIndex]])
            {
                [device setValue:nil forKey:@"OMRON_CURRENT_BF_DEVICE"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        [self loadData];
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OMRONDevice *obj = (OMRONDevice *)self.datas[indexPath.row];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:obj.name forKey:@"name"];
    [dic setValue:[obj.num substringToIndex:obj.num.length-2] forKey:@"num"];
    [dic setValue:obj.userIndex forKey:@"userIndex"];
    if(self.deviceListType==1)//血压
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_CURRENT_BP_DEVICE" object:nil userInfo:dic];
    }
    else if(self.deviceListType==2)//体脂
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_CURRENT_BF_DEVICE" object:nil userInfo:dic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goBindGuide:(OMRONDeviceType)deviceType userIndex:(NSInteger)userIndex userInfo:(NSDictionary *)userInfo
{
    [self bindDevice:deviceType userIndex:userIndex userInfo:userInfo];
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
