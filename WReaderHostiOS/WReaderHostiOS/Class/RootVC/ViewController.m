//
//  ViewController.m
//  WReaderHostiOS
//
//  Created by 王展鸿 on 2020/4/25.
//  Copyright © 2020 王展鸿. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "WReaderViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *Button=[[UIButton alloc]init];
    Button.frame=CGRectMake(10, 20, 120, 120);
    Button.backgroundColor=UIColor.redColor;
    [Button addTarget:self action:@selector(jumpFlutterViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Button];
    self.view.backgroundColor=UIColor.whiteColor;
    EnvConfig *config=[FlutterModuleDBHelper getEnvConfig];
    NSLog(@"EnvConfig.brightnessMode = %d",config.brightnessMode);
    NSLog(@"EnvConfig.showExitHint = %d",config.showExitHint);
    NSLog(@"EnvConfig.myWord = %@",config.myWord);
    NSLog(@"EnvConfig.languageCode = %@",config.languageCode);
}

- (void)jumpFlutterViewController{
    FlutterViewController *flutterViewController=[[WReaderViewController alloc]init];
    flutterViewController.modalPresentationStyle=
    UIModalPresentationFullScreen;
    [self presentViewController:flutterViewController animated:YES completion:nil];
}

@end
