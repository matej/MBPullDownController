//
//  MBAppDelegate.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Guerrilla Code. All rights reserved.
//

#import "MBAppDelegate.h"
#import "MBPullDownController.h"
#import "MBFrontViewController.h"
#import "MBBackViewController.h"


@implementation MBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = [self setUpViewControllerHierarchy];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIViewController *)setUpViewControllerHierarchy {
	MBFrontViewController *front = [[MBFrontViewController alloc] init];
	MBBackViewController *back = [[MBBackViewController alloc] init];
	MBPullDownController *pullDownController = [[MBPullDownController alloc] initWithFrontController:front backController:back];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pullDownController];
	navigationController.navigationBarHidden = YES;
	return navigationController;
}

@end
