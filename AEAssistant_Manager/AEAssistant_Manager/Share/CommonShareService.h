//
//  CommonShareService.h
//  KidsTC
//
//  Created by Altair on 11/20/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    CommonShareTypeWechatSession,
    CommonShareTypeWechatTimeLine,
    CommonShareTypeWeibo,
    CommonShareTypeQQ,
    CommonShareTypeQZone
}CommonShareType;

extern NSString *const kCommonShareTypeWechatSessionKey;
extern NSString *const kCommonShareTypeWechatTimeLineKey;
extern NSString *const kCommonShareTypeWeiboKey;
extern NSString *const kCommonShareTypeQQKey;
extern NSString *const kCommonShareTypeQZoneKey;

@class CommonShareObject;

@interface CommonShareService : NSObject

+ (instancetype)sharedService;

+ (NSArray<NSNumber *> *)availableShareTypes;

+ (NSDictionary *)shareTypeAvailablities;

- (BOOL)startThirdPartyShareWithType:(CommonShareType)type
                              object:(CommonShareObject *)object
                             succeed:(void(^)())succeed
                             failure:(void(^)(NSError *error))failure;

@end