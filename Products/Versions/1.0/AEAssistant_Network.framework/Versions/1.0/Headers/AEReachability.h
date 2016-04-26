//
//  AEReachability.h
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AENetworkStatusUnknown          = -1,
    AENetworkStatusNotReachable     = 0,
    AENetworkStatusReachableViaWWAN = 1,
    AENetworkStatusReachableViaWiFi = 2,
}AENetworkStatus;

@interface AEReachability : NSObject

@property (strong, nonatomic) NSString *domain;

@property (nonatomic, readonly) BOOL isNetworkStatusOK;

@property (nonatomic, readonly) AENetworkStatus status;

+ (instancetype)sharedInstance;

//开始网络状态监控
- (void)startNetworkMonitoringWithStatusChangeBlock:(void(^)(AENetworkStatus status))block;
//停止网络状态监控
- (void)stopNetworkStatusMonitoring;

@end
