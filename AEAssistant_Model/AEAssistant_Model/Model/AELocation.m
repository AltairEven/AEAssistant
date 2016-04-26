//
//  AELocation.m
//  AEAssistant_Model
//
//  Created by Qian Ye on 16/4/25.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AELocation.h"

@implementation AELocation

- (instancetype)initWithLocation:(CLLocation *)location locationDescription:(NSString *)description {
    if (!location) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.location = location;
        self.locationDescription = description;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    AELocation *location = [[AELocation allocWithZone:zone] init];
    location.location = [self.location copy];
    location.locationDescription = [self.locationDescription copy];
    location.moreDescription = [self.moreDescription copy];
    return location;
}

@end
