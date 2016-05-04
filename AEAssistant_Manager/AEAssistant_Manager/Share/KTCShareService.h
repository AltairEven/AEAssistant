//
//  KTCShareService.h
//  KidsTC
//
//  Created by Altair on 12/7/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AEAssistant_Network/AEAssistant_Network.h>

typedef enum {
    KTCShareServiceChannelWechatSession = 1,
    KTCShareServiceChannelWechatTimeLine,
    KTCShareServiceChannelWeibo,
    KTCShareServiceChannelQQ,
    KTCShareServiceChannelQZone
}KTCShareServiceChannel;

typedef enum {
    KTCShareServiceTypeUnknow = 0,
    KTCShareServiceTypeStore = 1,
    KTCShareServiceTypeService,
    KTCShareServiceTypeNews,
    KTCShareServiceTypeStrategy
}KTCShareServiceType;

@interface KTCShareService : NSObject

+ (instancetype)service;

- (void)sendShareSucceedFeedbackToServerWithIdentifier:(NSString *)identifier
                                               channel:(KTCShareServiceChannel)channel
                                                  type:(KTCShareServiceType)type
                                                 title:(NSString *)title;

@end
