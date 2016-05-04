//
//  WeiboManager.h
//  KidsTC
//
//  Created by Altair on 11/16/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kWeiboUrlScheme;
extern NSString *const kWeiboAppKey;

@class WeiboShareObject;

@interface WeiboManager : NSObject

@property (nonatomic, readonly) BOOL isOnline;

+ (instancetype)sharedManager;

+ (BOOL)canShare;

+ (BOOL)canLogin;

- (BOOL)handleOpenURL:(NSURL *)url;

- (BOOL)sendLoginRequestWithSucceed:(void(^)(NSString *openId, NSString *accessToken))succeed failure:(void(^)(NSError *error))failure;

- (BOOL)sendShareRequestWithObject:(WeiboShareObject *)object succeed:(void(^)())succeed failure:(void(^)(NSError *error))failure;

@end


typedef enum {
    WeiboShareObjectTypeDefault,
    WeiboShareObjectTypeImage,
    WeiboShareObjectTypeWebPage
}WeiboShareObjectType;

@interface WeiboShareObject : NSObject

@property (nonatomic, assign) WeiboShareObjectType type;

@property (nonatomic, copy) NSString *followingContent;

+ (instancetype)shareObjectWithFollowingContent:(NSString *)content;

@end

@interface WeiboImageShareObject : WeiboShareObject

@property (nonatomic, strong) UIImage *image;

+ (instancetype)imageShareObjectWithFollowingContent:(NSString *)content image:(UIImage *)image;

@end

@interface WeiboWebPageShareObject : WeiboShareObject

@property (nonatomic, copy) NSString *identifier; //必填

@property (nonatomic, copy) NSString *title; //必填

@property (nonatomic, copy) NSString *pageDescription;

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, copy) NSString *scheme;

@property (nonatomic, copy) NSString *webPageUrlString; //必填

+ (instancetype)webPageShareObjectWithFollowingContent:(NSString *)content
                                            identifier:(NSString *)identifier
                                                 title:(NSString *)title
                                             urlString:(NSString *)urlString;

@end