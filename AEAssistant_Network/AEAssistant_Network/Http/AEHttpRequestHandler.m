//
//  AEHttpRequestHandler.m
//  AEAssistant_Network
//
//  Created by Altair on 7/25/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import "AEHttpRequestHandler.h"
#import "AEReachability.h"
#import "AEHttpCookieManager.h"
#import "InterfaceManager.h"

NSString *const kHandledServerResponsedLogoutNotification = @"kHandledServerResponsedLogoutNotification";
static AEHttpRequestConfiguration *_commonConfig = nil;

@interface AEHttpRequestHandler ()

@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, strong) NSURLSessionTask *requestTask;

- (NSStringEncoding)configStringEncoding;

- (NSTimeInterval)configTimeoutSeconds;

- (NSString *)configHttpMethod;

- (NetworkErrorBlcok)configErrorBlock;

- (NSError *)configValidResponse:(NSDictionary *)respData;

- (NSNumber *)configLogoutErrorNumber;

- (AEHttpRequestUserInfo *)configRequestUserInfo;

- (BOOL)configDisplayDebugInfo;

- (NSURLRequest *)builtHttpRequest;

- (void)logBeforeRequest;

@end

@implementation AEHttpRequestHandler
@synthesize urlString = _urlString, urlAliasName = _urlAliasName;
@synthesize requestDurationTime = _requestDurationTime;

#pragma mark Initialization

+ (instancetype)clientWithUrlString:(NSString *)url {
    return [[AEHttpRequestHandler alloc] initWithUrlString:url];
}

- (instancetype)initWithUrlString:(NSString*)url {
    self = [self init];
    if (self) {
        self.urlString = url;
    }
    return self;
}

+ (instancetype)clientWithUrlAliasName:(NSString *)name {
    return [[AEHttpRequestHandler alloc] initWithUrlAliasName:name];
}

- (instancetype)initWithUrlAliasName:(NSString *)name {
    self = [self init];
    if (self) {
        self.urlAliasName = name;
    }
    return self;
}

#pragma mark Setter & Getter

+ (void)setCommonRequestConfiguration:(AEHttpRequestConfiguration *)config {
    _commonConfig = config;
}


- (NSTimeInterval)requestDurationTime {
    NSTimeInterval duration = [self.endTime timeIntervalSinceDate:self.startTime];
    _requestDurationTime = duration;
    
    return _requestDurationTime;
}

- (void)setUrlAliasName:(NSString *)urlAliasName {
    _urlAliasName = urlAliasName;
    self.urlString = [[InterfaceManager sharedManager] getURLStringWithAliasName:urlAliasName];
}

#pragma mark Request

- (void)startHttpRequestWithSuccess:(void (^)(AEHttpRequestHandler *, NSDictionary *))success failure:(void (^)(AEHttpRequestHandler *, NSError *))failure {
    __weak typeof(self) weakSelf = self;
    NetworkErrorBlcok errorBlock = [weakSelf configErrorBlock];
    
    if (![[AEReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    //请求时间置零
    _requestDurationTime = 0;
    NSURLRequest *request = [self builtHttpRequest];
    NSStringEncoding stringEncoding = [self configStringEncoding];
    [self logBeforeRequest];
    self.startTime = [NSDate date];
    
    self.requestTask = [AFHttpRequestWrapper requestWithUrlRequest:request stringEncoding:stringEncoding parameter:weakSelf.originalParam success:^(NSURLRequest *request, id responseObject) {
        weakSelf.endTime = [NSDate date];
        
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duration:%f, response:%@", weakSelf.requestDurationTime, [NSString jsonFromObject:responseObject]);
        }
        NSError *error  = [weakSelf configValidResponse:responseObject];
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        if (success) {
            success(weakSelf, responseObject);
        }
    } failure:^(NSURLRequest *request, NSError *error) {
        weakSelf.endTime = [NSDate date];
        NSNumber *logoutNumber = [weakSelf configLogoutErrorNumber];
        if (logoutNumber && error.code == [logoutNumber integerValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHandledServerResponsedLogoutNotification object:error];
        }
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duratnion:%f, error description:%@", weakSelf.requestDurationTime, [error localizedDescription]);
        }
    }];
    [self.requestTask resume];
}

- (void)startHttpRequestWithRestParameter:(NSDictionary *)rParam originalParameter:(NSDictionary *)oParam success:(void (^)(AEHttpRequestHandler *, NSDictionary *))success failure:(void (^)(AEHttpRequestHandler *, NSError *))failure {
    self.restfulParam = [rParam copy];
    self.originalParam = [oParam copy];
    [self startHttpRequestWithSuccess:success failure:failure];
}

- (void)startHttpRequestWithParameter:(NSDictionary *)param success:(void (^)(AEHttpRequestHandler *, NSDictionary *))success failure:(void (^)(AEHttpRequestHandler *, NSError *))failure {
    self.originalParam = [param copy];
    [self startHttpRequestWithSuccess:success failure:failure];
}

- (void)uploadImageWithData:(NSData *)data success:(void (^)(AEHttpRequestHandler *, NSDictionary *))success failure:(void (^)(AEHttpRequestHandler *, NSError *))failure {
    if (!data) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NetworkErrorBlcok errorBlock = [weakSelf configErrorBlock];
    
    if (![[AEReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    
    //请求时间置零
    _requestDurationTime = 0;
    [self logBeforeRequest];
    self.startTime = [NSDate date];
    
    self.requestTask = [AFHttpRequestWrapper requestWithUrlRequest:[weakSelf builtHttpRequest] stringEncoding:[weakSelf configStringEncoding] parameter:weakSelf.originalParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:data name:@"commentImage.jpg"];
    } success:^(NSURLRequest *request, id responseObject) {
        
        weakSelf.endTime = [NSDate date];
        
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duration:%f, response:%@", weakSelf.requestDurationTime, [NSString jsonFromObject:responseObject]);
        }
        NSError *error  = [weakSelf configValidResponse:responseObject];
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        
        success(weakSelf, responseObject);
    } failure:^(NSURLRequest *request, NSError *error) {
        weakSelf.endTime = [NSDate date];
        NSNumber *logoutNumber = [weakSelf configLogoutErrorNumber];
        if (logoutNumber && error.code == [logoutNumber integerValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHandledServerResponsedLogoutNotification object:error];
        }
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duratnion:%f, error description:%@", weakSelf.requestDurationTime, [error localizedDescription]);
        }
    }];
    [self.requestTask resume];
}

- (void)downloadImageWithSuccess:(void (^)(AEHttpRequestHandler *, UIImage *))success failure:(void (^)(AEHttpRequestHandler *, NSError *))failure {
    __weak typeof(self) weakSelf = self;
    NetworkErrorBlcok errorBlock = [weakSelf configErrorBlock];
    
    if (![[AEReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        return;
    }
    
    //请求时间置零
    _requestDurationTime = 0;
    [self logBeforeRequest];
    self.startTime = [NSDate date];
    
    self.requestTask = [AFHttpRequestWrapper requestWithUrlRequest:[weakSelf builtHttpRequest] stringEncoding:[weakSelf configStringEncoding] parameter:weakSelf.originalParam success:^(NSURLRequest *request, id responseObject) {
        weakSelf.endTime = [NSDate date];
        
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duration:%f, response:%@", weakSelf.requestDurationTime, [NSString jsonFromObject:responseObject]);
        }
        NSError *error  = [weakSelf configValidResponse:responseObject];
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        if (success) {
            success(weakSelf, responseObject);
        }
    } failure:^(NSURLRequest *request, NSError *error) {
        weakSelf.endTime = [NSDate date];
        NSNumber *logoutNumber = [weakSelf configLogoutErrorNumber];
        if (logoutNumber && error.code == [logoutNumber integerValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHandledServerResponsedLogoutNotification object:error];
        }
        if (failure) {
            failure(weakSelf, error);
        }
        if (errorBlock) {
            errorBlock(error);
        }
        if ([weakSelf configDisplayDebugInfo]) {
            NSLog(@"duratnion:%f, error description:%@", weakSelf.requestDurationTime, [error localizedDescription]);
        }
    }];
    [self.requestTask resume];
}

- (void)cancelRequest {
    if (!self.requestTask) {
        return;
    }
    [self.requestTask cancel];
}


#pragma mark Private methods

- (NSStringEncoding)configStringEncoding {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSStringEncoding encoding = [config stringEncoding];
    if (config.stringEncoding <= 0) {
        //默认UTF-8
        encoding = NSUTF8StringEncoding;
    }
    self.endTime = [NSDate date];
    NSLog(@"config duration:%f", self.requestDurationTime);
    
    return encoding;
}

- (NSTimeInterval)configTimeoutSeconds {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSTimeInterval seconds = [config timeoutSeconds];
    if (seconds <= 0) {
        //默认10秒超时
        seconds = 10;
    }
    return seconds;
}

- (NSString *)configHttpMethod {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSString *method = [config httpMethod];
    if (!method || ![method isKindOfClass:[NSString class]] || [method length] == 0) {
        return @"GET";
    }
    return method;
}

- (NetworkErrorBlcok)configErrorBlock {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NetworkErrorBlcok block = [config errorBlock];
    return block;
}

- (NSError *)configValidResponse:(NSDictionary *)respData {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    if (config.validationBlock) {
        NSError *error = config.validationBlock(respData);
        return error;
    }
    return nil;
}

- (NSNumber *)configLogoutErrorNumber {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    NSNumber *number = [config logoutErrorNumber];
    return number;
}

- (AEHttpRequestUserInfo *)configRequestUserInfo {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    AEHttpRequestUserInfo *info = [config requestUserInfo];
    return info;
}

- (BOOL)configDisplayDebugInfo {
    AEHttpRequestConfiguration *config = self.requestConfiguration ? self.requestConfiguration : _commonConfig;
    BOOL display = [config displayDebugInfo];
    return display;
}

- (NSURLRequest *)builtHttpRequest {
    //resetful
    if ([self.restfulParam count] > 0) {
        NSMutableString *restfulParamString = [[NSMutableString alloc] init];
        [self.restfulParam enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [restfulParamString appendString:[NSString stringWithFormat:@"/%@/%@", key, obj]];
        }];
        NSUInteger insertLocation = [self.urlString rangeOfString:@"?"].location;
        if (insertLocation != NSNotFound) {
            NSMutableString *tempUrlString = [self.urlString mutableCopy];
            [tempUrlString insertString:restfulParamString atIndex:insertLocation];
            self.urlString = [tempUrlString copy];
        }
    }
    //append query string
    AEHttpRequestUserInfo *userInfo = [self configRequestUserInfo];
    if (userInfo) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [userInfo.infoAppendingAfterQueryString enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *appendParam = [NSString stringWithFormat:@"%@=%@", key, obj];
            [tempArray addObject:appendParam];
        }];
        NSMutableString *tempString = [NSMutableString stringWithString:self.urlString];
        [tempString appendString:[tempArray componentsJoinedByString:@"&"]];
        self.urlString = [NSString stringWithString:tempString];
    }
    //init request
    NSURL *url = [NSURL URLWithString:self.urlString];
    if (!url) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (!request) {
        return nil;
    }
    //timeout
    NSTimeInterval timeOut = [self configTimeoutSeconds];
    if (timeOut <= 0) {
        timeOut = 10;
    }
    request.timeoutInterval = timeOut;
    //method
    NSString *method = [[InterfaceManager sharedManager] getURLSendDataMethodWithAliasName:self.urlAliasName];
    if (method) {
        //以interface.plist为准
        request.HTTPMethod = method;
    } else {
        //如果没有配置interface，则按照config
        request.HTTPMethod = [self configHttpMethod];
    }
    //header
    request.allHTTPHeaderFields = userInfo.infoInHttpHeader;
    
    return [request copy];
}

- (void)logBeforeRequest {
    if ([self configDisplayDebugInfo]) {
        //输出请求内容
        NSLog(@"url:%@", self.urlString);
        NSLog(@"rest param:%@", self.restfulParam);
        NSLog(@"original param:%@", self.originalParam);
        NSLog(@"query userInfo:%@", [self configRequestUserInfo].infoAppendingAfterQueryString);
        NSLog(@"header userInfo:%@", [self configRequestUserInfo].infoInHttpHeader);
        NSLog(@"timeout:%f", [self configTimeoutSeconds]);
    }
}


@end
