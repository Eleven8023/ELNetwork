//
//  NSArray+AXNetworkingMethods.m
//  RTNetworking
//
//  Created by casa on 14-5-13.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import "NSArray+SFNetworkingMethods.h"

@implementation NSArray (SFNetworkingMethods)

/** 字母排序之后形成的参数字符串 */
- (NSString *)SF_paramsString
{
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@", obj];
        } else {
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}

/** 数组变json */
- (NSString *)SF_jsonString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
