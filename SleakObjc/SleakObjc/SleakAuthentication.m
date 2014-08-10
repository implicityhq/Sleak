//
//  SleakAuthentication.m
//  Example
//
//  Created by Jason Silberman on 8/10/14.
//  Copyright (c) 2014 Jason Silberman. All rights reserved.
//

NSString *const kSleakApplicationIdKey = @"x-sleak-application-id";
NSString *const kSleakTimestampKey = @"x-sleak-timestamp";
NSString *const kSleakNonceKey = @"x-sleak-nonce";
NSString *const kSleakScheme = @"Sleak";
NSString *const kSleakAuthorizationKey = @"Authorization";

#import <CommonCrypto/CommonHMAC.h>
#import <OrderedDictionary/OrderedDictionary.h>

#import "SleakAuthentication.h"

NSData *hmacForKeyAndData(NSString *key, NSString *data) {
	const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
	const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
	return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

NSString *randomStringOfLength(NSUInteger length) {
	NSMutableString *string = [NSMutableString stringWithCapacity:length];
	
	for (int i=0; i<length; i++) {
		[string appendFormat:@"%c", arc4random_uniform(26) + 'a'];
	}
	
	return string;
}

NSString *formEncodedString(NSString *string) {
	NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\"";
	NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
	NSString *encodedString = [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
	return [encodedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

NSString *queryStringValue(MutableOrderedDictionary *mutableOrderedDictionary) {
	NSMutableArray *pairs = [@[] mutableCopy];
	[mutableOrderedDictionary enumerateKeysAndObjectsWithIndexUsingBlock:^(id key, id value, NSUInteger idx, BOOL *stop) {
		NSString *escapedValue = [value isKindOfClass:[NSString class]] ? formEncodedString(value) : value;
		[pairs insertObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue] atIndex:idx];
	}];
	return [pairs componentsJoinedByString:@"&"];
}

@implementation SleakAuthentication

+ (NSURLRequest *)urlRequest:(NSURLRequest *)request withParameters:(NSDictionary *)parameters applicationId:(NSString *)applicationId privateKey:(NSString *)privateKey {
	NSMutableURLRequest *mutableRequest = [request mutableCopy];
	
	NSData *hmacData;
	
	NSString *randomString = randomStringOfLength(8);
	NSInteger date = [[[NSDate alloc] init] timeIntervalSince1970];
	
	NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
	
	MutableOrderedDictionary *info = [MutableOrderedDictionary new];
	
	[sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = [parameters objectForKey:obj];
		[info insertObject:value forKey:obj atIndex:idx];
	}];
	
	[info setObject:applicationId forKey:kSleakApplicationIdKey];
	[info setObject:@(date) forKey:kSleakTimestampKey];
	[info setObject:randomString forKey:kSleakNonceKey];
	
	NSString *queryString = queryStringValue(info);
	hmacData = hmacForKeyAndData(privateKey, queryString);
	
	NSString *sleakAuthorizationString = [NSString stringWithFormat:@"%@ %@, auth_nonce=\"%@\", auth_timestamp=\"%li\"", kSleakScheme, hmacData, randomString, (long)date];
	
	NSLog(@"%@", sleakAuthorizationString);
	
	[mutableRequest setValue:sleakAuthorizationString forHTTPHeaderField:kSleakAuthorizationKey];
	[mutableRequest setValue:applicationId forHTTPHeaderField:kSleakApplicationIdKey];
	
	return mutableRequest;
}

@end
