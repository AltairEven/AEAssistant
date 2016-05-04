//
//  WeiboManager.m
//  KidsTC
//
//  Created by Altair on 11/16/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "WeiboManager.h"
#import <AEAssistant_ThirdParty/AEAssistant_ThirdParty.h>

NSString *const kWeiboUrlScheme = @"wb2837514135";
NSString *const kWeiboAppKey = @"2837514135";
NSString *const kWeiboRedirectURL = @"https://api.weibo.com/oauth2/default.html";


typedef void (^WeiboLoginSuccessBlock)(NSString *, NSString *);
typedef void (^WeiboLoginFailureBlock)(NSError *);

typedef void (^WeiboShareSuccessBlock)();
typedef void (^WeiboShareFailureBlock)(NSError *);

static WeiboManager *_sharedInstance = nil;

@interface WeiboManager () <WeiboSDKDelegate>

@property (nonatomic, strong) WeiboLoginSuccessBlock loginSuccessBlock;

@property (nonatomic, strong) WeiboLoginFailureBlock loginFailureBlock;

@property (nonatomic, strong) WeiboShareSuccessBlock shareSuccessBlock;

@property (nonatomic, strong) WeiboShareFailureBlock shareFailureBlock;

@property (nonatomic, strong) NSString *token;

+ (WBMessageObject *)messageObjectFromWeiboShareObject:(WeiboShareObject *)shareObject;

+ (WBAuthorizeRequest *)weiboAuthRequest;

+ (NSString *)errorMessageWithStatusCode:(WeiboSDKResponseStatusCode)code;

- (void)handleAuthResp:(WBAuthorizeResponse *)resp;

- (void)handleShareResp:(WBSendMessageToWeiboResponse *)resp;

@end

@implementation WeiboManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [WeiboSDK enableDebugMode:YES];
        _isOnline = [WeiboSDK registerApp:kWeiboAppKey];
        if (![WeiboSDK isWeiboAppInstalled]) {
            _isOnline = NO;
        }
    }
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedInstance = [[WeiboManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        [self handleAuthResp:(WBAuthorizeResponse *)response];
        return;
    }
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        [self handleShareResp:(WBSendMessageToWeiboResponse *)response];
        return;
    }
}

#pragma mark Private methods


+ (WBMessageObject *)messageObjectFromWeiboShareObject:(WeiboShareObject *)shareObject {
    if (!shareObject || [shareObject.followingContent length] >= 140) {
        return nil;
    }
    WBMessageObject *messageObj = [WBMessageObject message];
    
    switch (shareObject.type) {
        case WeiboShareObjectTypeDefault:
        {
            [messageObj setText:shareObject.followingContent];
        }
            break;
        case WeiboShareObjectTypeImage:
        {
            WeiboImageShareObject *imageShareObj = (WeiboImageShareObject *)shareObject;
            messageObj.text = imageShareObj.followingContent;
            
            if (imageShareObj.image) {
                NSUInteger byteCount = [GToolUtil byteCountOfImage:imageShareObj.image];
                if (byteCount >= 32 * 1024 * 8) {
                    return nil;
                }
                
                WBImageObject *imageObj = [WBImageObject object];
                [imageObj setImageData:UIImageJPEGRepresentation(imageShareObj.image, 0)];
                [messageObj setImageObject:imageObj];
            }
        }
            break;
        case WeiboShareObjectTypeWebPage:
        {
            WeiboWebPageShareObject *webShareObj = (WeiboWebPageShareObject *)shareObject;
            messageObj.text = webShareObj.followingContent;
            
            WBWebpageObject *webPageObj = [WBWebpageObject object];
            webPageObj.objectID = webShareObj.identifier;
            webPageObj.title = webShareObj.title;
            webPageObj.description = webShareObj.pageDescription;
            if (webShareObj.thumbnailImage) {
                webPageObj.thumbnailData = UIImageJPEGRepresentation(webShareObj.thumbnailImage, 0);
            }
            webPageObj.scheme = webShareObj.scheme;
            webPageObj.webpageUrl = webShareObj.webPageUrlString;
            
            messageObj.mediaObject = webPageObj;
        }
            break;
        default:
            break;
    }
    return messageObj;
}

+ (WBAuthorizeRequest *)weiboAuthRequest {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectURL;
    request.scope = @"all";
    request.shouldShowWebViewForAuthIfCannotSSO = YES;
    
    return request;
}


+ (NSString *)errorMessageWithStatusCode:(WeiboSDKResponseStatusCode)code {
    NSString *errorMessage = @"新浪微博发生未知错误，操作失败";
    switch (code) {
        case WeiboSDKResponseStatusCodeSuccess:
        {
            errorMessage = @"";
        }
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
        {
            errorMessage = @"用户取消操作";
        }
            break;
        case WeiboSDKResponseStatusCodeSentFail:
        {
            errorMessage = @"发送失败";
        }
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
        {
            errorMessage = @"授权失败";
        }
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
        {
            errorMessage = @"用户取消安装微博客户端";
        }
            break;
        case WeiboSDKResponseStatusCodePayFail:
        {
            errorMessage = @"支付失败";
        }
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
        {
            errorMessage = @"分享失败";
        }
            break;
        case WeiboSDKResponseStatusCodeUnsupport:
        {
            errorMessage = @"不支持的请求";
        }
            break;
        case WeiboSDKResponseStatusCodeUnknown:
        {
            errorMessage = @"新浪微博发生未知错误";
        }
            break;
        default:
            break;
    }
    return errorMessage;
}

- (void)handleAuthResp:(WBAuthorizeResponse *)resp {
    if (resp.statusCode == WeiboSDKResponseStatusCodeSuccess && [resp.accessToken length] > 0) {
        self.token = resp.accessToken;
        if (self.loginSuccessBlock) {
            self.loginSuccessBlock(resp.userID, resp.accessToken);
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"Weibo Auth" code:resp.statusCode userInfo:[NSDictionary dictionaryWithObject:[WeiboManager errorMessageWithStatusCode:resp.statusCode] forKey:kErrMsgKey]];
        if (self.loginFailureBlock) {
            self.loginFailureBlock(error);
        }
    }
}

- (void)handleShareResp:(WBSendMessageToWeiboResponse *)resp {
    if (resp.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        if (self.shareSuccessBlock) {
            self.shareSuccessBlock();
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"Weibo Share" code:resp.statusCode userInfo:[NSDictionary dictionaryWithObject:[WeiboManager errorMessageWithStatusCode:resp.statusCode] forKey:kErrMsgKey]];
        if (self.shareFailureBlock) {
            self.shareFailureBlock(error);
        }
    }
}

#pragma mark Public methods

+ (BOOL)canShare {
    return [[WeiboManager sharedManager] isOnline];
}

+ (BOOL)canLogin {
    return [[WeiboManager sharedManager] isOnline];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)sendLoginRequestWithSucceed:(void (^)(NSString *, NSString *))succeed failure:(void (^)(NSError *))failure {
    if (!self.isOnline) {
        return NO;
    }
    self.loginSuccessBlock = succeed;
    self.loginFailureBlock = failure;
    WBAuthorizeRequest *request = [WeiboManager weiboAuthRequest];
    return [WeiboSDK sendRequest:request];
}

- (BOOL)sendShareRequestWithObject:(WeiboShareObject *)object succeed:(void (^)())succeed failure:(void (^)(NSError *))failure {
    //WBSendMessageToWeiboRequest 说明
    //当用户安装了可以支持微博客户端內分享的微博客户端时,会自动唤起微博并分享
    //当用户没有安装微博客户端或微博客户端过低无法支持通过客户端內分享的时候会自动唤起SDK內微博发布器
    //故不用判断是否可以分享
    if (!self.isOnline) {
        return NO;
    }
    
    self.shareSuccessBlock = succeed;
    self.shareFailureBlock = failure;
    
    WBMessageObject *messageObject = [WeiboManager messageObjectFromWeiboShareObject:object];
    
    if (!messageObject) {
        NSError *error = [NSError errorWithDomain:@"Weibo Share" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"无效的分享内容" forKey:kErrMsgKey]];
        if (failure) {
            failure(error);
        }
        return NO;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObject authInfo:[WeiboManager weiboAuthRequest] access_token:self.token];
    
    BOOL bRet = [WeiboSDK sendRequest:request];
    return bRet;
}

@end



@implementation WeiboShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeiboShareObjectTypeDefault;
    }
    return self;
}

+ (instancetype)shareObjectWithFollowingContent:(NSString *)content {
    if (![content isKindOfClass:[NSString class]] || [content length] == 0) {
        return nil;
    }
    WeiboShareObject *obj = [[WeiboShareObject alloc] init];
    obj.followingContent = content;
    return obj;
}

@end


@implementation WeiboImageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeiboShareObjectTypeImage;
    }
    return self;
}

+ (instancetype)imageShareObjectWithFollowingContent:(NSString *)content image:(UIImage *)image {
    if ([content length] == 0 && !image) {
        return nil;
    }
    
    WeiboImageShareObject *obj = [[WeiboImageShareObject alloc] init];
    obj.followingContent = content;
    obj.image = image;
    return obj;
}

@end

@implementation WeiboWebPageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeiboShareObjectTypeWebPage;
    }
    return self;
}

+ (instancetype)webPageShareObjectWithFollowingContent:(NSString *)content
                                            identifier:(NSString *)identifier
                                                 title:(NSString *)title
                                             urlString:(NSString *)urlString {
    if ([content length] == 0 && ([identifier length] == 0 || [title length] == 0 || [urlString length] == 0)) {
        return nil;
    }
    
    WeiboWebPageShareObject *obj = [[WeiboWebPageShareObject alloc] init];
    obj.followingContent = content;
    obj.identifier = identifier;
    obj.title = title;
    obj.webPageUrlString = urlString;
    return obj;
}

@end