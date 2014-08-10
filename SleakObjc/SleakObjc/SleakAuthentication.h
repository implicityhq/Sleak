//
//  SleakAuthentication.h
//  Example
//
//  Created by Jason Silberman on 8/10/14.
//  Copyright (c) 2014 Jason Silberman. All rights reserved.
//

@import Foundation;

@interface SleakAuthentication : NSObject

+ (NSURLRequest *)urlRequest:(NSURLRequest *)request withParameters:(NSDictionary *)parameters applicationId:(NSString *)applicationId privateKey:(NSString *)privateKey;

@end
