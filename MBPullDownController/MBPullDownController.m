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

static NSInteger const kContainerViewTag = -1000001;


@interface MBPullDownController ()

@property (nonatomic, strong) MBPullDownControllerTapUpRecognizer *tapUpRecognizer;
@property (nonatomic, assign) BOOL adjustedScroll;

@end


@interface UIScrollView (MBPullDownControllerHitTest)

+ (void)_MB_SwizzleHitTestForUIScrollView;

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
		[self sharedInitialization];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self sharedInitialization];
	}
	return self;
}

- (void)sharedInitialization {
	_pullToToggleEnabled = YES;
	_closedTopOffset = kDefaultClosedTopOffset;
	_openBottomOffset = kDefaultOpenBottomOffset;
	_openDragOffset = kDefaultOpenDragOffset;
	_closeDragOffset = kDefaultCloseDragOffset;
	_backgroundView = [MBPullDownControllerBackgroundView new];
	[[self class] updateInstanceCount:1];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.tag = kContainerViewTag;
	[self changeBackControllerFrom:nil to:self.backController];
	[self changeFrontControllerFrom:nil to:self.frontController];
}

- (void)dealloc {
	[self cleanUpScrollView:[self scrollView]];
	[[self class] updateInstanceCount:-1];
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
	if (open != _open) {
		[self willChangeValueForKey:@"open"];
		_open = open;
		[self didChangeValueForKey:@"open"];
	}
	
	UIScrollView *scrollView = [self scrollView];
	if (!scrollView) {
		return;
	}
	
	CGFloat offset = open ? self.view.bounds.size.height - self.openBottomOffset : self.closedTopOffset;
	CGPoint sOffset = scrollView.contentOffset;
	// Set content inset (no animation)
	UIEdgeInsets contentInset = scrollView.contentInset;
	contentInset.top = offset;
	scrollView.contentInset = contentInset;
	// Restor the previous scroll offset, sicne the contentInset change coud had changed it
	[scrollView setContentOffset:sOffset];
	
	// Update the scroll indicator insets
	void (^updateScrollInsets)(void) = ^{
		UIEdgeInsets scrollIndicatorInsets = scrollView.scrollIndicatorInsets;
		scrollIndicatorInsets.top = offset;
		scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
	};
	if (animated) {
		[UIView animateWithDuration:.3f animations:updateScrollInsets];
	} else {
		updateScrollInsets();
	}
	
	// Move the content
	if (animated) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[scrollView setContentOffset:CGPointMake(0.f, -offset) animated:YES];
		});
	} else {
		[scrollView setContentOffset:CGPointMake(0.f, -offset)];
	}
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
			[new didMoveToParentViewController:self];
		}
	}
	
	[self prepareScrollView:(UIScrollView *)new.view];
	[self setOpen:self.open animated:NO];
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
			[new didMoveToParentViewController:self];
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
		[self registerForScrollViewKVO:scrollView];
		[self addGestureRecognizersToScrollView:scrollView];
		[self initializeBackgroundView];
	}
}

- (void)cleanUpScrollView:(UIScrollView *)scrollView {
	if (scrollView) {
		[self unregisterFromScrollViewKVO:scrollView];
		[self.backgroundView removeFromSuperview];
		[self removeGesureRecognizersFromScrollView:scrollView];
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

+ (void)updateInstanceCount:(NSInteger)update {
	static NSInteger count = 0;
	if ((count == 0 && update == 1) || (count == 1 && update == -1)) {
		[UIScrollView _MB_SwizzleHitTestForUIScrollView];
	}
	count = MAX(0, count + update);
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
	self.adjustedScroll = NO;
	[scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)unregisterFromScrollViewKVO:(UIScrollView *)scrollView {
	[scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"contentOffset"]) {
		if (!self.adjustedScroll) {
			CGPoint oldValue = [[change valueForKey:NSKeyValueChangeOldKey] CGPointValue];
			CGPoint newValue = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
			CGPoint adjusted = newValue;
			// Simulate the scroll view elasticity effect while dragging in the open state
			if (self.open && [self scrollView].dragging) {
				CGFloat delta = roundf((oldValue.y - newValue.y) / 3);
				adjusted = CGPointMake(newValue.x, oldValue.y - delta);
				self.adjustedScroll = YES; // prevent infinite recursion
				[self scrollView].contentOffset = adjusted;
			}
			[self updateBackgroundViewForScrollOfset:adjusted];
		} else {
			self.adjustedScroll = NO;
		}
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


@implementation UIScrollView (MBPullDownControllerHitTest)

+ (void)_MB_SwizzleHitTestForUIScrollView {
	Class class = [UIScrollView class];
    SEL originalSelector = @selector(_MB_PullDownControllerHitTest:withEvent:);
    SEL overrideSelector = @selector(hitTest:withEvent:);
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

- (UIView *)_MB_PullDownControllerHitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (point.y <= 0.f && self.superview.tag == kContainerViewTag) {
		return nil;
	}
	return [self _MB_PullDownControllerHitTest:point withEvent:event];
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
