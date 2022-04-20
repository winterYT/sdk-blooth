//
//  BindBFDeviceTableViewCell.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/9/18.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OMRONLib/OMRONLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface BFHistoryTableViewCell : UITableViewCell
+(instancetype)cellWithTableView:(UITableView *)tableView;
-(void)configCell:(OMRONBFObject *)obj;
@end

NS_ASSUME_NONNULL_END
