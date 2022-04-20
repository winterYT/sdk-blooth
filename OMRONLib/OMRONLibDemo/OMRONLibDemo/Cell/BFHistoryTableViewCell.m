//
//  BindBFDeviceTableViewCell.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/9/18.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "BFHistoryTableViewCell.h"
@interface BFHistoryTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *lab_Name;
@property (weak, nonatomic) IBOutlet UILabel *lab_measure_at;
@property (weak, nonatomic) IBOutlet UILabel *lab_weight;
@property (weak, nonatomic) IBOutlet UILabel *lab_bodyFatPercentage;
@property (weak, nonatomic) IBOutlet UILabel *lab_skeletalMusclePercentage;
@property (weak, nonatomic) IBOutlet UILabel *lab_basalMetabolism;
@property (weak, nonatomic) IBOutlet UILabel *lab_bmi;
@property (weak, nonatomic) IBOutlet UILabel *lab_bodyAge;
@property (weak, nonatomic) IBOutlet UILabel *lab_visceralFatLevel;
@end
@implementation BFHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"BFHistoryTableViewCell";
    BFHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BFHistoryTableViewCell" owner:self options:nil] firstObject];
    }
    return cell;
}

-(void)configCell:(OMRONBFObject *)obj
{
    self.lab_Name.text = [NSString stringWithFormat:@"%@ #%ld",obj.device_type,(long)obj.userIndex];
    self.lab_weight.text = [NSString stringWithFormat:@"体重 %.1fkg",obj.weight];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.measure_at];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.lab_measure_at.text = [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
    self.lab_bodyFatPercentage.text = [NSString stringWithFormat:@"体脂肪率 %.1f%%",obj.fat_rate];
    self.lab_skeletalMusclePercentage.text = [NSString stringWithFormat:@"骨骼肌率 %.1f%%",obj.skeletal_muscles_rate];
    self.lab_basalMetabolism.text = [NSString stringWithFormat:@"基础代谢 %ld",(long)obj.basal_metabolism];
    self.lab_bmi.text = [NSString stringWithFormat:@"BMI %.1f",[obj.bmi floatValue]];
    self.lab_bodyAge.text = [NSString stringWithFormat:@"体年龄 %ld",(long)obj.body_age];;
    self.lab_visceralFatLevel.text = [NSString stringWithFormat:@"内脏脂肪 %ld",(long)obj.visceral_fat];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
