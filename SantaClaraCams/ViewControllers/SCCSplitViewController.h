//
//  SCCSplitViewController.h
//  SantaClaraCams
//
//  Created by Leptos on 1/19/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCCListViewController.h"
#import "SCCLocationViewController.h"

@interface SCCSplitViewController : UISplitViewController

@property (strong, nonatomic, readonly, nonnull) SCCListViewController *listViewController;
@property (strong, nonatomic, readonly, nullable) SCCLocationViewController *detailViewController;

@end
