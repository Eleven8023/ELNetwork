//
//  HttpNetModule.h
//  ELNetWork
//
//  Created by Eleven on 17/1/5.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPResponseDelegate <NSObject>
/**
 *  所有业务层都有此类发起 通过以下代理方法统一管理 该类根据后台人员接口形式而定 底层为ELAPIProxt类 可根据自己业务复杂程度设定离散型管理业务 还是统一管理 这里给出统一管理业务形式  swift版本会给出离散型管理
 *  @param nssRequestCode 业务的接口名称用来区分不同业务的名称 status 返回的状态码 message 状态信息 data 数据
 */
- (void) processHttpResponseData:(NSString *)nssRequestCode
                          status:(int)iStatus
                         message:(NSString *)nssMsg
                            data:(id)data;
@end

@interface HttpNetModule : NSObject
{
    NSString * m_nssUrl;
    NSMutableArray * m_arrRequest;
}

@property (nonatomic, assign)BOOL retriveTestData;
@property (nonatomic, copy)NSString * m_nssUrl;
@property (nonatomic, assign) id<HTTPResponseDelegate> httpResponseDelegate;

// 取消所有业务请求
- (void)cancelAllRequest;

// 获取时间戳
- (NSString *)getTimeStamp;

// 例子:获取验证码
- (void)getSmsCodeForRegisterCode:(NSString *)phoneNumber;

@end
