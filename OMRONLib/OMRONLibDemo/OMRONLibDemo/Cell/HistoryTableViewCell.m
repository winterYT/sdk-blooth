//
//  HistoryTableViewCell.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/23.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "HistoryTableViewCell.h"
@interface HistoryTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *lab_device_type;
@property (weak, nonatomic) IBOutlet UILabel *lab_measure_at;
@property (weak, nonatomic) IBOutlet UILabel *lab_pressure;
@property (weak, nonatomic) IBOutlet UILabel *lab_pulse;
@property (weak, nonatomic) IBOutlet UIImageView *img_ihb_flg;
@property (weak, nonatomic) IBOutlet UIImageView *img_cws_flg;
@property (weak, nonatomic) IBOutlet UIImageView *img_bm_flg;
@end
@implementation HistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"HistoryTableViewCell";
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil] firstObject];
    }
    return cell;
}

-(void)configCell:(OMRONBPObject *)obj
{
    self.lab_device_type.text = obj.device_type;
    self.lab_pressure.text = [NSString stringWithFormat:@"%ld/%ld",obj.sbp,obj.dbp];
    self.lab_pulse.text = [NSString stringWithFormat:@"%ld",obj.pulse];
//    NSLog(@"%ld",obj.measure_at);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.measure_at];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.lab_measure_at.text = [NSString stringWithFormat:@"%@",[format stringFromDate:date]];
    
    if(obj.ihb_flg==1)
    {
        self.img_ihb_flg.image = [UIImage imageNamed:@"cem_bp_nearest_pluseStatus_enable_icon"];
    }
    else
    {
        self.img_ihb_flg.image = [UIImage imageNamed:@"cem_bp_nearest_pluseStatus_disable_icon"];
    }
    
    if(obj.cws_flg==1)
    {
        self.img_cws_flg.image = [UIImage imageNamed:@"cem_bp_nearest_wearStatus_enable_icon"];
    }
    else
    {
        self.img_cws_flg.image = [UIImage imageNamed:@"cem_bp_nearest_wearStatus_disable_icon"];
    }
    
    if(obj.bm_flg==1)
    {
        self.img_bm_flg.image = [UIImage imageNamed:@"cem_bp_nearest_bodyMovementStatus_enable_icon"];
    }
    else
    {
        self.img_bm_flg.image = [UIImage imageNamed:@"cem_bp_nearest_bodyMovementStatus_disable_icon"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
