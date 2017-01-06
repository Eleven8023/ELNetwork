//
//  ViewController.m
//  ELNetWork
//
//  Created by Eleven on 17/1/4.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import "ViewController.h"

#import "HttpNetModule.h"

@interface ViewController ()<HTTPResponseDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HttpNetModule *model = [[HttpNetModule alloc] init];
    model.httpResponseDelegate = self;
    [model getSmsCodeForRegisterCode:@"13934567890"];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark -- 模块业务的代理方法
- (void)processHttpResponseData:(NSString *)nssRequestCode status:(int)iStatus message:(NSString *)nssMsg data:(id)data{
    if (iStatus == 200) {
        
    }else if (iStatus == -1000){
        
    }else{
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
