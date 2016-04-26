//
//  AENormalUser.m
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AENormalUser.h"
#import <AEAssistant_ThirdParty/AEAssistant_ThirdParty.h>

#define USERDEFAULT_UID_KEY (@"UserDefaultUidKey")
#define KEYCHAIN_SERVICE_UIDSKEY (@"com.KidsTC.iPhoneAPP.uid")

static AENormalUser *_sharedInstance = nil;

@interface AENormalUser ()

@end

@implementation AENormalUser
@synthesize uid = _uid, skey = _skey;

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)currentUser {
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        _sharedInstance = [[AENormalUser alloc] init];
    });
    return _sharedInstance;
}

- (NSString *)userName {
    if (!_userName) {
        _userName = @"";
    }
    return _userName;
}

- (NSString *)nickName {
    if (!_nickName) {
        _nickName = @"";
    }
    return _nickName;
}


- (NSString *)uid {
    if (!_uid) {
        _uid = @"";
    }
    return _uid;
}


- (NSString *)skey {
    if (!_skey) {
        _skey = @"";
    }
    return _skey;
}

#pragma mark Public methods

- (void)updateUid:(NSString *)uid skey:(NSString *)skey {
    if ([uid length] > 0 && [skey length] > 0) {
        _hasLogin = YES;
        _uid = uid;
        _skey = skey;
        
        [self setLocalSave];
    }
}

- (void)checkLoginStatusWithParam:(NSDictionary *)param fromServerWithResult:(void (^)(BOOL, NSDictionary *, NSError *))result {
    [self getLocalSave];
    if ([self.uid length] > 0 && [self.skey length] > 0) {
        _hasLogin = YES;
        //本地存储了uid和skey，可以开始检查是否登录
        if (!self.checkLoginRequest) {
            return;
        }
        __weak typeof (self) weakSelf = self;
        [weakSelf.checkLoginRequest startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
            _hasLogin = YES;
            if (result) {
                result(_hasLogin, responseData, nil);
            }
        } failure:^(HttpRequestClient *client, NSError *error) {
            _hasLogin = NO;
            [weakSelf clearLoginInfo];
            if (result) {
                result(_hasLogin, nil, error);
            }
        }];
    } else {
        if (result) {
            NSError *error = [NSError errorWithDomain:@"AENormalUser" code:-1 userInfo:@{@"errMsg":@"no user login info"}];
            result(_hasLogin, nil, error);
        }
    }
}

- (void)logoutManually:(BOOL)manually withParam:(NSDictionary *)param success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    if (manually) {
        if (!self.logoutRequest) {
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        [weakSelf.logoutRequest startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
            if (success) {
                success(responseData);
            }
        } failure:^(HttpRequestClient *client, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } else {
        if (success) {
            success(nil);
        }
        if (failure) {
            failure(nil);
        }
    }
    [self clearLoginInfo];
}

#pragma mark Private methods

- (void)setLocalSave {
    [[NSUserDefaults standardUserDefaults] setObject:self.uid forKey:USERDEFAULT_UID_KEY];
    [SFHFKeychainUtils storeUsername:self.uid andPassword:self.skey forServiceName:KEYCHAIN_SERVICE_UIDSKEY updateExisting:YES error:nil];
}

- (void)getLocalSave {
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_UID_KEY];
    if ([self.uid length] > 0) {
        _skey = [SFHFKeychainUtils getPasswordForUsername:self.uid andServiceName:KEYCHAIN_SERVICE_UIDSKEY error:nil];
    }
}

- (void)clearLoginInfo {
    [SFHFKeychainUtils deleteItemForUsername:self.uid andServiceName:KEYCHAIN_SERVICE_UIDSKEY error:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULT_UID_KEY];
    _uid = nil;
    _skey = nil;
    _hasLogin = NO;
}

@end
