//
//  HttpRequestClient.h
//  ICSON
//
//  Created by 钱烨 on 3/5/15.
//  Copyright (c) 2015 肖晓春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClientV2.h"

extern NSString *const kServerResponsedLogoutNotification;

typedef void(^ NetworkErrorBlcok) (NSError *error);

@interface HttpRequestClient : NSObject

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) NSDictionary *parameter;

@property (nonatomic, copy) NSString *urlAliasName;

@property (nonatomic, assign) NSStringEncoding stringEncoding;

@property (nonatomic, assign) NSTimeInterval timeoutSeconds;

@property (nonatomic, assign) HttpRequestMethod methodType;

@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, assign) NSTimeInterval requestDurationTime;

@property (nonatomic, strong) NetworkErrorBlcok errorBlock;

@property (nonatomic, assign) BOOL displayDebugInfo;

@property (nonatomic, assign) NSInteger logoutErrorCode;

+ (void)setCommonUserInfo:(NSDictionary *)info;

+ (NSDictionary *)commonUserInfo;

+ (instancetype)defaultClient;

+ (instancetype)clientWithUrlString:(NSString *)url;

- (instancetype)initWithUrlString:(NSString*)url;

+ (instancetype)clientWithUrlAliasName:(NSString *)name;

- (instancetype)initWithUrlAliasName:(NSString *)name;

+ (instancetype)clientWithUrlString:(NSString *)url andParameter:(NSDictionary *)param;

- (instancetype)initWithUrlString:(NSString*)url andParameter:(NSDictionary *)param;

+ (instancetype)clientWithUrlAliasName:(NSString *)name andParameter:(NSDictionary *)param;

- (instancetype)initWithUrlAliasName:(NSString *)name andParameter:(NSDictionary *)param;

+ (instancetype)clientWithUrlString:(NSString *)url parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding;

- (instancetype)initWithUrlString:(NSString *)url parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding;

+ (instancetype)clientWithUrlAliasName:(NSString *)name parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding;

- (instancetype)initWithUrlAliasName:(NSString *)name parameter:(NSDictionary *)param andStringEncoding:(NSStringEncoding)encoding;

- (void)setUpHttpHeaderWithValue:(NSString *)value forKey:(NSString *)key;

- (void)startHttpRequestWithSuccess:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                            failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)startHttpRequestWithParameter:(NSDictionary *)param
                              success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                              failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)startHttpRequestWithUrlString:(NSString *)url
                            parameter:(NSDictionary *)param
                              success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                              failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)startHttpRequestWithUrlAliasName:(NSString *)name
                               parameter:(NSDictionary *)param
                                 success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                                 failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)startHttpRequestWithUrlString:(NSString *)url
                            parameter:(NSDictionary *)param
                       stringEncoding:(NSStringEncoding)encoding
                              success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                              failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)startHttpRequestWithUrlAliasName:(NSString *)name
                               parameter:(NSDictionary *)param
                          stringEncoding:(NSStringEncoding)encoding
                                 success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                                 failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)uploadImageWithData:(NSData *)data
                       success:(void (^)(HttpRequestClient *client, NSDictionary *responseData))success
                       failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)downloadImageWithSuccess:(void (^)(HttpRequestClient *client, UIImage *image))success
                         failure:(void (^)(HttpRequestClient *client, NSError *error))failure;

- (void)cancel;

@end
