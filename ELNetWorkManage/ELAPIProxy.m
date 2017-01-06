//
//  ELAPIProxy.m
//  ELNetWork
//
//  Created by Eleven on 17/1/4.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import "ELAPIProxy.h"
#import "AFNetworking.h"
#import "NSArray+SFNetworkingMethods.h"
#import "NSDictionary+SFNetworkingMethods.h"
#import "NSString+SFNetworkingMethods.h"

@implementation ELAPIProxy

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static ELAPIProxy *shareInstance = nil;
    dispatch_once(&onceToken, ^{
        shareInstance = [[ELAPIProxy alloc] init];
    });
    return shareInstance;
}

- (NSURLSessionDataTask *)postRequestWithUrl:(NSString *)urlString paramsDic:(NSDictionary *)paramsDic responseBlock:(HQCallback)responseBlock{
    HQCallback responseCopy = CFBridgingRelease((__bridge CFTypeRef _Nullable)(responseBlock));
    // 签名业务参数
    NSMutableArray *signArray = [NSMutableArray arrayWithArray:[paramsDic SF_transformedUrlParamsArraySignature:YES]];
    [signArray addObject:[NSString stringWithFormat:@"app_secret=%@",@""]];
    
    // 生成签名
    NSString * sign = [[signArray SF_paramsString] SF_md5];
    // 请求参数拼接签名
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:paramsDic];
    [params setObject:sign forKey:@"sign"];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSLog(@"\n URL: %@\n params: %@",URL, params);
    
    // 请求管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = NETWORKCONNECTTIMEOUT;
    manager.requestSerializer = requestSerializer;
    
    if ([urlString hasPrefix:@"https://"]) {
        manager.securityPolicy = [self customSecurityPolicy];
    }
    
    __block UIApplication *weekApp = [UIApplication sharedApplication];
    weekApp.networkActivityIndicatorVisible = YES;
    
    NSURLSessionDataTask *task = [manager POST:URL.absoluteString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        weekApp.networkActivityIndicatorVisible = NO;
        NSLog(@"请求成功");
        if (!TYPESECURITYCHECK(responseObject, [NSData class])) {
            responseCopy(nil, KEnumURLResponseStatusErrorFormatError);
            return;
        }
        
        NSDictionary *dicResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        responseCopy(dicResponse, KEnumURLResponseStatusSuccess);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        weekApp.networkActivityIndicatorVisible = NO;
        NSLog(@"请求失败:%@", error.localizedDescription);
        // 1.未能连接到服务器 2.似乎已断开与互联网的链接 3. 请求超时 4.请求取消
        if ([error.localizedDescription rangeOfString:@"已取消"].length != 0) {
            responseCopy(nil,KEnumURLResponseStatusErrorCancell);
        }else if ([error.localizedDescription rangeOfString:@"请求超时"].length != 0){
            responseCopy(nil,KEnumURLResponseStatusErrorTimeout);
        }else if ([error.localizedDescription rangeOfString:@"未能连接到服务器"].length != 0){
            responseCopy(nil,KEnumURLResponseStatusErrorNoConnect);
        }else{
            responseCopy(nil,KEnumURLResponseStatusErrorNoNetwork);
        }
    }];

    return task;
}

- (AFSecurityPolicy*)customSecurityPolicy{
    // 导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"serverdevelop" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果是需要验证自建证书, 需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithArray:@[cerData]];
    return securityPolicy;
}

- (void)cancellRequestWithTask:(NSURLSessionDataTask *)task{
    TYPESECURITYCHECK(task, [NSURLSessionDataTask class]);
    
    if (task.state != NSURLSessionTaskStateCompleted) {
        [task cancel];
        NSLog(@"request clearDelegatesAndCancel\n");
    }else{
        NSLog(@"request has finished");
    }
}

@end
