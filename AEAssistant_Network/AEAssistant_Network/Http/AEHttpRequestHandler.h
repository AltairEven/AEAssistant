//
//  AEHttpRequestHandler.h
//  AEAssistant_Network
//
//  Created by Altair on 7/25/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHttpRequestWrapper.h"
#import "AEHttpRequestConfiguration.h"

extern NSString *const kHandledServerResponsedLogoutNotification;

@interface AEHttpRequestHandler : NSObject

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *restfulParam;

@property (nonatomic, strong) NSDictionary *originalParam;

@property (nonatomic, copy) NSString *urlAliasName;

@property (nonatomic, readonly) NSTimeInterval requestDurationTime;

@property (nonatomic, strong) AEHttpRequestConfiguration *requestConfiguration;

+ (void)setCommonRequestConfiguration:(AEHttpRequestConfiguration *)config;

+ (instancetype)clientWithUrlString:(NSString *)url;

- (instancetype)initWithUrlString:(NSString*)url;

+ (instancetype)clientWithUrlAliasName:(NSString *)name;

- (instancetype)initWithUrlAliasName:(NSString *)name;

- (void)startHttpRequestWithSuccess:(void (^)(AEHttpRequestHandler *handler, NSDictionary *responseData))success
                            failure:(void (^)(AEHttpRequestHandler *handler, NSError *error))failure;

- (void)startHttpRequestWithParameter:(NSDictionary *)param
                              success:(void (^)(AEHttpRequestHandler *handler, NSDictionary *responseData))success
                              failure:(void (^)(AEHttpRequestHandler *handler, NSError *error))failure;

- (void)startHttpRequestWithRestParameter:(NSDictionary *)rParam
                        originalParameter:(NSDictionary *)oParam
                                  success:(void (^)(AEHttpRequestHandler *handler, NSDictionary *responseData))success
                                  failure:(void (^)(AEHttpRequestHandler *handler, NSError *error))failure;

- (void)uploadImageWithData:(NSData *)data
                    success:(void (^)(AEHttpRequestHandler *handler, NSDictionary *responseData))success
                    failure:(void (^)(AEHttpRequestHandler *handler, NSError *error))failure;

- (void)downloadImageWithSuccess:(void (^)(AEHttpRequestHandler *handler, UIImage *image))success
                         failure:(void (^)(AEHttpRequestHandler *handler, NSError *error))failure;

- (void)cancelRequest;

@end
