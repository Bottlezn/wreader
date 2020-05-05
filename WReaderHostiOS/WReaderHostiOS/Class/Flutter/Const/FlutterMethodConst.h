//
//  FlutterMethodConst.h
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,FlutterIncomeMethod){
    //未知方法, IM income method
    IM_UNKNOWN_METHOD,
    //获取版本信息
    IM_GET_VERSION_INFO,
    //切换到桌面
    IM_GOTO_HOME,
    //关闭App
    IM_EXIT_APP,
    //获取 git 仓库的存放路径
    IM_GET_GIT_ROOT_PATH,
    //Toast
    IM_SHOW_TOAST,
};

@interface FlutterMethodConst : NSObject

//根据函数名称，获取枚举值。 oc 的语法真的一言难尽啊
+ (FlutterIncomeMethod)typeWithMethodName:(NSString *)methodName;

@end

NS_ASSUME_NONNULL_END
