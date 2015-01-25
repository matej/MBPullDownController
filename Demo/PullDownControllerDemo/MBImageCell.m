//
//  MBImageCell.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 24. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBImageCell.h"
#import "MBImagesViewController.h"
#import <QuartzCore/QuartzCore.h>


static NSString * const kImageFadeAnimationKey = @"imageFade";


@interface MBImageCell ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;

@end


@implementation MBImageCell

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor colorWithWhite:.95f alpha:1.f];
		[self setUpContentView];
    }
    return self;
}

#pragma mark - Suviews

- (void)setUpContentView {
	UIView *contentView = self.contentView;
	CGRect imageFrame = CGRectInset(contentView.bounds, 5.f, 5.f);
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
	imageView.backgroundColor = [UIColor colorWithWhite:.98f alpha:1.f];
	[contentView addSubview:imageView];
	_imageView = imageView;
	UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
	indicator.center = imageView.center;
	indicator.frame = CGRectIntegral(indicator.frame);
	[contentView addSubview:indicator];
	_activityIndicator = indicator;
}

#pragma mark - Reuse

- (void)prepareForReuse {
	[self.connection cancel];
	self.connection = nil;
	self.responseData = nil;
	[self.imageView.layer removeAnimationForKey:kImageFadeAnimationKey];
	self.imageView.image = nil;
	_URL = nil;
	[self.activityIndicator stopAnimating];
}

#pragma mark - Image

- (void)setURL:(NSURL *)URL {
	if (_URL != URL) {
		_URL = URL;
		if (URL) {
			[self loadImageAt:URL];
		}
	}
}

- (void)loadImageAt:(NSURL *)url {
	UIImage *cachedImage = [[MBImagesViewController cache] objectForKey:url];
	if (cachedImage) {
		[self setImage:cachedImage animated:NO];
	} else {
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
		self.connection = connection;
		[connection start];
		[self.activityIndicator startAnimating];
	}
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
	self.imageView.image = image;
	if (animated) {
		CATransition *animation = [CATransition animation];
		[[self.imageView layer] addAnimation:animation forKey:kImageFadeAnimationKey];
	}
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    self.responseData = [[NSMutableData alloc]init];
	NSInteger code = [response statusCode];
	if (code != 200) {
		[connection cancel];
		NSDictionary *info = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid response code (%ld).", (long)code]};
		NSError *error = [NSError errorWithDomain:@"MBImageCell" code:code userInfo:info];
		[self connection:connection didFailWithError:error];
	}
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
	NSLog(@"Image load error: %@", error);
	[self.activityIndicator stopAnimating];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	UIImage *image = [UIImage imageWithData:self.responseData];
	[self setImage:image animated:YES];
	if (image) {
		[[MBImagesViewController cache] setObject:image forKey:connection.originalRequest.URL];
	}
	[self.activityIndicator stopAnimating];
	self.responseData = nil;
}

@end
