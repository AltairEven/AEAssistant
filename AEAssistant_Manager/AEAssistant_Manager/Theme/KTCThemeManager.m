//
//  KTCThemeManager.m
//  KidsTC
//
//  Created by Altair on 12/24/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "KTCThemeManager.h"
#import <AEAssistant_Network/AEAssistant_Network.h>


#define ThemeLocalDirectory (@"/ThemeLocalDirectory")
#define ThemeFilesDirectory (@"/ThemeLocalDirectory/ThemeFilesDirectory")
#define ThemeConfigFileName (@"config")

NSString *const kThemeDidChangedNotification = @"kThemeDidChangedNotification";

static NSString *const kThemeConfigVersionKey = @"version";
static NSString *const kThemeConfigStartTimeKey = @"startTime";
static NSString *const kThemeConfigExpireTimeKey = @"expireTime";

static NSString *const kThemeConfigNaviBGColorKey = @"topColor";
static NSString *const kThemeConfigTabBGColorKey = @"bgColor";

static NSString *const kThemeConfigTabHomeKey = @"home";
static NSString *const kThemeConfigTabNewsKey = @"news";
static NSString *const kThemeConfigTabStrategyKey = @"strategy";
static NSString *const kThemeConfigTabMeKey = @"me";

static NSString *const kThemeConfigTabItemTitleKey = @"title";
static NSString *const kThemeConfigTabItemTitleColorNormalKey = @"titleColorNor";
static NSString *const kThemeConfigTabItemTitleColorHighlightKey = @"titleColorSel";
static NSString *const kThemeConfigTabItemImageNameNormalKey = @"imgNorName";
static NSString *const kThemeConfigTabItemImageNameHighlightKey = @"imgSelName";


static KTCThemeManager *_sharedInstance = nil;

@interface KTCThemeManager ()

@property (nonatomic, strong) HttpRequestClient *loadThemeConfigClient;

@property (nonatomic, strong) NSURLRequest *loadThemeZipRequest;

@property (nonatomic, strong) NSDictionary *localConfig;

- (BOOL)localConfigIsValid;

- (NSString *)localVersion;

- (void)loadRemoteDataSucceed:(NSDictionary *)data;

- (void)loadRemoteDataFailed:(NSError *)error;

- (void)downloadThemeZipFileWithUrlString:(NSString *)urlString;

- (void)downloadThemeZipSucceed:(NSData *)data response:(NSURLResponse *)response;

- (void)downloadThemeZipFailed:(NSError *)error response:(NSURLResponse *)response;

- (AUITheme *)themeFromLocalData;

- (UIColor *)colorWithString:(NSString *)string;

- (AUITabbarItemElement *)tabbarItemElementWithRawData:(NSDictionary *)data;

@end

@implementation KTCThemeManager
@synthesize currentTheme = _currentTheme;

+ (instancetype)manager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedInstance = [[KTCThemeManager alloc] init];
        _sharedInstance.autoLoad = YES;
    });
    
    return _sharedInstance;
}


- (AUITheme *)defaultTheme {
    return [AUITheme defaultTheme];
}

- (AUITheme *)currentTheme {
    if (!_currentTheme) {
        _currentTheme = [AUITheme defaultTheme];
    }
    return _currentTheme;
}

- (void)setTheme:(AUITheme *)theme {
    if (!theme) {
        return;
    }
    _currentTheme = [theme copy];
    [self reloadTheme];
}

#pragma mark Synchronize

- (void)synchronizeTheme {
    if (!self.loadThemeConfigClient) {
        self.loadThemeConfigClient = [HttpRequestClient clientWithUrlAliasName:@"GET_HOME_THEME"];
    }
    NSDictionary *param = [NSDictionary dictionaryWithObject:[self localVersion] forKey:@"version"];
    
    __weak KTCThemeManager *weakSelf = self;
    [weakSelf.loadThemeConfigClient startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
        [weakSelf loadRemoteDataSucceed:responseData];
    } failure:^(HttpRequestClient *client, NSError *error) {
        [weakSelf loadRemoteDataFailed:error];
    }];
}


- (void)loadRemoteDataSucceed:(NSDictionary *)data {
    //有数据返回，说明服务端版本更新
    NSDictionary *dataDic = [data objectForKey:@"data"];
    if ([dataDic isKindOfClass:[NSDictionary class]]) {
        NSString *remoteVersion = [dataDic objectForKey:@"newVersion"];
        if (![remoteVersion isKindOfClass:[NSString class]]) {
            //服务端返回的版本参数错误
            return;
        }
        if ([[self localVersion] floatValue] >= [remoteVersion floatValue]) {
            //服务端版本小于本地版本
            return;
        }
        //开始下载新主题
        NSString *downloadUrlString = [dataDic objectForKey:@"downLink"];
        [self downloadThemeZipFileWithUrlString:downloadUrlString];
    }
}

- (void)loadRemoteDataFailed:(NSError *)error {
    if (error.code == -2001) {
        [self removeLocalData];
        [self setTheme:[[KTCThemeManager manager] defaultTheme]];
    }
}

#pragma mark Zip File

- (void)downloadThemeZipFileWithUrlString:(NSString *)urlString {
    if (![urlString isKindOfClass:[NSString class]] || [urlString length] == 0) {
        //无效的下载地址
    }
    self.loadThemeZipRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    __weak KTCThemeManager *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:weakSelf.loadThemeZipRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [weakSelf downloadThemeZipFailed:connectionError response:response];
        } else {
            [weakSelf downloadThemeZipSucceed:data response:response];
        }
    }];
}

- (void)downloadThemeZipSucceed:(NSData *)data response:(NSURLResponse *)response {
    //先移除本地文件
    [self removeLocalData];
    
    NSString *destination = FILE_CACHE_PATH(ThemeFilesDirectory);
    //创建文件夹
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
        return;
    }
    NSString *filePath = [NSString stringWithFormat:@"%@.zip", destination];
    //先写入文件
    BOOL bWrite = [data writeToFile:filePath atomically:NO];
    if (bWrite) {
        //解压缩
        BOOL bUnzip = [SSZipArchive unzipFileAtPath:filePath toDestination:destination];
        if (bUnzip && self.autoLoad) {
            //如果解压完成并且需要自动加载，则加载
            [self loadLocalTheme];
        }
    }
}

- (void)downloadThemeZipFailed:(NSError *)error response:(NSURLResponse *)response {
    
}


#pragma mark Local Files

- (NSString *)localVersion {
    if (!self.localConfig) {
        return @"";
    }
    NSString *version = [self.localConfig objectForKey:kThemeConfigVersionKey];
    if (!version || [version length] == 0) {
        return @"";
    }
    return version;
}

- (BOOL)localConfigIsValid {
    if ([[self localVersion] length] == 0) {
        //版本不正确
        return NO;
    }
    
    NSTimeInterval nowaTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval startTime = [[self.localConfig objectForKey:kThemeConfigStartTimeKey] doubleValue];
    if (nowaTimeInterval < startTime) {
        //未开始
        return NO;
    }
    NSTimeInterval endTime = [[self.localConfig objectForKey:kThemeConfigExpireTimeKey] doubleValue];
    if (nowaTimeInterval > endTime) {
        //已过期
        return NO;
    }
    
    NSString *topBGColorString = [self.localConfig objectForKey:kThemeConfigNaviBGColorKey];
    if (!topBGColorString || ![topBGColorString isKindOfClass:[NSString class]] || [topBGColorString length] == 0) {
        //导航栏数据无效
        return NO;
    }
    
    NSString *tabBGColorString = [self.localConfig objectForKey:kThemeConfigTabBGColorKey];
    if (!tabBGColorString || ![tabBGColorString isKindOfClass:[NSString class]] || [tabBGColorString length] == 0) {
        //tab栏数据无效
        return NO;
    }
    
    NSDictionary *homeDic = [self.localConfig objectForKey:kThemeConfigTabHomeKey];
    if (!homeDic || ![homeDic isKindOfClass:[NSDictionary class]] || [homeDic count] == 0) {
        //首页数据无效
        return NO;
    }
    NSDictionary *newsDic = [self.localConfig objectForKey:kThemeConfigTabNewsKey];
    if (!newsDic || ![newsDic isKindOfClass:[NSDictionary class]] || [newsDic count] == 0) {
        //知识库数据无效
        return NO;
    }
    NSDictionary *strategyDic = [self.localConfig objectForKey:kThemeConfigTabStrategyKey];
    if (!strategyDic || ![strategyDic isKindOfClass:[NSDictionary class]] || [strategyDic count] == 0) {
        //亲自攻略数据无效
        return NO;
    }
    NSDictionary *meDic = [self.localConfig objectForKey:kThemeConfigTabMeKey];
    if (!meDic || ![meDic isKindOfClass:[NSDictionary class]] || [meDic count] == 0) {
        //用户中心数据无效
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)localConfig {
    if (!_localConfig) {
        NSString *configPath = [NSString stringWithFormat:@"%@/%@", FILE_CACHE_PATH(ThemeFilesDirectory), ThemeConfigFileName];
        NSData *paramData = [NSData dataWithContentsOfFile:configPath];
        if (paramData) {
            _localConfig = [NSJSONSerialization JSONObjectWithData:paramData options:NSJSONReadingAllowFragments error:nil];
        }
    }
    return _localConfig;
}

- (void)removeLocalData {
    NSString *fileDirectory = FILE_CACHE_PATH(ThemeLocalDirectory);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileDirectory error:nil];
    self.localConfig = nil;
}


#pragma mark Theme Load

- (AUITheme *)themeFromLocalData {
    if (![self localConfigIsValid]) {
        //无效的配置文件
        return nil;
    }
    
    NSString *naviBGColorString = [self.localConfig objectForKey:kThemeConfigNaviBGColorKey];
    UIColor *naviBGColor = [self colorWithString:naviBGColorString];
    if (!naviBGColor) {
        return nil;
    }
    
    NSString *tabBGColorString = [self.localConfig objectForKey:kThemeConfigTabBGColorKey];
    UIColor *tabBGColor = [self colorWithString:tabBGColorString];
    if (!tabBGColor) {
        return nil;
    }
    
    NSDictionary *homeDic = [self.localConfig objectForKey:kThemeConfigTabHomeKey];
    AUITabbarItemElement *homeElement = [self tabbarItemElementWithRawData:homeDic];
    if (!homeElement) {
        //首页配置无效
        return nil;
    }
    homeElement.type = AUITabbarItemTypeHome;
    
    NSDictionary *newsDic = [self.localConfig objectForKey:kThemeConfigTabNewsKey];
    AUITabbarItemElement *newsElement = [self tabbarItemElementWithRawData:newsDic];
    if (!newsElement) {
        //知识库配置无效
        return nil;
    }
    newsElement.type = AUITabbarItemTypeNews;
    
    NSDictionary *strategyDic = [self.localConfig objectForKey:kThemeConfigTabStrategyKey];
    AUITabbarItemElement *strategyElement = [self tabbarItemElementWithRawData:strategyDic];
    if (!strategyElement) {
        //攻略配置无效
        return nil;
    }
    strategyElement.type = AUITabbarItemTypeStrategy;
    
    NSDictionary *meDic = [self.localConfig objectForKey:kThemeConfigTabMeKey];
    AUITabbarItemElement *meElement = [self tabbarItemElementWithRawData:meDic];
    if (!meElement) {
        //个人中心配置无效
        return nil;
    }
    meElement.type = AUITabbarItemTypeUserCenter;
    
    AUITheme *theme = [AUITheme defaultTheme];
    theme.navibarBGColor = naviBGColor;
    theme.tabbarBGColor = tabBGColor;
    theme.tabbarItemElements = [NSArray arrayWithObjects:homeElement, newsElement, strategyElement, meElement, nil];
    
    return theme;
}

- (void)loadLocalTheme {
    AUITheme *theme = [self themeFromLocalData];
    if (!theme) {
        return;
    }
    [self setTheme:theme];
}

- (void)reloadTheme {
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangedNotification object:self.currentTheme];
}

#pragma mark Data Convertion

- (UIColor *)colorWithString:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSArray *colorArray = [string componentsSeparatedByString:@","];
    if ([colorArray count] < 3) {
        return nil;
    }
    UIColor *color = [UIColor colorWithRed:[[colorArray objectAtIndex:0] floatValue]/255.0 green:[[colorArray objectAtIndex:1] floatValue]/255.0 blue:[[colorArray objectAtIndex:2] floatValue]/255.0 alpha:1];
    return color;
}

- (AUITabbarItemElement *)tabbarItemElementWithRawData:(NSDictionary *)data {
    if (!data || ![data isKindOfClass:[NSDictionary class]] || [data count] == 0) {
        //配置数据无效
        return nil;
    }
    
    if (![data objectForKey:kThemeConfigTabItemTitleKey]) {
        //按钮标题配置格式无效
        return nil;
    }
    NSString *title = [NSString stringWithFormat:@"%@", [data objectForKey:kThemeConfigTabItemTitleKey]];
    
    if (![data objectForKey:kThemeConfigTabItemImageNameNormalKey]) {
        //按钮图片配置格式无效
        return nil;
    }
    NSString *imageNormalName = [NSString stringWithFormat:@"%@", [data objectForKey:kThemeConfigTabItemImageNameNormalKey]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", FILE_CACHE_PATH(ThemeFilesDirectory), imageNormalName];
    UIImage *normalImage = [UIImage imageWithContentsOfFile:filePath];
    if (imageNormalName && !normalImage) {
        return nil;
    }
    
    if (![data objectForKey:kThemeConfigTabItemImageNameHighlightKey]) {
        //按钮图片配置格式无效
        return nil;
    }
    NSString *imageHighlightName = [NSString stringWithFormat:@"%@", [data objectForKey:kThemeConfigTabItemImageNameHighlightKey]];
    filePath = [NSString stringWithFormat:@"%@/%@", FILE_CACHE_PATH(ThemeFilesDirectory), imageHighlightName];
    UIImage *highlightImage = [UIImage imageWithContentsOfFile:filePath];
    if (imageNormalName && !highlightImage) {
        return nil;
    }
    
    UIColor *titleNormalColor = [self colorWithString:[data objectForKey:kThemeConfigTabItemTitleColorNormalKey]];
    UIColor *titleHighlightColor = [self colorWithString:[data objectForKey:kThemeConfigTabItemTitleColorHighlightKey]];
    
    AUITabbarItemElement *element = [[AUITabbarItemElement alloc] init];
    element.tabbarItemTitle = title;
    element.tabbarTitleColor_Normal = titleNormalColor;
    element.tabbarTitleColor_Highlight = titleHighlightColor;
    element.tabbarItemImage_Normal = normalImage;
    element.tabbarItemImage_Highlight = highlightImage;
    
    return element;
}

@end
