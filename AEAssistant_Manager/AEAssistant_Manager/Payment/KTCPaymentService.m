//
//  KTCPaymentService.m
//  KidsTC
//
//  Created by Altair on 11/21/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "KTCPaymentService.h"
#import "AlipayManager.h"
#import "WeChatManager.h"


static KTCPaymentService *_sharedInstance = nil;

@interface KTCPaymentService ()

@property (nonatomic, strong) HttpRequestClient *loadPaymentInfoRequest;

@end

@implementation KTCPaymentService

+ (instancetype)sharedService {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedInstance = [[KTCPaymentService alloc] init];
    });
    
    return _sharedInstance;
}

- (void)startPaymentWithOrderIdentifier:(NSString *)identifier succeed:(void (^)())succeed failure:(void (^)(NSError *))failure {
    if (!identifier || ![identifier isKindOfClass:[NSString class]]) {
        return;
    }
    if ([identifier length] == 0) {
        return;
    }
    if (!self.loadPaymentInfoRequest) {
        self.loadPaymentInfoRequest = [HttpRequestClient clientWithUrlAliasName:@"PAY_GET_NOTICE"];
    }
    
    NSDictionary *param = [NSDictionary dictionaryWithObject:identifier forKey:@"orderId"];
    
    __weak KTCPaymentService *weakSelf = self;
    [weakSelf.loadPaymentInfoRequest startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
        NSDictionary *dataDic = [responseData objectForKey:@"data"];
        if (dataDic && [dataDic isKindOfClass:[NSDictionary class]]) {
            NSDictionary *payInfoDic = [dataDic objectForKey:@"payInfo"];
            KTCPaymentInfo *info = [KTCPaymentInfo instanceWithRawData:payInfoDic];
            if (info) {
                [KTCPaymentService startPaymentWithInfo:info succeed:succeed failure:failure];
            }
        }
    } failure:^(HttpRequestClient *client, NSError *error) {
        if (failure) {
            if (error.userInfo) {
                NSString *msg = [error.userInfo objectForKey:@"data"];
                if ([msg length] == 0) {
                    msg = @"获取支付信息失败";
                }
                NSError *err = [NSError errorWithDomain:@"Load Payment Info" code:error.code userInfo:[NSDictionary dictionaryWithObject:msg forKey:kErrMsgKey]];
                failure(err);
            }
        }
    }];
}

+ (void)startPaymentWithInfo:(KTCPaymentInfo *)info succeed:(void (^)())succeed failure:(void (^)(NSError *))failure {
    switch (info.paymentType) {
        case KTCPaymentTypeNone:
        {
            succeed();
        }
            break;
        case KTCPaymentTypeAlipay:
        {
            KTCAlipayPaymentInfo *paymentInfo = (KTCAlipayPaymentInfo *)info;
            [[AlipayManager sharedManager] startPaymentWithUrlString:paymentInfo.paymentUrl succeed:succeed failure:failure];
        }
            break;
        case KTCPaymentTypeWechat:
        {
            [[WeChatManager sharedManager] sendPayRequestWithInfo:(KTCWeChatPaymentInfo *)info succeed:succeed failure:failure];
        }
            break;
        default:
            break;
    }
}

@end