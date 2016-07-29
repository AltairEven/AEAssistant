//
//  AFHttpRequestWrapper.h
//  AEAssistant_Network
//
//  Created by Altair on 7/25/16.
//  Copyright © 2016 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AEAssistant_Category/AEAssistant_Category.h>
#import <AEAssistant_ToolBox/AEAssistant_ToolBox.h>

@interface AFHttpRequestWrapper : NSObject


+ (NSURLSessionTask *)requestWithUrlRequest:(NSURLRequest *)urlRequest
                             stringEncoding:(NSStringEncoding)encoding
                                  parameter:(NSDictionary *)parameter
                                    success:(void (^)(NSURLRequest *request, id responseObject))success
                                    failure:(void (^)(NSURLRequest *request, NSError *error))failure;


+ (NSURLSessionTask *)requestWithUrlRequest:(NSURLRequest *)urlRequest
                             stringEncoding:(NSStringEncoding)encoding
                                  parameter:(NSDictionary *)parameter
                  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                    success:(void (^)(NSURLRequest *request, id responseObject))success
                                    failure:(void (^)(NSURLRequest *request, NSError *error))failure;

@end
