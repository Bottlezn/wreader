//
//  WReaderViewController.m
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/4/29.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import "WReaderViewController.h"

@interface WReaderViewController ()

@end

@implementation WReaderViewController
static NSString *const GIT_REP_DIR=@"gitRepo";

- (void)setupInit {
    // 插件注册
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [self initChannel];
}

// 初始化 Channel
- (void)initChannel{
    FlutterMethodChannel *channel=[FlutterMethodChannel methodChannelWithName:FlutterConst.wReaderChannelName binaryMessenger:self];
    self.methodChannel=channel;
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        NSLog(@"log_hy_flutter, methodCallHandler,  method: %@, arg: %@", call.method, call.arguments);
        [self handleMethodCall:call result:result];
    }];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"call.method : %@, call.argument : %@",call.method,call.arguments);
    switch ([FlutterMethodConst typeWithMethodName:call.method]) {
        case IM_UNKNOWN_METHOD:
            NSLog(@"UNKNOWN method");
            result(@"fail，unknown method.");
            break;
        case IM_GET_VERSION_INFO:
            [self callbackVersionInf:result];
            break;
        case IM_EXIT_APP:
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            exit(0);
            break;
        case IM_GOTO_HOME:
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
            break;
        case IM_GET_GIT_ROOT_PATH:
            [self getGitRootPath:result];
            break;
        case IM_SHOW_TOAST:
            [self showToast:[NSString stringWithFormat:@"%@",call.arguments]];
            result(@"");
            break;
        default:
            break;
    }
}

- (void)showToast:(NSString*)content{
    [ToastUtil showToast:content];
}

//获取本地存储 git 仓库的路径，仅仅显示
- (void)getGitRootPath:(FlutterResult)result{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *gitRepoDir = [documentPath stringByAppendingPathComponent:GIT_REP_DIR];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:gitRepoDir]){
        [fileManager createDirectoryAtPath:gitRepoDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    result(gitRepoDir);
}

// 回调 Flutter 告知版本号
- (void)callbackVersionInf:(FlutterResult)result{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    result([NSString stringWithFormat:@"{\"versionName\":\"%@\",\"versionCode\":1}",app_Version]);
}

- (void)viewDidLoad {
    [self setupInit];
    [super viewDidLoad];
    // UI
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.view.backgroundColor = UIColor.blackColor;
}


@end
