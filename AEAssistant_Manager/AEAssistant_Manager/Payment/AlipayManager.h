//
//  AlipayManager.h
//  KidsTC
//
//  Created by Altair on 11/21/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kAlipayFromScheme;

@interface AlipayManager : NSObject

+ (instancetype)sharedManager;

+ (BOOL)canLogin;

- (BOOL)handleOpenUrl:(NSURL *)url;

- (void)startPaymentWithUrlString:(NSString *)urlString succeed:(void(^)())succeed failure:(void(^)(NSError *error))failure;

@end
