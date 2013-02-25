//
//  MBImagesViewController.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 24. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBImagesViewController.h"
#import "MBImageCell.h"


static NSUInteger const kNumbeOfItems = 42;
static NSString * const kMBImageCellId = @"MBImageCell";
static NSString * const kURLFormat = @"http://lorempixel.com/166/166/%@/%d/";


@implementation MBImagesViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.collectionView registerClass:[MBImageCell class] forCellWithReuseIdentifier:kMBImageCellId];
}

#pragma mark - Cache

+ (NSCache *)cache {
	static NSCache *cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [[NSCache alloc] init];
	});
	return cache;
}

#pragma mark - Category

- (void)setImageCategory:(NSString *)imageCategory {
	if (_imageCategory != imageCategory) {
		_imageCategory = imageCategory;
		[self load];
	}
}

#pragma mark - Loading

- (void)load {
	if (self.imageCategory) {
		[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
	}
}

- (void)reload {
	[[[self class] cache] removeAllObjects];
	[self load];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return kNumbeOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	MBImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMBImageCellId forIndexPath:indexPath];
	cell.URL = [NSURL URLWithString:[NSString stringWithFormat:kURLFormat, self.imageCategory, (indexPath.row % 10) + 1]];
	return cell;
}

@end
