//
//  MBPullDownController.h
//  MBPullDownController
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
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

/**
 * The frontmost view controller. The controller's view needs to be a UIScrollView subclass.
 */
@property (nonatomic, strong) UIViewController *frontController;

/**
 * The background view controller, positioned behind the frontController.
 */
@property (nonatomic, strong) UIViewController *backController;

/**
 * Enables or disables pull the pull to open or close interaction.
 * Defaults to YES;
 */
@property (nonatomic, assign) BOOL pullToToggleEnabled;

/**
 * The front controller offset from the top of the view, when in the closed state.
 * Defaults to 44.f.
 * @see setClosedTopOffset:animated:
 */
@property (nonatomic, assign) CGFloat closedTopOffset;

/**
 * The front controller offset from the bottom of the view, when in the open state.
 * Defaults to 44.f. 
 * @see setOpenBottomOffset:animated:
 */
@property (nonatomic, assign) CGFloat openBottomOffset;

/**
 * The minimum drag distance required to trigger the open action.
 * Overrides openDragOffsetPercentage when set. 
 * Disabled when det to NAN (default).
 */
@property (nonatomic, assign) CGFloat openDragOffset;

/**
 * The minimum drag distance required to trigged the close action.
 * Overrides closeDragOffsetPercentage when set. 
 * Disabled when det to NAN (default).
 */
@property (nonatomic, assign) CGFloat closeDragOffset;

/**
 * The minimum drag distance required to trigger the open action,
 * expressed as a percentage of the total view height.
 * Valid values from 0.f to 1.f, disabled otherwise. 
 * Defaults to .2f.
 */
@property (nonatomic, assign) CGFloat openDragOffsetPercentage;

/**
 * The minimum drag distance required to trigged the close action,
 * expressed as a percentage of the total view height.
 * Valid values from 0.f to 1.f, disabled otherwise. 
 * Defaults to .05f.
 */
@property (nonatomic, assign) CGFloat closeDragOffsetPercentage;

/**
 * The current state (observable).
 * Defaults to NO. 
 * @see setOpen:animated:
 */
@property (nonatomic, assign) BOOL open;

/**
 * A view that is placed immediately behind frontController.view and scrolled 
 * in accordance with the closedTopOffset and openBottomOffset properties.
 * Defaults to a MBPullDownControllerBackgroundView instance.
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 * The dedicated initializer. 
 * @param frontController A UIViewController to be set as the frontController property. 
 * The controller's view needs to be n UIScrollView subclass.
 * @param frontController A UIViewController to be set as the backController property. 
 */
- (id)initWithFrontController:(UIViewController *)front backController:(UIViewController *)back;

/**
 * Switches from the open to the closed state or vice versa.  
 * @param animated If set to YES, the open or close is animated, otherwise the action is instant. 
 */
- (void)toggleOpenAnimated:(BOOL)animated;

/**
 * Moves the front view controller to the open or closed position.
 * @param open The desired frontController state. If the frontController is 
 * already in the desired state, no action is performed.
 * @param animated If set to YES, the open or close is animated, otherwise the action is instant.
 */
- (void)setOpen:(BOOL)open animated:(BOOL)animated;

/**
 * Sets closedTopOffset and optionally animates the change, if the front controller is in the closed state.
 * @closedTopOffset The front controller offset from the top of the view, when in the closed state.
 * @param animated If set to YES, the offset change is animated, otherwise the action is instant.
 */
- (void)setClosedTopOffset:(CGFloat)closedTopOffset animated:(BOOL)animated;

/**
 * Sets openBottomOffset and optionally animates the change, if the front controller is in the open state.
 * @param openBottomOffset The front controller offset from the bottom of the view, when in the open state.
 * @param animated If set to YES, offset change is animated, otherwise the action is instant.
 */
- (void)setOpenBottomOffset:(CGFloat)openBottomOffset animated:(BOOL)animated;

@end


@interface UIViewController (MBPullDownController)

/**
 * The nearest parent MBPullDownController in the view controllerer hiearrachy 
 * or nil if no MBPullDownController is found.
 */
@property (nonatomic, readonly) MBPullDownController *pullDownController;

@end


@interface MBPullDownControllerBackgroundView : UIView

/**
 * Enables or disables the preset MBPullDownControllerBackgroundView shadow.
 * Defaults to YES. 
 */
@property (nonatomic, assign) BOOL dropShadowVisible;

@end
