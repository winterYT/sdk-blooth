//
//  BindDeviceTableViewCell.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/16.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "BindDeviceTableViewCell.h"
@interface BindDeviceTableViewCell()
@property (weak, nonatomic) IBOutlet UIButton *btn_del;
@property (weak, nonatomic) IBOutlet UILabel *lab_name;
@property (weak, nonatomic) IBOutlet UILabel *lab_num;
@property (nonatomic, strong) void(^delBlock)(NSString *num,NSString *userIndex);
@property (nonatomic, copy) NSString *curNum;
@property (nonatomic, copy) NSString *curUserIndex;
@property (weak, nonatomic) IBOutlet UIButton *delLabel;
@end
@implementation BindDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configCell:(NSString *)name num:(NSString *)num userIndex:(NSString *)userIndex del:(void(^)(NSString *num,NSString *userIndex))del
{
    self.delBlock = del;
    if(![userIndex isEqualToString:@"0"])
    {
        self.lab_name.text = [NSString stringWithFormat:@"%@ #%@",name,userIndex];
    }
    else
    {
        self.lab_name.text = name;
    }
    self.lab_num.text = [num substringToIndex:num.length-2];
    self.curNum = num;
    self.curUserIndex = userIndex;
}

-(void)configCell:(NSString *)name num:(NSString *)num del:(void(^)(NSString *num,NSString *userIndex))del
{
    self.delBlock = del;
    self.lab_name.text = name;
    self.lab_num.text = [num substringToIndex:num.length-2];
    [self.delLabel setTitle:@"配对" forState:UIControlStateNormal];
    self.curNum = num;
}

- (IBAction)btn_del_click:(id)sender {
    if(self.delBlock)
    {
        [self delBlock](self.curNum,self.curUserIndex);
    }
}

@end
