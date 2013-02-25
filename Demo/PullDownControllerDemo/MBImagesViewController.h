//
//  MBImagesViewController.h
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 24. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MBImagesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (copy, nonatomic) NSString *imageCategory;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

+ (NSCache *)cache;
- (void)reload;

@end
