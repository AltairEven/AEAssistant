//
//  KTCImageUploader.m
//  KidsTC
//
//  Created by 钱烨 on 8/31/15.
//  Copyright (c) 2015 KidsTC. All rights reserved.
//

#import "KTCImageUploader.h"
#import <AEAssistant_Network/AEAssistant_Network.h>
#import <AEAssistant_ToolBox/AEAssistant_ToolBox.h>

#define FILE_UPLOAD (@"IMAGE_UPLOAD")

static KTCImageUploader *sharedInstance = nil;

@interface KTCImageUploader ()

@property (nonatomic, strong) NSMutableArray *uploadClients;

@property (nonatomic, strong) NSMutableDictionary *uploadResultDic;

- (void)startUploadWithImage:(UIImage *)image splitCount:(NSUInteger)count viaHttpRequestClient:(HttpRequestClient *)client succeed:(void(^)(NSString *locateUrlString))succeed failure:(void(^)(NSError *error))failure;

- (NSString *)getUploadLocationWithResponse:(NSDictionary *)respData;

- (NSArray *)getUploadResultArray;

@end

@implementation KTCImageUploader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uploadClients = [[NSMutableArray alloc] init];
        self.uploadResultDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [[KTCImageUploader alloc] init];
    });
    return sharedInstance;
}

- (void)startUploadWithImagesArray:(NSArray *)imagesArray splitCount:(NSUInteger)count withSucceed:(void (^)(NSArray *))succeed failure:(void (^)(NSError *))failure {
    [self stopUpload];
    [self.uploadClients removeAllObjects];
    [self.uploadResultDic removeAllObjects];
    
    NSUInteger imageCount = [imagesArray count];
    
    for (NSUInteger index = 0; index < imageCount; index ++) {
        UIImage *image = [imagesArray objectAtIndex:index];
        HttpRequestClient *client = [HttpRequestClient clientWithUrlAliasName:FILE_UPLOAD];
        if (client) {
            [self.uploadClients addObject:client];
            __weak KTCImageUploader *weakSelf = self;
            [weakSelf startUploadWithImage:image splitCount:count viaHttpRequestClient:client succeed:^(NSString *locateUrlString) {
                if ([locateUrlString length] > 0) {
                    [weakSelf.uploadResultDic setObject:locateUrlString forKey:[NSNumber numberWithInteger:index]];
                    if ([weakSelf.uploadResultDic count] == imageCount && succeed) {
                        //上传完成
                        succeed([weakSelf getUploadResultArray]);
                    }
                } else {
                    [weakSelf stopUpload];
                    if (failure) {
                        NSError *error = [NSError errorWithDomain:@"Image upload" code:-100001 userInfo:[NSDictionary dictionaryWithObject:@"Response not valid." forKey:kErrMsgKey]];
                        failure(error);
                    }
                }
            } failure:^(NSError *error) {
                [weakSelf stopUpload];
                if (failure) {
                    failure(error);
                }
            }];
        }
    }
}

- (void)stopUpload {
    NSArray *clients = [NSArray arrayWithArray:self.uploadClients];
    for (HttpRequestClient *client in clients) {
        [client cancel];
    }
}

#pragma mark Private methods

- (void)startUploadWithImage:(UIImage *)image splitCount:(NSUInteger)count viaHttpRequestClient:(HttpRequestClient *)client succeed:(void (^)(NSString *))succeed failure:(void (^)(NSError *))failure {
    NSData *data = UIImageJPEGRepresentation(image, 0.0);
    
    if (!data) {
        return;
    }
    
    NSString *dataString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:dataString, @"fileStr", @"JPEG", @"suffix", [NSNumber numberWithInteger:count], @"count", nil];
    __weak KTCImageUploader *weakSelf = self;
    [client startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
        NSString *location = [weakSelf getUploadLocationWithResponse:responseData];
        if (succeed) {
            succeed(location);
        }
    } failure:^(HttpRequestClient *client, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSString *)getUploadLocationWithResponse:(NSDictionary *)respData {
    NSString *data = [respData objectForKey:@"data"];
    if (!data || ![data isKindOfClass:[NSString class]]) {
        return nil;
    }
    return data;
}

- (NSArray *)getUploadResultArray {
    if ([self.uploadResultDic count] == 0) {
        return nil;
    }
    NSArray *allKeys = [self.uploadResultDic allKeys];
    allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *key1 = obj1;
        NSNumber *key2 = obj2;
        return [key1 compare:key2];
    }];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (NSNumber *key in allKeys) {
        NSString *result = [self.uploadResultDic objectForKey:key];
        [tempArray addObject:result];
    }
    return [NSArray arrayWithArray:tempArray];
}


@end
