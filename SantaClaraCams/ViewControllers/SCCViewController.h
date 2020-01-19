//
//  SCCViewController.h
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

@import UIKit;
@import SantaClaraCityCams;

@interface SCCViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

- (void)navigateForModel:(SCCCameraLocation *)model animated:(BOOL)animated;

@end
