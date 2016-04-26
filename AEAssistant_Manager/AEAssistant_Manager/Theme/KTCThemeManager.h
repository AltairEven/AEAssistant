//
//  KTCThemeManager.h
//  KidsTC
//
//  Created by Altair on 12/24/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AEAssistant_ToolBox/AEAssistant_ToolBox.h>

extern NSString *const kThemeDidChangedNotification;

@interface KTCThemeManager : NSObject

@property (nonatomic, strong, readonly) AUITheme *defaultTheme;

@property (nonatomic, strong, readonly) AUITheme *currentTheme;

@property (nonatomic, assign) BOOL autoLoad; //default YES

+ (instancetype)manager;

- (void)setTheme:(AUITheme *)theme;

- (void)reloadTheme;

- (void)synchronizeTheme;

- (void)loadLocalTheme;

- (void)removeLocalData;

@end
