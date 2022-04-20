//
//  NetTool.m
//  OMRONLib
//
//  Created by Calvin on 2019/5/16.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "NetTool.h"
#import "OMRONReachability.h"
@implementation NetTool
+(instancetype)shareInstance
{
    static NetTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetTool alloc] init];
    });
    
    return instance;
}

-(BOOL)isHasNet
{
    OMRONReachability *reachability = [OMRONReachability reachabilityWithHostName:@"www.apple.com"];
    OMRONNetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if(internetStatus==NotReachable)
    {
        return NO;
    }
    return YES;
}

-(void)post:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObj))success failture:(void(^)(NSError *error, id responseObj))failture
{
    NSDictionary *headers = @{ @"Content-Type": @"application/x-www-form-urlencoded",
                               @"cache-control": @"no-cache"};
    NSMutableData *postData =[[NSMutableData alloc] init];
    for(NSString *key in params.allKeys)
    {
        [postData appendData:[[NSString stringWithFormat:@"%@=%@&",key,[params valueForKey:key]]dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
        if(data == nil) {
           failture(error,@{});
         } else {
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
           failture(error,dict);
         }
        } else {
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            success(dict);
        }
    }];
    [dataTask resume];
}
@end
