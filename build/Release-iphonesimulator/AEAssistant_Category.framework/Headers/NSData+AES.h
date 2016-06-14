//
//  NSData+AES.h
//  AEAssistant_Category
//
//  Created by Qian Ye on 16/6/13.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

- (NSData *)AES256ParmEncryptWithKey:(NSString *)key;   //加密

- (NSData *)AES256ParmDecryptWithKey:(NSString *)key;   //解密

@end
