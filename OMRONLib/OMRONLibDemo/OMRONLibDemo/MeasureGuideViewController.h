//
//  MeasureGuideViewController.h
//  OMRONLibDemo
//
//  Created by Calvin on 2019/9/23.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OMRONLib/OMRONLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface MeasureGuideViewController : UIViewController
@property (nonatomic, strong) void(^GuideBlock)(OMRONDeviceType deviceType);
@property (nonatomic, assign) OMRONDeviceType deviceType;
@end

NS_ASSUME_NONNULL_END
