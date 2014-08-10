//
//  SleakExampleViewController.m
//  Example
//
//  Created by Jason Silberman on 8/10/14.
//  Copyright (c) 2014 Jason Silberman. All rights reserved.
//

#import "SleakExampleViewController.h"

#import "SleakAuthentication.h"

@interface SleakExampleViewController ()

@property (nonatomic) NSURLSessionDataTask *task;

@end

@implementation SleakExampleViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blueColor];
	self.title = @"Loading...";
	
	NSURLSession *sharedSession = [NSURLSession sharedSession];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost/sleak-auth-example/"]];
	
	static NSString *const PRIVATE_KEY = @"tGupPBruGcAj87LtP6YzVeYGg2vZH96yA6BXEqHJip2dfM83Kh";
	static NSString *const APP_ID = @"dfak3773hdjS";
	
	NSDictionary *params = @{};
	
	request = [[SleakAuthentication urlRequest:request withParameters:params applicationId:APP_ID privateKey:PRIVATE_KEY] mutableCopy];
	
	self.task = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		NSLog(@"Complete");
		dispatch_async(dispatch_get_main_queue(), ^{
			self.title = @"Done";
		});
		NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
		NSLog(@"Response: %@", responseDictionary);
		if ([responseDictionary[@"status"] isEqualToString:@"failed"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.view.backgroundColor = [UIColor redColor];
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				self.view.backgroundColor = [UIColor greenColor];
			});
		}
	}];
	
	[self.task resume];
	
}

@end
