//
//  AEReachability.m
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AEReachability.h"
#import <AEAssistant_Network.h>

static AEReachability *_sharedManager = nil;

@interface AEReachability ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@end

@implementation AEReachability
@synthesize domain;
@synthesize isNetworkStatusOK = _isNetworkStatusOK;
@synthesize reachabilityManager;
@synthesize status = _status;

- (id)init
{
    self = [super init];
    if (self) {
        //默认有效,因为监控开始时网络状态未知
        _isNetworkStatusOK = YES;
    }
    
    return self;
}



+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^ (void) {
        _sharedManager = [[AEReachability alloc] init];
    });
    
    return _sharedManager;
}



- (void)startNetworkMonitoringWithStatusChangeBlock:(void (^)(AENetworkStatus))block
{
    //初始化网络状态监控
    if (self.domain && ![self.domain isEqualToString:@""]) {
        self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:self.domain];
    } else {
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    }
    [self.reachabilityManager startMonitoring];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        _status = (AENetworkStatus)status;
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            _isNetworkStatusOK = YES;
        } else {
            _isNetworkStatusOK = NO;
        }
        
        block((AENetworkStatus)status);
    }];
    
}


- (void)stopNetworkStatusMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    
    _isNetworkStatusOK = NO;
}

@end
