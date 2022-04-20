//
//  HistoryTableViewCell.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/23.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OMRONLib/OMRONLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface HistoryTableViewCell : UITableViewCell
+(instancetype)cellWithTableView:(UITableView *)tableView;
-(void)configCell:(OMRONBPObject *)obj;
@end

NS_ASSUME_NONNULL_END
