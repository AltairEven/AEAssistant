//
//  AlipayManager.m
//  KidsTC
//
//  Created by Altair on 11/21/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "AlipayManager.h"
#import <AEAssistant_ThirdParty/AEAssistant_ThirdParty.h>

NSString *const kAlipayFromScheme = @"alipayfromscheme";

#define AlipayCallbackDescriptionKey (@"memo")
#define AlipayCallbackResultKey (@"result")
#define AlipayCallbackResultStatusKey (@"resultStatus")

static AlipayManager *_sharedInstance = nil;

@interface  AlipayManager ()


@end

@implementation AlipayManager

+ (instancetype)sharedManager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedInstance = [[AlipayManager alloc] init];
    });
    
    return _sharedInstance;
}

+ (BOOL)canLogin {
    return YES;
}

- (BOOL)handleOpenUrl:(NSURL *)url {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:nil];
    return YES;
}

- (void)startPaymentWithUrlString:(NSString *)urlString succeed:(void (^)())succeed failure:(void (^)(NSError *))failure {
    [[AlipaySDK defaultService] payOrder:urlString fromScheme:kAlipayFromScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"%@", resultDic);
        NSInteger status = [[resultDic objectForKey:AlipayCallbackResultStatusKey] integerValue];
        if (status == 9000) {
//            NSString *resultString = [resultDic objectForKey:AlipayCallbackResultKey];
            if (succeed) {
                succeed();
            }
        } else {
            if (failure) {
                NSString *resultDescription = [resultDic objectForKey:AlipayCallbackDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"Alipay" code:status userInfo:[NSDictionary dictionaryWithObject:resultDescription forKey:kErrMsgKey]];
                failure(error);
            }
        }
    }];
}

@end
