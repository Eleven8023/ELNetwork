//
//  NSString+AXNetworkingMethods.m
//  RTNetworking
//
//@author smart_fu
//
//@copyright  © 2016年 smartFu. All rights reserved.
//

#import "NSString+SFNetworkingMethods.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (SFNetworkingMethods)

- (NSString *)SF_md5
{
	NSData* inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	CC_MD5([inputData bytes], (unsigned int)[inputData length], outputData);
	
	NSMutableString* hashStr = [NSMutableString string];
	int i = 0;
	for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
		[hashStr appendFormat:@"%02x", outputData[i]];
	
	return hashStr;
}

@end
