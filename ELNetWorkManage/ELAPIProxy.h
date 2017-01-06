//
//  ELAPIProxy.h
//  ELNetWork
//
//  Created by Eleven on 17/1/4.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HQURLResponseStatus)
{
    KEnumURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。
    KEnumURLResponseStatusErrorTimeout, //未收到服务器反馈，网络连接超时错误。
    KEnumURLResponseStatusErrorNoNetwork, //无网络错误。
    KEnumURLResponseStatusErrorNoConnect, //未能连接到服务器。
    KEnumURLResponseStatusErrorFormatError, //数据格式错误。
    KEnumURLResponseStatusErrorCancell, //请求取消。
};

typedef void(^HQCallback)(NSDictionary *responseDic , HQURLResponseStatus status);

@interface ELAPIProxy : NSObject

@property (nonatomic, copy) HQCallback callBack;

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)postRequestWithUrl:(NSString *)urlString paramsDic:(NSDictionary *)paramsDic responseBlock:(HQCallback) responseBlock;

//取消网络任务
- (void)cancellRequestWithTask:(NSURLSessionDataTask *)task;

@end
