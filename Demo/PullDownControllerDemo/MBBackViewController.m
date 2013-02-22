//
//  MBBackViewController.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Guerrilla Code. All rights reserved.
//

#import "MBBackViewController.h"
#import "MBBackViewCell.h"


static NSUInteger const kNumbeOfItems = 30;
static NSString * const kBackViewCellId = @"BackViewCell";


@implementation MBBackViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.collectionView registerClass:[MBBackViewCell class] forCellWithReuseIdentifier:kBackViewCellId];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return kNumbeOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBackViewCellId forIndexPath:indexPath];
	return cell;
}

@end
