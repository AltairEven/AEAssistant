 //
//  AFHTTPClientV2.m
//  PAFNetClient
//
//  Created by michael on 15-2-28.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "AFHTTPClientV2.h"


@interface AFHTTPClientV2 ()

@end

@implementation AFHTTPClientV2

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)requestWithBaseURLStr:(NSString *)URLString
                                   params:(NSDictionary *)params
                               httpMethod:(HttpRequestMethod)httpMethod
                           stringEncoding:(NSStringEncoding)encoding
                                  timeout:(NSTimeInterval)seconds
                                  success:(void (^)(AFHTTPClientV2 *request, id responseObject))success
                                  failure:(void (^)(AFHTTPClientV2 *request, NSError *error))failure;
{
    [self requestWithBaseURLStr:URLString params:params httpMethod:httpMethod userInfo:self.userInfo stringEncoding:encoding timeout:seconds success:success failure:failure];
}

- (void)requestWithBaseURLStr:(NSString *)URLString
                                   params:(NSDictionary *)params
                               httpMethod:(HttpRequestMethod)httpMethod
                                 userInfo:(NSDictionary*)userInfo
                           stringEncoding:(NSStringEncoding)encoding
                                  timeout:(NSTimeInterval)seconds
                                  success:(void (^)(AFHTTPClientV2 *request, id responseObject))success
                                  failure:(void (^)(AFHTTPClientV2 *request, NSError *error))failure;
{
    self.userInfo = userInfo;
    self.timeoutSeconds = seconds;
    self.stringEncoding = encoding;
    
    if (userInfo) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *appendParam = [NSString stringWithFormat:@"%@=%@", key, obj];
            [tempArray addObject:appendParam];
        }];
        NSMutableString *tempString = [NSMutableString stringWithString:URLString];
        [tempString appendString:[tempArray componentsJoinedByString:@"&"]];
        URLString = [NSString stringWithString:tempString];
    }
    
    
    __weak AFHTTPClientV2 *weakSelf = self;
    AFHTTPSessionManager   *httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    
    NSURLRequest *request = nil;
    if (httpMethod == HttpRequestMethodGET) {
        NSError *error = nil;
        request = [httpClient.requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:params error:&error];
        if (error && failure) {
            failure(weakSelf, error);
        }
    }else if (httpMethod == HttpRequestMethodPOST){
        NSError *error = nil;
        request = [httpClient.requestSerializer requestWithMethod:@"POST" URLString:URLString parameters:params error:&error];
        if (error && failure) {
            failure(weakSelf, error);
        }
    }else if (httpMethod == HttpRequestMethodDELETE){
        NSError *error = nil;
        request = [httpClient.requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:params error:&error];
        if (error && failure) {
            failure(weakSelf, error);
        }
    }
    httpClient.requestSerializer.timeoutInterval = weakSelf.timeoutSeconds;
    httpClient.requestSerializer.stringEncoding = weakSelf.stringEncoding;
    for (NSString *key in [self.userInfo allKeys]) {
        NSString *value = [self.userInfo objectForKey:key];
        if (value && [value isKindOfClass:[NSString class]]) {
            [httpClient.requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/xml", @"text/html", @"text/plain",nil];
    [(AFJSONResponseSerializer *)httpClient.responseSerializer setRemovesKeysWithNullValues:YES];
    
    _currentSessionTask = [httpClient dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
        } else {
            if (success) {
                success(weakSelf, responseObject);
            }
        }
    }];
    [_currentSessionTask resume];
}

- (void)requestWithBaseURLStr:(NSString *)URLString
                               parameters:(id)parameters
                                 userInfo:(NSDictionary*)userInfo
                constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                  success:(void (^)(AFHTTPClientV2 *request, id responseObject))success
                                  failure:(void (^)(AFHTTPClientV2 *request, NSError *error))failure
{
    self.userInfo = userInfo;
    
    if (userInfo) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [userInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *appendParam = [NSString stringWithFormat:@"%@=%@", key, obj];
            [tempArray addObject:appendParam];
        }];
        NSMutableString *tempString = [NSMutableString stringWithString:URLString];
        [tempString appendString:[tempArray componentsJoinedByString:@"&"]];
        URLString = [NSString stringWithString:tempString];
    }
    
    __weak AFHTTPClientV2 *weakSelf = self;
    AFHTTPSessionManager   *httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    NSError *error = nil;
    NSURLRequest *request = [httpClient.requestSerializer requestWithMethod:@"POST" URLString:URLString parameters:parameters error:&error];
    if (error && failure) {
        failure(weakSelf, error);
    }
    for (NSString *key in [self.userInfo allKeys]) {
        NSString *value = [self.userInfo objectForKey:key];
        if (value && [value isKindOfClass:[NSString class]]) {
            [httpClient.requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/xml", @"text/html", @"text/plain",nil];
    [(AFJSONResponseSerializer *)httpClient.responseSerializer setRemovesKeysWithNullValues:YES];
    
    _currentSessionTask = [httpClient dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
        } else {
            if (success) {
                success(weakSelf, responseObject);
            }
        }
    }];
    [_currentSessionTask resume];
}

- (void)requestWithBaseURLStr:(NSString *)URLString
                               parameters:(id)parameters
                constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                  success:(void (^)(AFHTTPClientV2 *request, id responseObject))success
                                  failure:(void (^)(AFHTTPClientV2 *request, NSError *error))failure
{
    [self requestWithBaseURLStr:URLString parameters:parameters userInfo:nil constructingBodyWithBlock:block success:success failure:failure];
}

- (void)downloadImageWithURLStr:(NSString *)URLString success:(void (^)(AFHTTPClientV2 *, id))success failure:(void (^)(AFHTTPClientV2 *, NSError *))failure {
    __weak AFHTTPClientV2 *weakSelf = self;
    AFHTTPSessionManager   *httpClient = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    NSError *error = nil;
    NSURLRequest *request = [httpClient.requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:nil error:&error];
    if (error && failure) {
        failure(weakSelf, error);
    }
    for (NSString *key in [self.userInfo allKeys]) {
        NSString *value = [self.userInfo objectForKey:key];
        if (value && [value isKindOfClass:[NSString class]]) {
            [httpClient.requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    httpClient.responseSerializer = [AFImageResponseSerializer serializer];
    
    _currentSessionTask = [httpClient dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(weakSelf, error);
            }
        } else {
            if (success) {
                success(weakSelf, responseObject);
            }
        }
    }];
    [_currentSessionTask resume];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    AFHTTPClientV2  *clientV2 = [[self class] init];
    [clientV2 setUserInfo:[[self userInfo] copyWithZone:zone]];
    return clientV2;
}


- (void)cancel {
    if (_currentSessionTask) {
        [_currentSessionTask cancel];
        _currentSessionTask = nil;
    }
}

@end
