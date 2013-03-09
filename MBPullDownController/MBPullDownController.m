//
//  MBPullDownController.m
//  MBPullDownController
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBPullDownController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <objc/runtime.h>
#import <objc/message.h>


static CGFloat const kDefaultClosedTopOffset = 44.f;
static CGFloat const kDefaultOpenBottomOffset = 44.f;
static CGFloat const kDefaultOpenDragOffset = 100.f;
static CGFloat const kDefaultCloseDragOffset = 44.f;


@interface MBPullDownController ()

@property MBPullDownControllerTapUpRecognizer *tapUpRecognizer;

@end


@implementation MBPullDownController

#pragma mark - Lifecycle

- (id)init {
	return [self initWithFrontController:nil backController:nil];
}

- (id)initWithFrontController:(UIViewController *)front backController:(UIViewController *)back {
	self = [super init];
	if (self) {
		_frontController = front;
		_backController = back;
		_pullToToggleEnabled = YES;
		_closedTopOffset = kDefaultClosedTopOffset;
		_openBottomOffset = kDefaultOpenBottomOffset;
		_openDragOffset = kDefaultOpenDragOffset;
		_closeDragOffset = kDefaultCloseDragOffset;
		_backgroundView = [MBPullDownControllerBackgroundView new];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self changeBackControllerFrom:nil to:self.backController];
	[self changeFrontControllerFrom:nil to:self.frontController];
}

- (void)dealloc {
	[self cleanUpScrollView:[self scrollView]];
}

#pragma mark - Controllers

- (void)setFrontController:(UIViewController *)frontController {
	if (_frontController != frontController) {
		UIViewController *oldController = _frontController;
		_frontController = frontController;
		if (self.isViewLoaded) {
			[self changeFrontControllerFrom:oldController to:frontController];
		}
	}
}

- (void)setBackController:(UIViewController *)backController {
	if (_backController != backController) {
		UIViewController *oldController = _backController;
		_backController = backController;
		if (self.isViewLoaded) {
			[self changeBackControllerFrom:oldController to:backController];
		}
	}
}

#pragma mark - Open / close offsets

- (void)setClosedTopOffset:(CGFloat)closedTopOffset {
	[self setClosedTopOffset:closedTopOffset animated:NO];
}

- (void)setClosedTopOffset:(CGFloat)closedTopOffset animated:(BOOL)animated {
	if (_closedTopOffset != closedTopOffset) {
		_closedTopOffset = closedTopOffset;
		if (!self.open) {
			[self setOpen:NO animated:animated];
		}
	}
}

- (void)setOpenBottomOffset:(CGFloat)openBottomOffset {
	[self setOpenBottomOffset:openBottomOffset animated:NO];
}

- (void)setOpenBottomOffset:(CGFloat)openBottomOffset animated:(BOOL)animated {
	if (_openBottomOffset != openBottomOffset) {
		_openBottomOffset = openBottomOffset;
		if (self.open) {
			[self setOpen:YES animated:animated];
		}
	}
}

#pragma mark - Open / close actions

- (void)toggleOpenAnimated:(BOOL)animated {
	[self setOpen:!_open animated:animated];
}

- (void)setOpen:(BOOL)open {
	[self setOpen:open animated:NO];
}

- (void)setOpen:(BOOL)open animated:(BOOL)animated {
	[self willChangeValueForKey:@"open"];
	_open = open;
	[self didChangeValueForKey:@"open"];
	UIScrollView *scrollView = [self scrollView];
	CGFloat offset = open ? self.view.bounds.size.height - self.openBottomOffset : self.closedTopOffset;
	
	void (^updateInserts)(void) = ^{
		UIEdgeInsets contentInset = scrollView.contentInset;
		contentInset.top = offset;
		scrollView.contentInset = contentInset;
		UIEdgeInsets scrollIndicatorInsets = scrollView.scrollIndicatorInsets;
		scrollIndicatorInsets.top = offset;
		scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
	};
	
	if (open) {
		updateInserts();
	} else {
		if (animated) {
			[UIView animateWithDuration:.3f animations:updateInserts];
		} else {
			updateInserts();
		}
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[scrollView setContentOffset:CGPointMake(0.f, -offset) animated:animated];
	});
}

#pragma mark - Container controller

- (void)changeFrontControllerFrom:(UIViewController *)current to:(UIViewController *)new {

	[current removeFromParentViewController];
	[self cleanUpScrollView:(UIScrollView *)current.view];
	[current.view removeFromSuperview];
	
	if (new) {
		[self addChildViewController:new];
		UIView *containerView = self.view;
		UIView *newView = new.view;
		NSString *message = @"The front controller's view is not a UIScrollView subclass.";
		NSAssert(!newView || [newView isKindOfClass:[UIScrollView class]], message);
		if (newView) {
			newView.frame = containerView.bounds;
			[containerView addSubview:newView];
		}
	}
	
	[self prepareScrollView:(UIScrollView *)new.view];
	[self setOpen:NO animated:NO];
}

- (void)changeBackControllerFrom:(UIViewController *)current to:(UIViewController *)new {

	[current removeFromParentViewController];
	[current.view removeFromSuperview];
	
	if (new) {
		[self addChildViewController:new];
		UIView *containerView = self.view;
		UIView *newView = new.view;
		if (newView) {
			newView.frame = containerView.bounds;
			[containerView insertSubview:newView atIndex:0];
		}
	}
}

#pragma mark - BacgroundView

- (void)setBackgroundView:(UIView *)backgroundView {
	[_backgroundView removeFromSuperview];
	_backgroundView = backgroundView;
	[self initializeBackgroundView];
}

- (void)initializeBackgroundView {
	UIView *containerView = self.view;
	UIView *backgroundView = self.backgroundView;
	UIScrollView *scrollView = [self scrollView];
	if (scrollView && backgroundView) {
		backgroundView.frame = containerView.bounds;
		[containerView insertSubview:backgroundView belowSubview:scrollView];
		[self updateBackgroundViewForScrollOfset:scrollView.contentOffset];
	}
}

- (void)updateBackgroundViewForScrollOfset:(CGPoint)offset {
	CGRect frame = self.backgroundView.frame;
	frame.origin.y = MAX(0.f, -offset.y);
	self.backgroundView.frame = frame;
}

#pragma mark - ScrollView

- (UIScrollView *)scrollView {
	return (UIScrollView *)self.frontController.view;
}

- (void)prepareScrollView:(UIScrollView *)scrollView {
	if (scrollView) {
		scrollView.backgroundColor = [UIColor clearColor];
		scrollView.alwaysBounceVertical = YES;
		[self swizzleHitTestForScrollView:scrollView revert:NO];
		[self registerForScrollViewKVO:scrollView];
		[self addGestureRecognizersToScrollView:scrollView];
		[self initializeBackgroundView];
	}
}

- (void)cleanUpScrollView:(UIScrollView *)scrollView {
	if (scrollView) {
		[self swizzleHitTestForScrollView:scrollView revert:YES];
		[self unregisterFromScrollViewKVO:scrollView];
		[self.backgroundView removeFromSuperview];
		[self removeGesureRecognizersFromScrollView:scrollView];
	}
}

- (void)swizzleHitTestForScrollView:(UIScrollView *)scrollView revert:(BOOL)revert {
	Class class = [scrollView class];
    SEL originalSelector;
    SEL overrideSelector;
	if (revert) {
		originalSelector = @selector(hitTest:withEvent:);
		overrideSelector = @selector(MBPullDownControllerHitTest:withEvent:);
	} else {
		originalSelector = @selector(MBPullDownControllerHitTest:withEvent:);
		overrideSelector = @selector(hitTest:withEvent:);
	}
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method overrideMethod = class_getInstanceMethod(class, overrideSelector);
	IMP overrideImp = method_getImplementation(overrideMethod);
	const char *overrideType = method_getTypeEncoding(overrideMethod);
	IMP originalImp = method_getImplementation(originalMethod);
	const char *originalType = method_getTypeEncoding(originalMethod);
    if (class_addMethod(class, originalSelector, overrideImp, overrideType)) {
		class_replaceMethod(class, overrideSelector, originalImp, originalType);
    } else {
		method_exchangeImplementations(originalMethod, overrideMethod);
    }
}

- (void)checkOpenCloseConstraints {
	BOOL open = self.open;
	BOOL enabled = self.pullToToggleEnabled;
	CGPoint offset = [self scrollView].contentOffset;
	if (!open && enabled && offset.y < - self.openDragOffset - self.closedTopOffset) {
		[self setOpen:YES animated:YES];
	} else if (open) {
		if (enabled && offset.y > self.closeDragOffset - self.view.bounds.size.height + self.openBottomOffset) {
			[self setOpen:NO animated:YES];
		} else {
			[self setOpen:YES animated:YES];
		}
	}
}

#pragma mark - Gestures

- (void)addGestureRecognizersToScrollView:(UIScrollView *)scrollView {
	MBPullDownControllerTapUpRecognizer *tapUp;
	tapUp = [[MBPullDownControllerTapUpRecognizer alloc] initWithTarget:self action:@selector(tapUp:)];
	[scrollView addGestureRecognizer:tapUp];
	self.tapUpRecognizer = tapUp;
}

- (void)removeGesureRecognizersFromScrollView:(UIScrollView *)scrollView {
	[scrollView removeGestureRecognizer:self.tapUpRecognizer];
}

- (void)tapUp:(MBPullDownControllerTapUpRecognizer *)recognizer {
	[self checkOpenCloseConstraints];
}

#pragma mark - KVO

- (void)registerForScrollViewKVO:(UIScrollView *)scrollView {
	[scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unregisterFromScrollViewKVO:(UIScrollView *)scrollView {
	[scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"contentOffset"]) {
		[self updateBackgroundViewForScrollOfset:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
	}
}

@end


@implementation UIViewController (MBPullDownController)

- (MBPullDownController *)pullDownController {
	UIViewController *controller = self;
	while (controller != nil) {
		if ([controller isKindOfClass:[MBPullDownController class]]) {
			return (MBPullDownController *)controller;
		}
		controller = controller.parentViewController;
	}
	return nil;
}

@end


@implementation MBPullDownControllerTapUpRecognizer

#pragma mark - Lifecycle

- (id)initWithTarget:(id)target action:(SEL)action {
	self = [super initWithTarget:target action:action];
	if (self) {
		self.cancelsTouchesInView = NO;
		self.delaysTouchesBegan = NO;
		self.delaysTouchesEnded = NO;
	}
	return self;
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.state = UIGestureRecognizerStateRecognized;
	self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.state = UIGestureRecognizerStateRecognized;
	self.state = UIGestureRecognizerStateEnded;
}

#pragma mark - Tap prevention

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
	return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	return NO;
}

@end


@interface UIScrollView (MBPullDownControllerHitTest)

- (UIView *)MBPullDownControllerHitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end


@implementation UIScrollView (MBPullDownControllerHitTest)

- (UIView *)MBPullDownControllerHitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (point.y <= 0.f) {
		return nil;
	}
	return [self MBPullDownControllerHitTest:point withEvent:event];
}

@end


@implementation MBPullDownControllerBackgroundView

#pragma mark - Lifecycle

- (id)init {
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.dropShadowVisible = YES;
	}
	return self;
}

#pragma mark - Shadow

- (void)setDropShadowVisible:(BOOL)dropShadowVisible {
	if (_dropShadowVisible != dropShadowVisible) {
		CALayer *layer = self.layer;
		layer.shadowOffset = CGSizeMake(0, -5);
		layer.shadowRadius = 5;
		layer.shadowOpacity = dropShadowVisible ? .2f : 0.f;
		[self setNeedsLayout];
		_dropShadowVisible = dropShadowVisible;
	}
}

#pragma mark - Layout

- (void)layoutSubviews {
	[super layoutSubviews];
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

@end

