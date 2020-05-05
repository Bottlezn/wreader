//
//  AppDelegate.h
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/4/25.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Flutter/Flutter.h>

@interface AppDelegate : FlutterAppDelegate <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic,strong) FlutterEngine *flutterEngine;


- (void)saveContext;


@end

