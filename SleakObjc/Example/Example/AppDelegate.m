//
//  AppDelegate.m
//  Example
//
//  Created by Jason Silberman on 8/10/14.
//  Copyright (c) 2014 Jason Silberman. All rights reserved.
//

#import "AppDelegate.h"

#import "SleakExampleViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[SleakExampleViewController alloc] init]];
	
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	return YES;
}

@end
