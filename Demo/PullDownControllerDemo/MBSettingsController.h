//
//  MBSettingsController.h
//  PullDownControllerDemo
//
//  Created by Matej Bukovinski on 22. 02. 13.
//  Copyright (c) 2013 Matej Bukovinski. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MBSettingsController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, readonly) NSArray *categoryList;
@property (assign, nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

- (IBAction)togglePressed:(id)sender;
- (IBAction)reloadPressed:(id)sender;
- (IBAction)infoPressed:(id)sender;

@end
