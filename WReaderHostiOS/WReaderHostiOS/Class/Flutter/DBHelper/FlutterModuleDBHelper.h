//
//  FlutterModuleDBHelper.h
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//  iOS 项目不熟练，瞎鸡儿写的
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "EnvConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterModuleDBHelper : NSObject

+ (NSString *)getWreaderDBName;
//判断 db 是否存在
+ (BOOL)dbExist;
//获取项目的环境配置
+ (EnvConfig*)getEnvConfig;


@end

NS_ASSUME_NONNULL_END
