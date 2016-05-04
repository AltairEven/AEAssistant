//
//  KTCShareService.m
//  KidsTC
//
//  Created by Altair on 12/7/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "KTCShareService.h"

static KTCShareService *_sharedInstance = nil;

@interface KTCShareService ()

@property (nonatomic, strong) HttpRequestClient *sendFeedbackRequest;

@end

@implementation KTCShareService

+ (instancetype)service {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedInstance = [[KTCShareService alloc] init];
    });
    
    return _sharedInstance;
}

- (void)sendShareSucceedFeedbackToServerWithIdentifier:(NSString *)identifier
                                               channel:(KTCShareServiceChannel)channel
                                                  type:(KTCShareServiceType)type
                                                 title:(NSString *)title {
    if (!self.sendFeedbackRequest) {
        self.sendFeedbackRequest = [HttpRequestClient clientWithUrlAliasName:@"SHARE_ADD_RECORD"];
    } else {
        [self.sendFeedbackRequest cancel];
    }
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                           identifier, @"id",
                           [NSNumber numberWithInteger:channel], @"channel",
                           [NSNumber numberWithInteger:type], @"type",
                           title, @"name", nil];
    
    [self.sendFeedbackRequest startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
        NSLog(@"Send share feedback succeed");
    } failure:^(HttpRequestClient *client, NSError *error) {
        NSLog(@"Send share feedback failed");
    }];
}

@end
