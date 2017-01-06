//
//  NSDictionary+AXNetworkingMethods.h
//  RTNetworking
//
//  Created by casa on 14-5-6.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SFNetworkingMethods)

- (NSString *)SF_urlParamsStringSignature:(BOOL)isForSignature;
- (NSString *)SF_jsonString;
- (NSArray *)SF_transformedUrlParamsArraySignature:(BOOL)isForSignature;

@end
