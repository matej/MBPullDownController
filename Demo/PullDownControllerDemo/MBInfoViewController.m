//
//  MBInfoViewController.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBInfoViewController.h"

@interface MBInfoViewController()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeight;
@property (nonatomic, assign) BOOL firstLayoutCalled;

@end


@implementation MBInfoViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	self.backButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:24];
	[self.backButton setTitle:@"\uf0a8" forState:UIControlStateNormal];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.firstLayoutCalled) {
        [self updateTopBarLayout];
        self.firstLayoutCalled = YES;
    }
}

- (void)updateTopBarLayout {
    self.topBarHeight.constant = 44.f;
    if (@available(iOS 11, *)) {
        self.topBarHeight.constant += self.view.safeAreaInsets.top;
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self updateTopBarLayout];
}

#pragma mark - Actions

- (IBAction)backPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
