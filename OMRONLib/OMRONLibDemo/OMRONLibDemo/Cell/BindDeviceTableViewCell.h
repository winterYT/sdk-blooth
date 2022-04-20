//
//  BindDeviceTableViewCell.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/16.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BindDeviceTableViewCell : UITableViewCell
-(void)configCell:(NSString *)name num:(NSString *)num userIndex:(NSString *)userIndex del:(void(^)(NSString *num,NSString *userIndex))del;

-(void)configCell:(NSString *)name num:(NSString *)num del:(void(^)(NSString *num,NSString *userIndex))del;
@end

NS_ASSUME_NONNULL_END
