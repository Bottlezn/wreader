//
//  FlutterModuleDBHelper.m
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/5/1.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import "FlutterModuleDBHelper.h"

@implementation FlutterModuleDBHelper

static NSString *const DB_NAME=@"wreader_db.db";

+ (NSString *)getWreaderDBName{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath=[documentPath stringByAppendingPathComponent:DB_NAME];
    NSLog(@"documentPath = %@",documentPath);
    NSLog(@"dbPath = %@",dbPath);
    return dbPath;
}

//判断 wreader_db.db 数据库文件是否存在
+ (BOOL)dbExist{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self getWreaderDBName]];
}

//CREATE TABLE IF NOT EXISTS environment(brightness_mode INT(1),show_exit_hint INT(1),my_word VARCHAR(64),language_code VARCHAR(32))
+ (EnvConfig*)getEnvConfig{
    if([self dbExist]){
        FMDatabase *db=[FMDatabase databaseWithPath:[self getWreaderDBName]];
        if(![db open]){
            NSLog(@"打开数据库失败");
            [db close];
            return nil;
        }
        FMResultSet *result= [db executeQuery:@"select * from  environment"];
        EnvConfig *config=nil;
        if([result next]){
            NSLog(@"查询到数据");
            config = [EnvConfig new];
            config.brightnessMode =[result intForColumn:@"brightness_mode"];
            config.showExitHint =[result intForColumn:@"show_exit_hint"];
            config.myWord =[result stringForColumn:@"my_word"];
            config.languageCode =[result stringForColumn:@"language_code"];
        }
        [result close];
        [db close];
        return config;
    }
    return nil;
}

@end
