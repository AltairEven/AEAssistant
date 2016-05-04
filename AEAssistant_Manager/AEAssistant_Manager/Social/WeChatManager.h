//
//  WeChatManager.h
//  KidsTC
//
//  Created by Altair on 11/16/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kWeChatUrlScheme;
extern NSString *const kWeChatAppKey;

@class WeChatShareObject;
@class KTCWeChatPaymentInfo;

typedef enum {
    WechatShareSceneSession = 0,
    WechatShareSceneTimeline = 1
}WechatShareScene;

@interface WeChatManager : NSObject

@property (nonatomic, readonly) BOOL isOnline;

+ (instancetype)sharedManager;

+ (BOOL)canShare;

+ (BOOL)canLogin;

//程序启动时调用
- (BOOL)getOnline;

- (BOOL)handleOpenURL:(NSURL *)url;

- (BOOL)sendLoginRequestWithSucceed:(void(^)(NSString *openId, NSString *accessToken))succeed failure:(void(^)(NSError *error))failure;

- (BOOL)sendShareRequestToScene:(WechatShareScene)scene
                     WithObject:(WeChatShareObject *)object
                        succeed:(void(^)())succeed
                        failure:(void(^)(NSError *error))failure;

- (BOOL)sendPayRequestWithInfo:(KTCWeChatPaymentInfo *)info
                       succeed:(void(^)())succeed
                       failure:(void(^)(NSError *error))failure;

@end


typedef enum {
    WeChatShareObjectTypeDefault,
    WeChatShareObjectTypeImage,
    WeChatShareObjectTypeWebPage
}WeChatShareObjectType;


@interface WeChatShareObject : NSObject

@property (nonatomic, assign) WeChatShareObjectType type;

/** 标题
 * @note 长度不能超过512字节
 */
@property (nonatomic, copy) NSString *title;
/** 描述内容
 * @note 长度不能超过1K
 */
@property (nonatomic, copy) NSString *shareDescription;
/** 缩略图数据
 * @note 大小不能超过32K
 */
@property (nonatomic, strong) UIImage *thumbImage;
/**
 * @note 长度不能超过64字节
 */
@property (nonatomic, copy) NSString *mediaTagName;
/**
 *
 */
@property (nonatomic, copy) NSString *messageExt;

@property (nonatomic, copy) NSString *messageAction;

+ (instancetype)shareObjectWithTitle:(NSString *)title description:(NSString *)des thumbImage:(UIImage *)thumb;

@end

@interface WeChatImageShareObject : WeChatShareObject

/** 图片真实数据内容
 * @note 大小不能超过10M
 */
@property (nonatomic, strong) UIImage *image;
/** 图片url
 * @note 长度不能超过10K
 */
@property (nonatomic, copy) NSString *imageUrlString;

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                              description:(NSString *)des
                               thumbImage:(UIImage *)thumb
                               shareImage:(UIImage *)image
                      shareImageUrlString:(NSString *)urlString;

@end

@interface WeChatWebPageShareObject : WeChatShareObject

/** 网页的url地址
 * @note 不能为空且长度不能超过10K
 */
@property (nonatomic, copy) NSString *webPageUrlString;

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                                description:(NSString *)des
                                 thumbImage:(UIImage *)thumb
                           webPageUrlString:(NSString *)urlString;

@end