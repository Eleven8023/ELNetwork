//
//  ELNetworkCache.h
//  ELNetWork
//
//  Created by Eleven on 17/1/5.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELNetworkCachedObject.h"

@interface ELNetworkCache : NSObject

+ (instancetype)shareInstance;

- (NSString *)keyWithMethodName:(NSString *)methodName
                  requestParams:(NSDictionary *)requestParams;
- (NSData *)fetchCachedDataWithMethodName:(NSString *)methodName
                            requestParams:(NSDictionary *)requestParams;

- (void)saveCacheWithData:(NSData *)cachedData
               methodName:(NSString *)methodName
            requestParams:(NSDictionary *)requestParams;

- (void)deleteCacheWithMethodName:(NSString *)methodName
                    requestParams:(NSDictionary *)requestParams;

- (NSData *)fethchCachedDataWithKey:(NSString *)key;
- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key;
- (void)deleteCacheWithKey:(NSString *)key;
- (void)clean;

@end
