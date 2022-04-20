//
//  BFUserInfoViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "BFUserInfoViewController.h"
#import "Toast/ToastUtil.h"
#import "NSDate+Extension.h"
#import "LocalStore.h"
@interface BFUserInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield_birthday;
@property (weak, nonatomic) IBOutlet UITextField *textfield_gender;
@property (weak, nonatomic) IBOutlet UITextField *textfield_height;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (weak, nonatomic) IBOutlet UILabel *lab_tip;
@property (weak, nonatomic) IBOutlet UILabel *lab_tip2;
@end

@implementation BFUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"个人信息"];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:gesture];
    self.userInfo = [LocalStore getUserInfo];
    NSDictionary *dic = self.userInfo;
    if(dic)
    {
        self.textfield_height.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"height"]];
        self.textfield_gender.text = [[dic objectForKey:@"gender"] isEqualToString:@"0"]?@"男":@"女";
        self.textfield_birthday.text = [NSDate stringWithDate:[dic objectForKey:@"dateOfBirth"] format:@"yyyy-MM-dd"];
    }
    else
    {
        self.textfield_birthday.text = @"2001-01-01";
        self.textfield_height.text = @"175";
        self.textfield_gender.text = @"男";
    }
    
    if(self.isBindDevice)
    {
        [self.lab_tip setHidden:NO];
        [self.lab_tip2 setHidden:NO];
    }
    else
    {
        [self.lab_tip setHidden:YES];
        [self.lab_tip2 setHidden:YES];
    }
}

-(void)endEditing
{
    [self.view endEditing:YES];
}

- (IBAction)btn_gender_click:(id)sender {
    [self.view endEditing:YES];
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.textfield_gender.text = @"男";
    }];
    [actionSheetController addAction:alertAction1];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.textfield_gender.text = @"女";
    }];
    [actionSheetController addAction:alertAction2];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    actionSheetController.title = @"请选择性别";
    [actionSheetController addAction:cancelAction];
    [self presentViewController:actionSheetController animated:YES completion:^{
        
    }];
}

- (IBAction)btn_birthdat_click:(id)sender {
    [self.view endEditing:YES];
    [ToastUtil showDatePickerView:@"yyyy-MM-dd" origin:self.view complete:^(NSString * _Nonnull resolt) {
        self.textfield_birthday.text = resolt;
    }];
}

- (IBAction)btn_comfirm:(id)sender {
    [self.view endEditing:YES];
    if(self.textfield_birthday.text.length==0)
    {
        [ToastUtil showToast:@"清选择生日"];
        return;
    }
    if(self.textfield_gender.text.length==0)
    {
        [ToastUtil showToast:@"清选择性别"];
        return;
    }
    if(self.textfield_height.text.length==0)
    {
        [ToastUtil showToast:@"请输入身高"];
        return;
    }
    
    if([self.textfield_height.text floatValue]<100||[self.textfield_height.text floatValue]>199.5)
    {
        [ToastUtil showToast:@"请输入100~199.5的数值"];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    if(self.userInfoBlock)
    {
        NSDictionary *dic = @{@"dateOfBirth":[NSDate dateWithString:self.textfield_birthday.text format:@"yyyy-MM-dd"], @"gender":[self.textfield_gender.text isEqualToString:@"男"]?@"0":@"1",@"height":self.textfield_height.text};
        if(self.userInfo!=nil)
        {
            [LocalStore storeUserInfo:dic];
        }
        [self userInfoBlock](dic);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField.text hasSuffix:@"."])//判断最后一位是否是小数点
    {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isHaveDian;
    
    // 判断是否有小数点
    if ([textField.text containsString:@"."])
    {
        isHaveDian = YES;
    }
    else
    {
        isHaveDian = NO;
    }
    
    if (string.length > 0)
    {
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.'))
        {
            return NO;
        }
        
        // 只能有一个小数点
        if (isHaveDian && single == '.')
        {
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.'))
        {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"])
        {
            if (textField.text.length > 1)
            {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."])
                {
                    return NO;
                }
            }
            else
            {
                if (![string isEqualToString:@"."])
                {
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入一位
        if (isHaveDian)
        {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location)
            {
                if ([textField.text pathExtension].length > 0)
                {
                    return NO;
                }
            }
        }
    }
    
    return YES;
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
