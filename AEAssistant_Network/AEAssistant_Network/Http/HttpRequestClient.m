//
//  HttpRequestClient.m
//  ICSON
//
//  Created by 钱烨 on 3/5/15.
//  Copyright (c) 2015 肖晓春. All rights reserved.
//

#import "HttpRequestClient.h"
#import "AEReachability.h"
#import "AEHttpCookieManager.h"
#import "InterfaceManager.h"
#import <AEAssistant_ToolBox/AEAssistant_ToolBox.h>

@interface HttpRequestClient ()

@property (nonatomic, strong) NSDate *startTime;

@property (nonatomic, strong) NSDate *endTime;

@property (nonnull, strong) AFHTTPClientV2 *httpClient;

@end

@implementation HttpRequestClient
@synthesize urlString = _urlString, urlAliasName = _urlAliasName;
@synthesize stringEncoding, timeoutSeconds;
@synthesize methodType = _methodType, requestDurationTime = _requestDurationTime;

- (instancetype)init
{
    self = [super init];
    if (self) {
//        //默认GBK
//        self.stringEncoding = CFStringConvertEncodingToNSStringEncoding ( kCFStringEncodingGB_18030_2000 );
        //默认UTF-8
        self.stringEncoding = NSUTF8StringEncoding;
        //默认10秒超时
        self.timeoutSeconds = 10;
        //默认GET
        _methodType = HttpRequestMethodGET;
        //请求时间置零
        _requestDurationTime = 0;
        //初始化请求
        _httpClient = [[AFHTTPClientV2 alloc] init];
    }
    return self;
}



- (NSTimeInterval)requestDurationTime
{
    NSTimeInterval duration = [self.endTime timeIntervalSinceDate:self.startTime];
    _requestDurationTime = duration;
    
    return _requestDurationTime;
}



- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
}



- (void)setUrlAliasName:(NSString *)urlAliasName
{
    _urlAliasName = urlAliasName;
    self.urlString = [[InterfaceManager sharedManager] getURLStringWithAliasName:urlAliasName];
    _methodType = (HttpRequestMethod)[[InterfaceManager sharedManager] getURLSendDataMethodWithAliasName:urlAliasName];
}


+ (instancetype)defaultClient
{
    return [[HttpRequestClient alloc] init];
}


+ (instancetype)clientWithUrlString:(NSString *)url
{
    return [[HttpRequestClient alloc] initWithUrlString:url];
}


- (instancetype)initWithUrlString:(NSString*)url
{
    self = [self init];
    if (self) {
        self.urlString = url;
    }
    return self;
}


+ (instancetype)clientWithUrlAliasName:(NSString *)name
{
    return [[HttpRequestClient alloc] initWithUrlAliasName:name];
}



- (instancetype)initWithUrlAliasName:(NSString *)name
{
    self = [self init];
    if (self) {
        self.urlAliasName = name;
    }
    return self;
}



+ (instancetype)clientWithUrlString:(NSString *)url andParameter:(NSDictionary *)param
{
    return [[HttpRequestClient alloc] initWithUrlAliasName:url andParameter:param];
}



- (instancetype)initWithUrlString:(NSString*)url andParameter:(NSDictionary *)param
{
    self = [self init];
    if (self) {
        self.urlString = url;
        self.parameter = param;
    }
    return self;
}



+ (instancetype)clientWithUrlAliasName:(NSString *)name andParameter:(NSDictionary *)param
{
    return [[HttpRequestClient alloc] initWithUrlAliasName:name andParameter:param];
}



- (instancetype)initWithUrlAliasName:(NSString *)name andParameter:(NSDictionary *)param
{
    self = [self init];
    if (self) {
        self.urlAliasName = name;
        self.parameter = param;
    }
    return self;
}



+ (instancetype)clientWithUrlString:(NSString *)url parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding
{
    return [[HttpRequestClient alloc] initWithUrlString:url parameter:param andStringEncoding:encoding];
}



- (instancetype)initWithUrlString:(NSString *)url parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding
{
    self = [self init];
    if (self) {
        self.urlString = url;
        self.parameter = param;
        self.stringEncoding = encoding;
    }
    return self;
}




+ (instancetype)clientWithUrlAliasName:(NSString *)name parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding
{
    return [[HttpRequestClient alloc] initWithUrlAliasName:name parameter:param andStringEncoding:encoding];
}



- (instancetype)initWithUrlAliasName:(NSString *)name parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding
{
    self = [self init];
    if (self) {
        self.urlAliasName = name;
        self.parameter = param;
        self.stringEncoding = encoding;
    }
    return self;
}


- (void)setUpHttpHeaderWithValue:(NSString *)value forKey:(NSString *)key {
    NSMutableDictionary *info = [_httpClient.userInfo mutableCopy];
    if (!info) {
        info = [[NSMutableDictionary alloc] init];
    }
    [info setObject:value forKey:key];
    _httpClient.userInfo = [NSDictionary dictionaryWithDictionary:info];
}



- (void)startHttpRequestWithSuccess:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                            failure:(void (^)(HttpRequestClient *client, NSError *error))failure;
{
    __weak HttpRequestClient *weakSelf = self;
    
    if (![[AEReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        if (failure) {
            failure(weakSelf, error);
        }
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
        return;
    }
    
    self.startTime = [NSDate date];
    
    //输出请求内容
    NSLog(@"%@", self.urlString);
    NSLog(@"%@", self.parameter);
    
    [_httpClient requestWithBaseURLStr:weakSelf.urlString params:weakSelf.parameter httpMethod:weakSelf.methodType stringEncoding:weakSelf.stringEncoding timeout:weakSelf.timeoutSeconds success:^(AFHTTPClientV2 *request, id responseObject) {
        
        weakSelf.endTime = [NSDate date];
        
        if (responseObject == nil) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject nil." code:-301 userInfo:nil];
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        if (responseObject == NULL) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject  NULL." code:-302 userInfo:nil];
            if (failure) {
                failure(weakSelf, error);
            }
            return ;
        }
        NSInteger errorNo = [[responseObject objectForKey:@"code"] integerValue];
        if (errorNo <= 0) {
            NSError *error = nil;
            if ([responseObject objectForKey:@"msg"]) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[responseObject objectForKey:@"msg"] forKey:kErrMsgKey];
                error = [NSError errorWithDomain:@"Http request client." code:errorNo userInfo:userInfo];
            }
            if (failure) {
                failure(weakSelf, error);
            }
            
            return ;
        }
        /*
        if([responseObject objectForKey:@"data"] == nil){
            NSError *error = [NSError errorWithDomain:@"Http request client." code:-303 userInfo:@{kErrMsgKey:@"responseObject data nil."}];
            failure(weakSelf, error);
            return ;
        }
        if([responseObject objectForKey:@"data"] == NULL){
            NSError *error = [NSError errorWithDomain:@"Http request client." code:-304 userInfo:@{kErrMsgKey:@"responseObject data NULL."}];
            failure(weakSelf, error);
            return ;
        }
        */
        if (success) {
            success(weakSelf, responseObject);
        }
        
    } failure:^(AFHTTPClientV2 *request, NSError *error) {
        
        weakSelf.endTime = [NSDate date];
        if (failure) {
            failure(weakSelf, error);
            if (weakSelf.errorBlock) {
                weakSelf.errorBlock(error);
            }
        }
        
    }];
    
}



- (void)startHttpRequestWithParameter:(NSDictionary *)param
                              success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                              failure:(void (^)(HttpRequestClient *client, NSError *error))failure
{
    self.parameter = param;
    
    [self startHttpRequestWithSuccess:success failure:failure];
}



- (void)startHttpRequestWithUrlString:(NSString *)url
                            parameter:(NSDictionary *)param
                              success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                              failure:(void (^)(HttpRequestClient *client, NSError *error))failure
{
    if (!url || [url isEqualToString:@""]) {
        return;
    }
    
    self.urlString = url;
    self.parameter = param;
    
    [self startHttpRequestWithSuccess:success failure:failure];
}




- (void)startHttpRequestWithUrlAliasName:(NSString *)name
                               parameter:(NSDictionary *)param
                                 success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                                 failure:(void (^)(HttpRequestClient *client, NSError *error))failure
{
    if (!name || [name isEqualToString:@""]) {
        return;
    }
    
    self.urlAliasName = name;
    self.parameter = param;
    
    [self startHttpRequestWithSuccess:success failure:failure];
}




- (void)startHttpRequestWithUrlString:(NSString *)url
                            parameter:(NSDictionary *)param
                       stringEncoding:(NSStringEncoding)encoding
                              success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                              failure:(void (^)(HttpRequestClient *client, NSError *error))failure
{
    if (!url || [url isEqualToString:@""]) {
        return;
    }
    
    self.urlString = url;
    self.parameter = param;
    self.stringEncoding = encoding;
    
    [self startHttpRequestWithSuccess:success failure:failure];
}




- (void)startHttpRequestWithUrlAliasName:(NSString *)name
                               parameter:(NSDictionary *)param
                          stringEncoding:(NSStringEncoding)encoding
                                 success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                                 failure:(void (^)(HttpRequestClient *client, NSError *error))failure
{
    if (!name || [name isEqualToString:@""]) {
        return;
    }
    
    self.urlAliasName = name;
    self.parameter = param;
    self.stringEncoding = encoding;
    
    [self startHttpRequestWithSuccess:success failure:failure];
}

- (void)uploadImageWithData:(NSData *)data success:(void (^)(HttpRequestClient *, NSDictionary *))success failure:(void (^)(HttpRequestClient *, NSError *))failure {
    if (!data) {
        return;
    }
    __weak HttpRequestClient *weakSelf = self;
    
    if (![[AEReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        failure(weakSelf, error);
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        failure(weakSelf, error);
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
        return;
    }
    
    self.startTime = [NSDate date];
    
    [_httpClient requestWithBaseURLStr:weakSelf.urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:data name:@"commentImage.jpg"];
    } success:^(AFHTTPClientV2 *request, id responseObject) {
        
        weakSelf.endTime = [NSDate date];
        
        if (responseObject == nil) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject nil." code:-301 userInfo:nil];
            failure(weakSelf, error);
            return ;
        }
        if (responseObject == NULL) {
            NSError *error = [NSError errorWithDomain:@"Http request client. ResponseObject  NULL." code:-302 userInfo:nil];
            failure(weakSelf, error);
            return ;
        }
        NSInteger errorNo = [[responseObject objectForKey:@"errno"] integerValue];
        if (errorNo != 0) {
            NSError *error = [NSError errorWithDomain:@"Http request client." code:errorNo userInfo:responseObject];
            failure(weakSelf, error);
            
            return ;
        }
        /*
         if([responseObject objectForKey:@"data"] == nil){
         NSError *error = [NSError errorWithDomain:@"Http request client." code:-303 userInfo:@{kErrMsgKey:@"responseObject data nil."}];
         failure(weakSelf, error);
         return ;
         }
         if([responseObject objectForKey:@"data"] == NULL){
         NSError *error = [NSError errorWithDomain:@"Http request client." code:-304 userInfo:@{kErrMsgKey:@"responseObject data NULL."}];
         failure(weakSelf, error);
         return ;
         }
         */
        
        success(weakSelf, responseObject);
    } failure:^(AFHTTPClientV2 *request, NSError *error) {
        weakSelf.endTime = [NSDate date];
        failure(weakSelf, error);
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
    }];
}

- (void)downloadImageWithSuccess:(void (^)(HttpRequestClient *, UIImage *))success failure:(void (^)(HttpRequestClient *, NSError *))failure {
    __weak HttpRequestClient *weakSelf = self;
    
    if (![[AEReachability sharedInstance] isNetworkStatusOK]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Network status not ok." code:-1 userInfo:nil];
        failure(weakSelf, error);
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
        return;
    }
    if (!self.urlString || [self.urlString isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"Http request client. Request content not valid" code:-2 userInfo:nil];
        failure(weakSelf, error);
        if (weakSelf.errorBlock) {
            weakSelf.errorBlock(error);
        }
        return;
    }
    
    self.startTime = [NSDate date];
    [_httpClient downloadImageWithURLStr:self.urlString success:^(AFHTTPClientV2 *request, id responseObject) {
        if (success) {
            success(weakSelf, responseObject);
        }
    } failure:^(AFHTTPClientV2 *request, NSError *error) {
        if (failure) {
            failure(weakSelf, error);
        }
    }];
}


- (void)cancel {
    if (_httpClient) {
        [_httpClient cancel];
    }
}


@end
