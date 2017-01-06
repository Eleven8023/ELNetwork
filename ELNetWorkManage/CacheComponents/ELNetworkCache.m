//
//  ELNetworkCache.m
//  ELNetWork
//
//  Created by Eleven on 17/1/5.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import "ELNetworkCache.h"
#import "NSDictionary+SFNetworkingMethods.h"

@interface ELNetworkCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation ELNetworkCache

- (NSCache *)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = CACHECOUNTLIMIT;
    }
    return _cache;
}

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static ELNetworkCache *shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[ELNetworkCache alloc] init];
    });
    return shareInstance;
}

#pragma mark -- public method
- (NSData *)fetchCachedDataWithMethodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    return [self fethchCachedDataWithKey:[self keyWithMethodName:methodName requestParams:requestParams]];
}

- (void)saveCacheWithData:(NSData *)cachedData methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    [self saveCacheWithData:cachedData key:[self keyWithMethodName:methodName requestParams:requestParams]];
}

- (void)deleteCacheWithMethodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    [self deleteCacheWithKey:[self keyWithMethodName:methodName requestParams:requestParams]];
}

- (NSData *)fethchCachedDataWithKey:(NSString *)key{
    ELNetworkCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject.isOutDated || cachedObject.isEmpty) {
        return nil;
    }else{
        return cachedObject.content;
    }
}

- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key{
    ELNetworkCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject == nil) {
        cachedObject = [[ELNetworkCachedObject alloc] init];
    }
    [cachedObject updateContent:cachedData];
    [self.cache setObject:cachedObject forKey:key];
}

- (void)deleteCacheWithKey:(NSString *)key{
    [self.cache removeObjectForKey:key];
}

- (void)clean{
    [self.cache removeAllObjects];
}

- (NSString *)keyWithMethodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams{
    return [NSString stringWithFormat:@"%@%@",methodName,[requestParams SF_urlParamsStringSignature:NO]];
}

@end
