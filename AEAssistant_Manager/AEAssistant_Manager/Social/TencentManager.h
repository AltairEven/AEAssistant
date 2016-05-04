//
//  TencentManager.h
//  KidsTC
//
//  Created by Altair on 11/16/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kTencentUrlScheme;
extern NSString *const kTencentAppKey;

@class TencentShareObject;


typedef enum {
    TencentShareSceneQQ = 0,
    TencentShareSceneQZone = 1
}TencentShareScene;

@interface TencentManager : NSObject

@property (nonatomic, readonly) BOOL isOnline;

+ (instancetype)sharedManager;

+ (BOOL)canShare;

+ (BOOL)canLogin;

- (BOOL)handleOpenURL:(NSURL *)url;

- (BOOL)sendLoginRequestWithSucceed:(void(^)(NSString *openId, NSString *accessToken))succeed failure:(void(^)(NSError *error))failure;

- (BOOL)sendShareRequestToScene:(TencentShareScene)scene
                     WithObject:(TencentShareObject *)object
                        succeed:(void(^)())succeed
                        failure:(void(^)(NSError *error))failure;

@end


typedef enum {
    TencentShareObjectTypeDefault,
    TencentShareObjectTypeImage,
    TencentShareObjectTypeWebPage
}TencentShareObjectType;


@interface TencentShareObject : NSObject

@property (nonatomic, assign) TencentShareObjectType type;

@property(nonatomic, copy) NSString* title; ///< 标题，最长128个字符

@property(nonatomic, copy) NSString* shareDescription; ///<简要描述，最长512个字符

+ (instancetype)shareObjectWithTitle:(NSString *)title shareDescription:(NSString *)description;

@end

@interface TencentImageShareObject : TencentShareObject

@property (nonatomic, strong) UIImage *image;///<分享的图片，必填，最大5M字节

@property(nonatomic, strong) UIImage *thumbImage;///<预览图像数据，最大1M字节

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                         shareDescription:(NSString *)description
                               shareImage:(UIImage *)image
                               thumbImage:(UIImage *)thumb;

@end


@interface TencentWebPageShareObject : TencentShareObject

@property (nonatomic, copy) NSString *pageUrlString;

@property(nonatomic, strong) UIImage *thumbImage;///<预览图像数据，最大1M字节

@property(nonatomic, copy) NSString *thumbImageUrlString;    ///<预览图像URL **预览图像数据与预览图像URL可二选一

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                           shareDescription:(NSString *)description
                              pageUrlString:(NSString *)urlString
                                 thumbImage:(UIImage *)thumb
                        thumbImageUrlString:(NSString *)thumbUrlString;

@end