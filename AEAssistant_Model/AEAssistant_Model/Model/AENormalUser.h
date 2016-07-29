//
//  AENormalUser.h
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AEAssistant_Network/AEAssistant_Network.h>

@interface AENormalUser : NSObject

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, strong, readonly) NSString *uid;

@property (nonatomic, strong, readonly) NSString *skey;

@property (nonatomic, readonly) BOOL hasLogin;

@property (nonatomic, strong) AEHttpRequestHandler *logoutRequest;

@property (nonatomic, strong) AEHttpRequestHandler *checkLoginRequest;

+ (instancetype)currentUser;

- (void)setLocalSave;

- (void)getLocalSave;

- (void)clearLoginInfo;

- (void)updateUid:(NSString *)uid skey:(NSString *)skey;

/**
 *  检查登录状态
 *
 *  @param param  请求参数
 *  @param result 返回结果
 */
- (void)checkLoginStatusWithParam:(NSDictionary *)param fromServerWithResult:(void(^)(BOOL hasLogin, NSDictionary *userInfo, NSError *error))result;
/**
 *  登出
 *
 *  @param manually 是否手动登出，是则发送登出请求，否则直接清空本地用户登录信息
 *  @param param    请求参数
 *  @param success  登出结果
 *  @param failure  登出失败结果
 */
- (void)logoutManually:(BOOL)manually withParam:(NSDictionary *)param success:(void(^)(NSDictionary *userInfo))success failure:(void(^)(NSError *error))failure;

@end
