//
//  HttpNetModule.m
//  ELNetWork
//
//  Created by Eleven on 17/1/5.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import "HttpNetModule.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+SFNetworkingMethods.h"
#import "ELNetworkCache.h"
#import "ELAPIProxy.h"

@interface HttpNetModule ()
@property (nonatomic, strong) ELNetworkCache *cache;
@end

@implementation HttpNetModule
@synthesize m_nssUrl;

- (id)init{
    if (self = [super init]) {
        m_nssUrl = [NSString stringWithFormat:@"%@",@"拼接项目的基地址"];
        
        m_arrRequest = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (ELNetworkCache *)cache{
    if (_cache == nil) {
        _cache = [ELNetworkCache shareInstance];
    }
    return _cache;
}

- (void)cancelAllRequest{
    for (NSURLSessionDataTask *task in m_arrRequest) {
        [[ELAPIProxy sharedInstance] cancellRequestWithTask:task];
    }
    [m_arrRequest removeAllObjects];
}

-(void)dealloc{
    [self cancelAllRequest];
}

- (NSString *)getTimeStamp{
    NSDate *localDate = [NSDate date];
    NSString * nsstimeStamp = [NSString stringWithFormat:@"%ld",(long)[localDate timeIntervalSince1970]];
    return nsstimeStamp;
}
- (BOOL)shouldCache
{
    return NO;
}
// 判断是否有缓存
- (BOOL)hasCacheWithParams:(NSDictionary *)params{
    NSString *methodName = [params objectForKey:@"action"];
    NSData *cacheData = [self.cache fetchCachedDataWithMethodName:methodName requestParams:params];
    
    if (cacheData == nil) {
        return NO;
    }
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:cacheData options:NSJSONReadingMutableContainers error:nil];
    if (!TYPESECURITYCHECK(responseDic, [NSDictionary class])) {
        return NO;
    }
    
    __block typeof(self) weekSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        int iStatus = [[responseDic objectForKey:@"status"] intValue];
        NSString * nssRequestCode = [responseDic objectForKey:@"code"];
        NSString * nssMsg = [responseDic objectForKey:@"msg"];
        id data = [responseDic objectForKey:@"data"];
        
        NSLog(@"cacheFinished, status:%dd, code:%@ msg:%@\ndata:%@", iStatus, nssRequestCode, nssMsg, data);
        if (weekSelf.httpResponseDelegate && ([weekSelf.httpResponseDelegate respondsToSelector:@selector(processHttpResponseData:status:message:data:)])) {
            [weekSelf.httpResponseDelegate processHttpResponseData:nssRequestCode status:iStatus message:nssMsg data:data];
        }
        
    });
    return YES;
}
// 测试本地数据
- (BOOL)hasTestData:(NSString *)code{
    if (!TYPESECURITYCHECK(code, [NSString class])) {
        return NO;
    }
    
    NSString *testDataPath = [[NSBundle mainBundle] pathForResource:@"testData" ofType:@"plist"];
    NSArray *testDataArray = [NSArray arrayWithContentsOfFile:testDataPath];
    
    for (NSDictionary *testDataDic in testDataArray) {
        if (testDataDic.allKeys.count > 0) {
            if ([code isEqualToString:[testDataDic objectForKey:@"code"]]) {
                int iStatus = [[testDataDic objectForKey:@"status"] intValue];
                NSString * nssRequestCode = [testDataDic objectForKey:@"code"];
                NSString * nssMsg = [testDataDic objectForKey:@"msg"];
                id data = [testDataDic objectForKey:@"data"];
                if (data) {
                    if (self.httpResponseDelegate && ([self.httpResponseDelegate respondsToSelector:@selector(processHttpResponseData:status:message:data:)])) {
                        [self.httpResponseDelegate processHttpResponseData:nssRequestCode status:iStatus message:nssMsg data:data];
                    }
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)httpRequestWithURL:(NSString *)nssUrl requestDic:(NSMutableDictionary *)dicForRequest{
    if (self.retriveTestData && [self hasTestData:[dicForRequest objectForKey:@"action"]]) {
        return;
    }
    // 先检查是否有缓存
    if ([self hasCacheWithParams:dicForRequest] && [self shouldCache]) {
        return;
    }
    // 时间戳
    NSString *nssStampValue = [NSString stringWithFormat:@"%@",[self getTimeStamp]];
    // 拼接请求参数(公参)
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dicForRequest];
    [params setObject:@"appkey" forKey:@"app_key"];
    [params setObject:@"uuid" forKey:@"uuid"];
    [params setObject:@"appVersion" forKey:@"version"];
    [params setObject:@"ios" forKey:@"platform"];
    [params setObject:nssStampValue forKey:@"timestamp"];
    
    __block typeof(self) weekSelf = self;
    
    ELAPIProxy *apiProxy = [ELAPIProxy sharedInstance];
    
    NSURLSessionDataTask *task = [apiProxy postRequestWithUrl:nssUrl paramsDic:params responseBlock:^(NSDictionary *responseDic, HQURLResponseStatus status) {
        if (weekSelf == nil) {
            return;
        }
        if (status == KEnumURLResponseStatusErrorCancell) {
            return;
        }
        if (status == KEnumURLResponseStatusSuccess) {
            if (responseDic) {
                if ([weekSelf shouldCache]) {
                    NSData *cacheData = [NSJSONSerialization dataWithJSONObject:responseDic options:NSJSONWritingPrettyPrinted error:nil];
                    [weekSelf.cache saveCacheWithData:cacheData methodName:[params objectForKey:@"action"] requestParams:dicForRequest];
                }
                int iStatus = [[responseDic objectForKey:@"status"] intValue];
                NSString * nssRequestCode = [responseDic objectForKey:@"code"];
                NSString * nssMsg = [responseDic objectForKey:@"msg"];
                id data = [responseDic objectForKey:@"data"];
                
                NSLog(@"requestFinished, status:%d, code:%@ msg:%@\ndata:%@", iStatus, nssRequestCode, nssMsg, data);
                
                if (weekSelf.httpResponseDelegate && [weekSelf.httpResponseDelegate respondsToSelector:@selector(processHttpResponseData:status:message:data:)]) {
                    [weekSelf.httpResponseDelegate processHttpResponseData:nssRequestCode status:iStatus message:nssMsg data:data];
                }
                return;
            }
        }
        if (weekSelf.httpResponseDelegate && [weekSelf.httpResponseDelegate respondsToSelector:@selector(processHttpResponseData:status:message:data:)]) {
            [weekSelf.httpResponseDelegate processHttpResponseData:[params objectForKey:@"action"] status:-1000 message:nil data:nil];
        }
    }];
    [m_arrRequest addObject:task];
}
#pragma mark -- 各个业务模块

- (void)getSmsCodeForRegisterCode:(NSString *)phoneNumber{
    NSString * nssActionValue = @"VETIFI-ATION";
// 基地址 + 该业务的接口
    NSString * nssUrl = [NSString stringWithFormat:@"%@%@?",m_nssUrl, @"/service/note/noteObtain.do"];
    NSMutableDictionary *dicRequest = [[NSMutableDictionary alloc] init];
    [dicRequest setObject:nssActionValue forKey:@"action"];
    [dicRequest setObject:phoneNumber forKey:@"login_account"];
    [self httpRequestWithURL:nssUrl requestDic:dicRequest];
}

@end
