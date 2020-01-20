//
//  SCCListViewController.h
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

@import UIKit;

#import "SCCLocationViewController.h"

@interface SCCListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, SCCLocationModelChangeDelegate>

- (void)navigateForModel:(SCCCameraLocation *)model animated:(BOOL)animated;

@end
