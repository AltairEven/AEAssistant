//
//  TencentManager.m
//  KidsTC
//
//  Created by Altair on 11/16/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "TencentManager.h"
#import <AEAssistant_ThirdParty/AEAssistant_ThirdParty.h>

NSString *const kTencentUrlScheme = @"tencent101265844";
NSString *const kTencentAppKey = @"101265844";

typedef void (^TencentLoginSuccessBlock)(NSString *, NSString *);
typedef void (^TencentLoginFailureBlock)(NSError *);

typedef void (^TencentShareSuccessBlock)();
typedef void (^TencentShareFailureBlock)(NSError *);

static TencentManager *_sharedInstance = nil;

@interface TencentManager () <TencentSessionDelegate, QQApiInterfaceDelegate>

@property (nonatomic, strong) TencentOAuth *tcOAuth;

@property (nonatomic, strong) TencentLoginSuccessBlock loginSuccessBlock;

@property (nonatomic, strong) TencentLoginFailureBlock loginFailureBlock;

@property (nonatomic, strong) TencentShareSuccessBlock shareSuccessBlock;

@property (nonatomic, strong) TencentShareFailureBlock shareFailureBlock;

- (BOOL)getOnline;

+ (QQApiObject *)apiObjectFromQQShareObject:(TencentShareObject *)object;

+ (QQApiObject *)apiObjectFromQZoneShareObject:(TencentShareObject *)object;

- (void)handleShareResp:(SendMessageToQQResp *)resp;

@end

@implementation TencentManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tcOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppKey andDelegate:self];
        [self getOnline];
    }
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedInstance = [[TencentManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark QQApiInterfaceDelegate

- (void)onReq:(QQBaseReq *)req {
    
}

- (void)onResp:(QQBaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        [self handleShareResp:(SendMessageToQQResp *)resp];
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    
}

#pragma mark TencentLoginDelegate

- (void)tencentDidLogin {
    if (self.loginSuccessBlock) {
        self.loginSuccessBlock(self.tcOAuth.openId, self.tcOAuth.accessToken);
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    NSString *errMsg = @"授权失败";
    if (cancelled) {
        errMsg = @"用户取消授权";
    }
    if (self.loginFailureBlock) {
        NSError *error = [NSError errorWithDomain:@"QQ Login" code:-1 userInfo:[NSDictionary dictionaryWithObject:errMsg forKey:kErrMsgKey]];
        self.loginFailureBlock(error);
    }
}

- (void)tencentDidNotNetWork {
    if (self.loginFailureBlock) {
        NSString *errMsg = @"授权超时";
        NSError *error = [NSError errorWithDomain:@"QQ Login" code:-1 userInfo:[NSDictionary dictionaryWithObject:errMsg forKey:kErrMsgKey]];
        self.loginFailureBlock(error);
    }
}

#pragma mari Private methods

- (BOOL)getOnline {
    if (self.tcOAuth) {
        _isOnline = YES;
    }
//    _isOnline = [TencentOAuth iphoneQQInstalled];
//    if (_isOnline) {
//        _isOnline = [TencentOAuth iphoneQQSupportSSOLogin];
//    }
    return _isOnline;
}

+ (QQApiObject *)apiObjectFromQQShareObject:(TencentShareObject *)object {
    if (!object) {
        return nil;
    }
    
    uint64_t contorlFlag = kQQAPICtrlFlagQQShare;
    
    switch (object.type) {
        case TencentShareObjectTypeDefault:
        {
            QQApiObject *apiObject = [[QQApiObject alloc] init];
            apiObject.title = object.title;
            apiObject.description = object.shareDescription;
            apiObject.cflag = contorlFlag;
            
            return apiObject;
        }
            break;
        case TencentShareObjectTypeImage:
        {
            TencentImageShareObject *shareObj = (TencentImageShareObject *)object;
            
            if ([GToolUtil byteCountOfImage:shareObj.image] >= 1024 * 1024 * 5 * 8) {
                return nil;
            }
            NSData *imageData = UIImageJPEGRepresentation(shareObj.image, 0);
            if ([GToolUtil byteCountOfImage:shareObj.thumbImage] >= 1024 * 1024 * 8) {
                return nil;
            }
            NSData *thumbData = nil;
            if (shareObj.thumbImage) {
                thumbData = UIImageJPEGRepresentation(shareObj.thumbImage, 0);
            }
            
            QQApiImageObject *imageObject = [QQApiImageObject objectWithData:imageData previewImageData:thumbData title:shareObj.title description:shareObj.shareDescription];
            imageObject.cflag = contorlFlag;
            return imageObject;
        }
            break;
        case TencentShareObjectTypeWebPage:
        {
            TencentWebPageShareObject *shareObj = (TencentWebPageShareObject *)object;
            
            NSURL *pageUrl = [NSURL URLWithString:shareObj.pageUrlString];
            
            QQApiURLObject *urlObject = nil;
            
            if ([GToolUtil byteCountOfImage:shareObj.thumbImage] >= 1024 * 1024 * 8) {
                return nil;
            }
            if (shareObj.thumbImage) {
                NSData *thumbData = UIImageJPEGRepresentation(shareObj.thumbImage, 0);
                urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageData:thumbData targetContentType:QQApiURLTargetTypeNews];
            } else {
                urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageURL:[NSURL URLWithString:shareObj.thumbImageUrlString] targetContentType:QQApiURLTargetTypeNews];
            }
            urlObject.cflag = contorlFlag;
            return urlObject;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (QQApiObject *)apiObjectFromQZoneShareObject:(TencentShareObject *)object {
    if (!object || ![object isKindOfClass:[TencentWebPageShareObject class]]) {
        return nil;
    }
    
    TencentWebPageShareObject *shareObj = (TencentWebPageShareObject *)object;
    
    NSURL *pageUrl = [NSURL URLWithString:shareObj.pageUrlString];
    
    QQApiURLObject *urlObject = nil;
    
    if ([GToolUtil byteCountOfImage:shareObj.thumbImage] >= 1024 * 1024 * 8) {
        return nil;
    }
    if (shareObj.thumbImage) {
        NSData *thumbData = UIImageJPEGRepresentation(shareObj.thumbImage, 0);
        urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageData:thumbData targetContentType:QQApiURLTargetTypeNews];
    } else {
        urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageURL:[NSURL URLWithString:shareObj.thumbImageUrlString] targetContentType:QQApiURLTargetTypeNews];
    }
    urlObject.cflag = kQQAPICtrlFlagQZoneShareOnStart;
    return urlObject;
}

- (void)handleShareResp:(SendMessageToQQResp *)resp {
    if ([resp.result isEqualToString:@"0"]) {
        if (self.shareSuccessBlock) {
            self.shareSuccessBlock();
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"Tencent Share" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"分享失败" forKey:kErrMsgKey]];
        if (self.shareFailureBlock) {
            self.shareFailureBlock(error);
        }
    }
}

#pragma mark Public methods

+ (BOOL)canShare {
    if (![QQApiInterface isQQInstalled] || ![QQApiInterface isQQSupportApi]) {
        return NO;
    }
    return YES;
}

+ (BOOL)canLogin {
    if (![QQApiInterface isQQInstalled] || ![QQApiInterface isQQSupportApi]) {
        return NO;
    }
    return YES;
}

- (BOOL)handleOpenURL:(NSURL *)url {
    if ([TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    NSString *urlString = [url absoluteString];
    NSDictionary *urlDic = [GToolUtil parsetUrl:urlString];
    NSString *sourceScheme = [urlDic objectForKey:@"source_scheme"];
    if (!sourceScheme || ![sourceScheme isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([sourceScheme isEqualToString:@"mqqapi"]) {
        return [QQApiInterface handleOpenURL:url delegate:self];
    }
    
    return YES;
}

- (BOOL)sendLoginRequestWithSucceed:(void (^)(NSString *, NSString *))succeed failure:(void (^)(NSError *))failure {
    if (!self.isOnline) {
        return NO;
    }
    self.loginSuccessBlock = succeed;
    self.loginFailureBlock = failure;
    NSArray* permissions = [NSArray arrayWithObjects:
                             kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_ADD_SHARE,
                             nil];
    return [self.tcOAuth authorize:permissions];
}

- (BOOL)sendShareRequestToScene:(TencentShareScene)scene
                     WithObject:(TencentShareObject *)object
                        succeed:(void (^)())succeed
                        failure:(void (^)(NSError *))failure {
    self.shareSuccessBlock = succeed;
    self.shareFailureBlock = failure;
    //判断是否可分享
    //判断是否可分享
    if (![QQApiInterface isQQInstalled]) {
        NSError *error = [NSError errorWithDomain:@"Tencent Share" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"请先安装手机QQ客户端" forKey:kErrMsgKey]];
        if (failure) {
            failure(error);
        }
        return NO;
    }
    if (![QQApiInterface isQQSupportApi]) {
        NSError *error = [NSError errorWithDomain:@"Tencent Share" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"当前QQ版本不支持" forKey:kErrMsgKey]];
        if (failure) {
            failure(error);
        }
        return NO;
    }
    
    QQApiObject *shareObject = nil;
    switch (scene) {
        case TencentShareSceneQQ:
        {
            shareObject = [TencentManager apiObjectFromQQShareObject:object];
        }
            break;
        case TencentShareSceneQZone:
        {
            shareObject = [TencentManager apiObjectFromQZoneShareObject:object];
        }
            break;
        default:
            break;
    }
    
    if (!shareObject) {
        NSError *error = [NSError errorWithDomain:@"QQ Share" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"无效的分享内容" forKey:kErrMsgKey]];
        if (failure) {
            failure(error);
        }
        return NO;
    }
    
    SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:shareObject];
    
    QQApiSendResultCode code = [QQApiInterface sendReq:request];
    
    if (code != EQQAPISENDSUCESS) {
        NSError *error = [NSError errorWithDomain:@"QQ Share" code:code userInfo:[NSDictionary dictionaryWithObject:@"分享失败" forKey:kErrMsgKey]];
        if (failure) {
            failure(error);
        }
        return NO;
    }
    return YES;
}

@end


@implementation TencentShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TencentShareObjectTypeDefault;
    }
    return self;
}

+ (instancetype)shareObjectWithTitle:(NSString *)title shareDescription:(NSString *)description {
    TencentShareObject *obj = [[TencentShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = description;
    return obj;
}

@end


@implementation TencentImageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TencentShareObjectTypeImage;
    }
    return self;
}

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                         shareDescription:(NSString *)description
                               shareImage:(UIImage *)image
                               thumbImage:(UIImage *)thumb {
    if (!image && ![image isKindOfClass:[UIImage class]]) {
        return nil;
    }
    
    TencentImageShareObject *obj = [[TencentImageShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = description;
    obj.image = image;
    obj.thumbImage = thumb;
    return obj;
}

@end


@implementation TencentWebPageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TencentShareObjectTypeWebPage;
    }
    return self;
}

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                           shareDescription:(NSString *)description
                              pageUrlString:(NSString *)urlString
                                 thumbImage:(UIImage *)thumb
                        thumbImageUrlString:(NSString *)thumbUrlString {
    
    TencentWebPageShareObject *obj = [[TencentWebPageShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = description;
    obj.pageUrlString = urlString;
    obj.thumbImage = thumb;
    obj.thumbImageUrlString = thumbUrlString;
    return obj;
}

@end