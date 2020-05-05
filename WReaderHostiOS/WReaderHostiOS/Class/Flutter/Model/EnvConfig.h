//
//  EnvConfig.h
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//int brightness_mode =[result intForColumn:@"brightness_mode"];
//int show_exit_hint =[result intForColumn:@"show_exit_hint"];
//NSString *my_word =[result stringForColumn:@"my_word"];
//NSString *language_code =[result stringForColumn:@"language_code"];
@interface EnvConfig : NSObject

@property (nonatomic) int brightnessMode;
@property (nonatomic) int showExitHint;
@property (nonatomic,copy) NSString *myWord;
@property (nonatomic,copy) NSString *languageCode;

@end

NS_ASSUME_NONNULL_END
