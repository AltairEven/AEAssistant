//
//  KTCPaymentInfo.m
//  KidsTC
//
//  Created by Altair on 11/21/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "KTCPaymentInfo.h"

@implementation KTCPaymentInfo

+ (instancetype)instanceWithRawData:(NSDictionary *)data {
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    KTCPaymentType type = (KTCPaymentType)[[data objectForKey:@"payChannel"] integerValue];
    switch (type) {
        case KTCPaymentTypeNone:
        {
            KTCPaymentInfo *info = [[KTCPaymentInfo alloc] init];
            info.paymentType = type;
            return info;
        }
            break;
        case KTCPaymentTypeAlipay:
        {
            KTCAlipayPaymentInfo *info = [[KTCAlipayPaymentInfo alloc] init];
            info.paymentType = type;
            info.paymentUrl = [NSString stringWithFormat:@"%@", [data objectForKey:@"payUrl"]];
            return info;
        }
            break;
        case KTCPaymentTypeWechat:
        {
            KTCWeChatPaymentInfo *info = [[KTCWeChatPaymentInfo alloc] init];
            info.paymentType = type;
            info.message = [NSString stringWithFormat:@"%@", [data objectForKey:@"message"]];
            info.nonceString = [NSString stringWithFormat:@"%@", [data objectForKey:@"nonceStr"]];
            info.packageValue = [NSString stringWithFormat:@"%@", [data objectForKey:@"packageValue"]];
            info.partnerId = [NSString stringWithFormat:@"%@", [data objectForKey:@"partnerId"]];
            info.prepayId = [NSString stringWithFormat:@"%@", [data objectForKey:@"prepayId"]];
            info.sign = [NSString stringWithFormat:@"%@", [data objectForKey:@"sign"]];
            info.timeStamp = [[data objectForKey:@"timeStamp"] intValue];
            return info;
        }
            break;
        default:
            break;
    }
    return nil;
}

@end

@implementation KTCAlipayPaymentInfo

@end


@implementation KTCWeChatPaymentInfo



@end