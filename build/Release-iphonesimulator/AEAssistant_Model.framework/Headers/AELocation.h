//
//  AELocation.h
//  AEAssistant_Model
//
//  Created by Qian Ye on 16/4/25.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AELocation : NSObject <NSCopying>

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, copy) NSString *locationDescription;

@property (nonatomic, copy) NSString *moreDescription;

- (instancetype)initWithLocation:(CLLocation *)location locationDescription:(NSString *)description;

@end
