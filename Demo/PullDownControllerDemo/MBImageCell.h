//
//  MBImageCell.h
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 24. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MBImageCell : UICollectionViewCell <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, retain, readonly) UIActivityIndicatorView *activityIndicator;

@end
