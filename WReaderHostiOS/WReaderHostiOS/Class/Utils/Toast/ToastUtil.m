//
//  ToastUtil.m
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import "ToastUtil.h"

@implementation ToastUtil

// 实现方法
+ (void)showToast:(NSString *)text{
    [WHToast showMessage:text duration:1.5 finishHandler:nil];
}

@end
