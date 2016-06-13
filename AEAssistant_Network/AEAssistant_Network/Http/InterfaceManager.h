//
//  InterfaceManager.h
//  KidsTC
//
//  Created by 钱烨 on 8/4/15.
//  Copyright (c) 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequestClient.h"

@interface InterfaceManager : NSObject

@property (nonatomic, copy) NSString *interfaceListAddress;

@property (nonatomic, strong, readonly) NSDictionary *interfaceData;

@property (nonatomic, strong, readonly) NSDictionary * URLMapWithAlias;

+ (instancetype)sharedManager;

- (void)updateInterface;

- (NSString *)getURLStringWithAliasName:(NSString *)aliasName;

- (HttpRequestMethod)getURLSendDataMethodWithAliasName:(NSString *)aliasName;

@end
