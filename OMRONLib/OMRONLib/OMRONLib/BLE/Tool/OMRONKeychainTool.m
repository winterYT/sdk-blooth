//
//  OMRONKeychainTool.m
//  OMRONLib
//
//  Created by Calvin on 2019/5/8.
//  Copyright © 2019 Calvin. All rights reserved.
//

#import "OMRONKeychainTool.h"
NSString * const KEY_UDID_INSTEAD = @"com.omronlib.udid";
@implementation OMRONKeychainTool
+(NSString *)getDeviceIDInKeychain {
    NSString *getUDIDInKeychain = (NSString *)[OMRONKeychainTool load:KEY_UDID_INSTEAD];
//    if (!getUDIDInKeychain ||[getUDIDInKeychain isEqualToString:@""]||[getUDIDInKeychain isKindOfClass:[NSNull class]]) {
//        CFUUIDRef puuid = CFUUIDCreate( nil );
//        CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
//        NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
//        CFRelease(puuid);
//        CFRelease(uuidString);
//        [OMRONKeychainTool save:KEY_UDID_INSTEAD data:result];
//        getUDIDInKeychain = (NSString *)[OMRONKeychainTool load:KEY_UDID_INSTEAD];
//    }
    return getUDIDInKeychain;
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+(void)saveDeviceUUID:(NSString *)uuid
{
    [OMRONKeychainTool save:KEY_UDID_INSTEAD data:uuid];
}

+(void)deleteDeviceUUID
{
    [OMRONKeychainTool delete:KEY_UDID_INSTEAD];
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}
@end
