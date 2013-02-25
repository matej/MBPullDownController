//
//  MBAppDelegate.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBAppDelegate.h"
#import "MBPullDownController.h"
#import "MBImagesViewController.h"
#import "MBSettingsController.h"


@implementation MBAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = [self setUpViewControllerHierarchy];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Controllers

- (UIViewController *)setUpViewControllerHierarchy {
	MBImagesViewController *front = [[MBImagesViewController alloc] init];
	MBSettingsController *back = [[MBSettingsController alloc] init];
	MBPullDownController *pullDownController = [[MBPullDownController alloc] initWithFrontController:front backController:back];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pullDownController];
	navigationController.navigationBarHidden = YES;
	return navigationController;
}

@end
