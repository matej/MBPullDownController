//
//  MBSettingsController.m
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import "MBSettingsController.h"
#import "MBPullDownController.h"
#import "MBImagesViewController.h"
#import "MBInfoViewController.h"


@interface MBSettingsController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;

@end


@implementation MBSettingsController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	_categoryList = [self buildCategoryList];
	[self updateSelectionTo:0];
	[self registerForKVO];
	[self setUpButtons];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateInsets];
}

- (void)dealloc {
	[self unregisterFromKVO];
}

#pragma mark - DisplayList

- (NSArray *)buildCategoryList {
	return @[@"abstract", @"animals", @"business", @"cats",
		  @"city", @"food", @"nightlife", @"fashion", @"people",
		  @"nature", @"sports", @"technics", @"transport"];
}

#pragma mark - Buttons

- (void)setUpButtons {
	UIFont *awesome = [UIFont fontWithName:@"FontAwesome" size:24];
	self.toggleButton.titleLabel.font = awesome;
	self.reloadButton.titleLabel.font = awesome;
	[self.reloadButton setTitle:@"\uf021" forState:UIControlStateNormal];
	self.infoButton.titleLabel.font = awesome;
	[self.infoButton setTitle:@"\uf05a" forState:UIControlStateNormal];
	[self.toggleButton setTitle:@"\uf0ab" forState:UIControlStateNormal];
	// Adjust top spacing for iOS 7 status bar
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		CGFloat topOffset = 20.f;
		UIEdgeInsets insets = UIEdgeInsetsMake(topOffset, 0.f, 0.f, 0.f);
		self.toggleButton.contentEdgeInsets = insets;
		self.infoButton.contentEdgeInsets = insets;
		self.reloadButton.contentEdgeInsets = insets;
		self.buttonHeight.constant += topOffset;
	}
}

#pragma mark - Actions

- (IBAction)togglePressed:(id)sender {
	[self.pullDownController toggleOpenAnimated:YES];
}

- (IBAction)reloadPressed:(id)sender {
	MBPullDownController *pullDownController = self.pullDownController;
	MBImagesViewController *imagesController = ((MBImagesViewController *)pullDownController.frontController);
	[imagesController reload];
}

- (IBAction)infoPressed:(id)sender {
	MBInfoViewController *details = [[MBInfoViewController alloc] init];
	[self.navigationController pushViewController:details animated:YES];
}

#pragma mark - TableView

- (void)updateInsets {
	UIEdgeInsets insets = UIEdgeInsetsMake(0.f, 0.f, self.pullDownController.openBottomOffset, 0.f);
	self.tableView.contentInset = insets;
	self.tableView.scrollIndicatorInsets = insets;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.textLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.f];
	cell.textLabel.text = [[self.categoryList objectAtIndex:indexPath.row] capitalizedString];
	cell.accessoryType = indexPath.row == self.selectedIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *oldIp = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
	[self updateSelectionTo:indexPath.row];
	[self configureCell:[tableView cellForRowAtIndexPath:oldIp] atIndexPath:oldIp];
	[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateSelectionTo:(NSUInteger)index {
	self.selectedIndex = index;
	MBPullDownController *pullDownController = self.pullDownController;
	MBImagesViewController *imagesController = ((MBImagesViewController *)pullDownController.frontController);
	imagesController.imageCategory = [self.categoryList objectAtIndex:index];
	if (pullDownController.open) {
		[pullDownController setOpen:NO animated:YES];
	}
}

#pragma mark - KVO

- (void)registerForKVO {
	MBPullDownController *pullDownController = self.pullDownController;
	[pullDownController addObserver:self forKeyPath:@"open" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unregisterFromKVO {
	MBPullDownController *pullDownController = self.pullDownController;
	[pullDownController removeObserver:self forKeyPath:@"open"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"open"]) {
		[self.toggleButton setTitle:self.pullDownController.open ? @"\uf0aa" : @"\uf0ab" forState:UIControlStateNormal];
	}
}

@end
