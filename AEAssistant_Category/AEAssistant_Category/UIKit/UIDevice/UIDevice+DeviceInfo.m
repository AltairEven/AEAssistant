//
//  UIDevice+DeviceInfo.m
//  AEAssistant
//
//  Created by Qian Ye on 16/4/21.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "UIDevice+DeviceInfo.h"

static CTTelephonyNetworkInfo *_sharedTelephonyNetworkInfo;

@implementation CTTelephonyNetworkInfo(GTelephonyNetworkInfoAddition)

+(CTTelephonyNetworkInfo *)sharedTelephonyNetworkInfo
{
    @synchronized([self class]){
        if (!_sharedTelephonyNetworkInfo) {
            _sharedTelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        }
        
        return _sharedTelephonyNetworkInfo;
    }
    
    return nil;
}

@end

@implementation UIDevice (DeviceInfo)

+ (NSString *)deviceInfo {
    return [NSString stringWithFormat: @"%@ %@ %@ %@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], [[UIDevice currentDevice] localizedModel], [[[CTTelephonyNetworkInfo sharedTelephonyNetworkInfo] subscriberCellularProvider] carrierName]];
}

@end
