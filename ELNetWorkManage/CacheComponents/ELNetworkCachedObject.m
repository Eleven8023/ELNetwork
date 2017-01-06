//
//  ELNetworkCachedObject.m
//  ELNetWork
//
//  Created by Eleven on 17/1/5.
//  Copyright © 2017年 Eleven. All rights reserved.
//

#import "ELNetworkCachedObject.h"

@interface ELNetworkCachedObject()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation ELNetworkCachedObject

- (BOOL)isEmpty{
    return self.content == nil;
}

- (BOOL)isOutDated{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > NETWORKCONNECTTIMEOUT;
}

- (void)setContent:(NSData *)content{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

- (instancetype)initWithContent:(NSData *)content{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}
#pragma mark -- public method
- (void)updateContent:(NSData *)content{
    self.content = content;
}

@end
