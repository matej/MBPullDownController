//
//  MBBackViewCell.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Guerrilla Code. All rights reserved.
//

#import "MBBackViewCell.h"

@implementation MBBackViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor colorWithWhite:.9f alpha:1.f];
    }
    return self;
}

@end
