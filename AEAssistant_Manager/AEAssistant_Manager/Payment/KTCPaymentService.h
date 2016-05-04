//
//  KTCPaymentService.h
//  KidsTC
//
//  Created by Altair on 11/21/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTCPaymentInfo.h"

@interface KTCPaymentService : NSObject

+ (instancetype)sharedService;

- (void)startPaymentWithOrderIdentifier:(NSString *)identifier succeed:(void(^)())succeed failure:(void(^)(NSError *error))failure;

+ (void)startPaymentWithInfo:(KTCPaymentInfo *)info succeed:(void(^)())succeed failure:(void(^)(NSError *error))failure;

@end