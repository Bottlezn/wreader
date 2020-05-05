//
//  ToastUtil.h
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WHToast.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastUtil : NSObject

+ (void)showToast:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
