//
//  NetTool.h
//  OMRONLib
//
//  Created by Calvin on 2019/5/16.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetTool : NSObject
+(instancetype)shareInstance;
-(BOOL)isHasNet;
-(void)post:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failture:(void(^)(NSError *error, id responseObj))failture;
@end

NS_ASSUME_NONNULL_END
