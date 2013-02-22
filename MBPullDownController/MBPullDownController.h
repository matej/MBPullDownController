//
//  MBPullDownController.h
//  MBPullDownController
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Guerrilla Code. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MBPullDownController : UIViewController

@property (nonatomic, strong) UIViewController *frontController;
@property (nonatomic, strong) UIViewController *backController;
@property (nonatomic, assign) CGFloat closedTopOffset;
@property (nonatomic, assign) CGFloat openBottomOffset;
@property (nonatomic, assign, readonly) BOOL open;
@property (nonatomic, strong) UIView *backgroundView;

- (id)initWithFrontController:(UIViewController *)front backController:(UIViewController *)back;
- (void)toggleOpenAnimated:(BOOL)animated;
- (void)setOpen:(BOOL)open animated:(BOOL)animated;

@end


@interface MBPullDownControllerBackgroundView : UIView

@property (nonatomic, assign) BOOL dropShadowVisible;

@end


@interface MBPullDownControllerTapUpRecognizer : UITapGestureRecognizer

@end