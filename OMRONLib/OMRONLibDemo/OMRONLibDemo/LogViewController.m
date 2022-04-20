//
//  LogViewController.m
//  OMRONLibDemo
//
//  Created by Calvin on 2019/6/5.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()
@property (weak, nonatomic) IBOutlet UITextView *normal_textview;
@property (weak, nonatomic) IBOutlet UITextView *error_textview;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *base_path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Documents/OLog/"];
    [self scanFoolder:[NSString stringWithFormat:@"%@",base_path] isError:false];
}

- (void)scanFoolder:(NSString *)targetPath isError:(BOOL)isError {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dicEnumerator = [fileManager enumeratorAtPath:targetPath];
    BOOL isDir = NO;
    BOOL isExist = NO;
    NSMutableString *logStr = [NSMutableString string];
    NSMutableString *logErrorStr = [NSMutableString string];
    for (NSString *path in dicEnumerator)
    {
        NSLog(@"%@",path);
        isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", targetPath, path] isDirectory:&isDir];
        if(isExist)
        {
            if(!isDir)
            {
                NSError *error;
                NSString *temp = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", targetPath, path]  encoding:NSUTF8StringEncoding error:&error];
                if(temp==nil)
                {
                    temp = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", targetPath, path]  encoding:NSMacOSRomanStringEncoding error:&error];
//                    NSLog(@"Temp:%@",temp);
//                    
//                    NSArray *arrEncoding = @[@(NSASCIIStringEncoding),
//                                             @(NSNEXTSTEPStringEncoding),
//                                             @(NSJapaneseEUCStringEncoding),
//                                             @(NSUTF8StringEncoding),
//                                             @(NSISOLatin1StringEncoding),
//                                             @(NSSymbolStringEncoding),
//                                             @(NSNonLossyASCIIStringEncoding),
//                                             @(NSShiftJISStringEncoding),
//                                             @(NSISOLatin2StringEncoding),
//                                             @(NSUnicodeStringEncoding),
//                                             @(NSWindowsCP1251StringEncoding),
//                                             @(NSWindowsCP1252StringEncoding),
//                                             @(NSWindowsCP1253StringEncoding),
//                                             @(NSWindowsCP1254StringEncoding),
//                                             @(NSWindowsCP1250StringEncoding),
//                                             @(NSISO2022JPStringEncoding),
//                                             @(NSMacOSRomanStringEncoding),
//                                             @(NSUTF16StringEncoding),
//                                             @(NSUTF16BigEndianStringEncoding),
//                                             @(NSUTF16LittleEndianStringEncoding),
//                                             @(NSUTF32StringEncoding),
//                                             @(NSUTF32BigEndianStringEncoding),
//                                             @(NSUTF32LittleEndianStringEncoding)
//                                             ];
//                    
//                    NSArray *arrEncodingName = @[@"NSASCIIStringEncoding",
//                                                 @"NSNEXTSTEPStringEncoding",
//                                                 @"NSJapaneseEUCStringEncoding",
//                                                 @"NSUTF8StringEncoding",
//                                                 @"NSISOLatin1StringEncoding",
//                                                 @"NSSymbolStringEncoding",
//                                                 @"NSNonLossyASCIIStringEncoding",
//                                                 @"NSShiftJISStringEncoding",
//                                                 @"NSISOLatin2StringEncoding",
//                                                 @"NSUnicodeStringEncoding",
//                                                 @"NSWindowsCP1251StringEncoding",
//                                                 @"NSWindowsCP1252StringEncoding",
//                                                 @"NSWindowsCP1253StringEncoding",
//                                                 @"NSWindowsCP1254StringEncoding",
//                                                 @"NSWindowsCP1250StringEncoding",
//                                                 @"NSISO2022JPStringEncoding",
//                                                 @"NSMacOSRomanStringEncoding",
//                                                 @"NSUTF16StringEncoding",
//                                                 @"NSUTF16BigEndianStringEncoding",
//                                                 @"NSUTF16LittleEndianStringEncoding",
//                                                 @"NSUTF32StringEncoding",
//                                                 @"NSUTF32BigEndianStringEncoding",
//                                                 @"NSUTF32LittleEndianStringEncoding"
//                                                 ];
//                    
//                    for (int i = 0 ; i < [arrEncoding count]; i++) {
//                        unsigned long encodingCode = [arrEncoding[i] unsignedLongValue];
//                        NSLog(@"arrEncodingName>>(%@)", arrEncodingName[i]);
//                        NSError *error = nil;
//                        NSString *filePath = [NSString stringWithFormat:@"%@%@", targetPath, path]; // <---这里是要查看的文件路径
//                        NSString *aString = [NSString stringWithContentsOfFile:filePath encoding:encodingCode  error:&error];
//                        NSLog(@"Error:>>%@", [error localizedDescription]);
//                        NSData *data = [aString dataUsingEncoding:encodingCode];
//                        NSString *string = [[NSString alloc] initWithData:data encoding:encodingCode];
//                        NSLog(@"[string length]>>>%lu", (unsigned long)[string length]);
//                        if([string length]>0)
//                        {
//                            NSLog(string);
//                        }
//                    }
                }
                if(temp!=nil)
                {
                    NSMutableString *log = [NSMutableString string];
                    [log appendString:[NSString stringWithFormat:@"\n\n%@",path]];
                    [log appendString:@"\n----------------\n"];
                    [log appendString:temp];
                    [log appendString:@"\n----------------\n"];
                    if(isError)
                    {
                        [logErrorStr appendString:log];
                    }
                    else
                    {
                        if(![path containsString:@"error"])
                        {
                            [logStr appendString:log];
                        }
                    }
                }
            }
            else
            {
                [self scanFoolder:[NSString stringWithFormat:@"%@/%@",targetPath,path] isError:true];
            }
        }
    }
    if(isError)
    {
        self.error_textview.text = logErrorStr;
    }
    else
    {
        self.normal_textview.text = logStr;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
