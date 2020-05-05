//
//  WReaderViewController.h
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/4/29.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import <Flutter/Flutter.h>
#import <GeneratedPluginRegistrant.h>
#import "FlutterConst.h"
#import "FlutterMethodConst.h"
#import "ToastUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface WReaderViewController : FlutterViewController
@property (nonatomic,strong) FlutterMethodChannel *methodChannel;


@end

NS_ASSUME_NONNULL_END
