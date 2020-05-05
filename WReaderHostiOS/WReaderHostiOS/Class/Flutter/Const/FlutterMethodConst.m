//
//  FlutterMethodConst.m
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import "FlutterMethodConst.h"

@implementation FlutterMethodConst


//未知方法
static NSString *const UNKNOWN_METHOD=@"unknown";
static NSString *const GET_VERSION_INFO=@"getVersionInfo";
static NSString *const GOTO_HOME=@"gotoHome";
static NSString *const EXIT_APP=@"exitApp";
static NSString *const GET_GIT_ROOT_PATH=@"getGitRootPath";
static NSString *const SHOW_TOAST=@"showToast";

+ (FlutterIncomeMethod)typeWithMethodName:(NSString *)methodName{
    if([GET_VERSION_INFO isEqualToString:methodName]){
        return IM_GET_VERSION_INFO;
    }
    if([GOTO_HOME isEqualToString:methodName]){
        return IM_GOTO_HOME;
    }
    if([EXIT_APP isEqualToString:methodName]){
        return IM_EXIT_APP;
    }
    if([GET_GIT_ROOT_PATH isEqualToString:methodName]){
        return IM_GET_GIT_ROOT_PATH;
    }
    if([SHOW_TOAST isEqualToString:methodName]){
        return IM_SHOW_TOAST;
    }
    return IM_UNKNOWN_METHOD;
}

@end
