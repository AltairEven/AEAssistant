//
//  KTCPaymentInfo.h
//  KidsTC
//
//  Created by Altair on 11/21/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    KTCPaymentTypeNone,
    KTCPaymentTypeAlipay,
    KTCPaymentTypeWechat
}KTCPaymentType;

@interface KTCPaymentInfo : NSObject

@property (nonatomic, assign) KTCPaymentType paymentType;

+ (instancetype)instanceWithRawData:(NSDictionary *)data;

@end

@interface KTCAlipayPaymentInfo : KTCPaymentInfo

@property (nonatomic, copy) NSString *paymentUrl;

@end

@interface KTCWeChatPaymentInfo : KTCPaymentInfo

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *nonceString;

@property (nonatomic, copy) NSString *packageValue;

@property (nonatomic, copy) NSString *partnerId;

@property (nonatomic, copy) NSString *prepayId;

@property (nonatomic, copy) NSString *sign;

@property (nonatomic, assign) UInt32 timeStamp;

@end
