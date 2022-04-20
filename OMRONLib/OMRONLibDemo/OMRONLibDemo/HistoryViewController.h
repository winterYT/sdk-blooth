//
//  HistoryViewController.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/5/23.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HistoryViewController : UIViewController
@property (nonatomic,assign) NSInteger hisIndex;//1 BF , 2 BP
@property (nonatomic, copy) NSArray *hisDatas;
@end

NS_ASSUME_NONNULL_END
