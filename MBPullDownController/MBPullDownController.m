//
//  MBPullDownController.m
//  MBPullDownController
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Guerrilla Code. All rights reserved.
//

#import "MBPullDownController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <objc/runtime.h>
#import <objc/message.h>


static CGFloat const kDefaultClosedTopOffset = 44.f;
static CGFloat const kDefaultOpenBottomOffset = 44.f;


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
		_closedTopOffset = kDefaultClosedTopOffset;
		_openBottomOffset = kDefaultOpenBottomOffset;
		_backgroundView = [MBPullDownControllerBackgroundView new];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self changeBackControllerFrom:nil to:self.backController];
	[self changeFrontControllerFrom:nil to:self.frontController];
}

#pragma mark - Open / Close

- (void)toggleOpenAnimated:(BOOL)animated {
	[self setOpen:!_open animated:animated];
}

- (void)setOpen:(BOOL)open animated:(BOOL)animated {
	_open = open;
	UIScrollView *scrollView = [self scrollView];
	CGFloat offset = open ? self.view.bounds.size.height - self.openBottomOffset : self.closedTopOffset;
	UIEdgeInsets insets = UIEdgeInsetsMake(offset, 0.f, 0.f, 0.f);
	void (^update)(void) = ^{
		scrollView.contentInset = insets;
		scrollView.scrollIndicatorInsets = insets;
		[scrollView scrollRectToVisible:CGRectMake(0.f, 0.f, 1.f, 1.f) animated:NO];
	};
	if (animated) {
		[UIView animateWithDuration:.3f animations:update];
	} else {
		update();
	}
}

#pragma mark - ContainerController

- (void)changeFrontControllerFrom:(UIViewController *)current to:(UIViewController *)new {
	UIView *containerView = self.view;
	UIView *currentView = current.view;
	UIView *newView = new.view;
	
	NSAssert(!newView || [newView isKindOfClass:[UIScrollView class]],
			 @"The front controller's view is not a UIScrollView subclass.");
	
	if (currentView) {
		[currentView removeFromSuperview];
	}
	if (newView) {
		newView.frame = containerView.bounds;
		[containerView addSubview:newView];
		[self addChildViewController:new];
	}
	
	[self prepareScrollView];
	[self setOpen:NO animated:NO];
}

- (void)changeBackControllerFrom:(UIViewController *)current to:(UIViewController *)new {
	UIView *containerView = self.view;
	UIView *currentView = current.view;
	UIView *newView = new.view;
	
	if (currentView) {
		[currentView removeFromSuperview];
	}
	if (newView) {
		newView.frame = containerView.bounds;
		[containerView insertSubview:newView atIndex:0];
		[self addChildViewController:new];
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

- (void)prepareScrollView {
	// TODO: cleanup on prevous scroll view
	UIScrollView *scrollView = [self scrollView];
	scrollView.backgroundColor = [UIColor clearColor];
	[self swizzleHitTestForScrollView:scrollView];
	[self registerForScrollViewKVO:scrollView];
	[self addGestureRecognizersToScrollView:scrollView];
	[self initializeBackgroundView];
}

- (void)swizzleHitTestForScrollView:(UIScrollView *)scrollView {
	Class class = [scrollView class];
    SEL originalSelector = @selector(hitTest:withEvent:);
    SEL overrideSelector = @selector(MBPullDownControllerHitTest:withEvent:);
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

- (void)checkForOpenCloseState {
	BOOL open = self.open;
	CGPoint offset = [self scrollView].contentOffset;
	if (!open && offset.y < -150.f) {
		[self setOpen:YES animated:YES];
	} else if (open) {
		[self setOpen:NO animated:YES];
	}
}

#pragma mark - Gestures

- (void)addGestureRecognizersToScrollView:(UIScrollView *)scrollView {
	MBPullDownControllerTapUpRecognizer *tapUp;
	tapUp = [[MBPullDownControllerTapUpRecognizer alloc] initWithTarget:self action:@selector(tapUp:)];
	[scrollView addGestureRecognizer:tapUp];
}

- (void)removeGesureRecognizersFromScrollView {
	// TODO: cleanup
}

- (void)tapUp:(MBPullDownControllerTapUpRecognizer *)recognizer {
	[self checkForOpenCloseState];
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
		layer.shadowOpacity = 0.2;
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

