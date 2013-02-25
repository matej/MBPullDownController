//
//  MBInfoViewController.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBInfoViewController.h"


@implementation MBInfoViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.backButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:24];
	[self.backButton setTitle:@"\uf0a8" forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)backPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
