//
//  SCCSplitViewController.m
//  SantaClaraCams
//
//  Created by Leptos on 1/19/20.
//  Copyright © 2020 Leptos. All rights reserved.
//

#import "SCCSplitViewController.h"

@implementation SCCSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SCCLocationViewController *locationController = self.detailViewController;
    locationController.modelChangeDelegate = self.listViewController;
    [locationController setModel:SCCCameraLocation.knownLocations.firstObject animated:NO];
}

/*
 * isCollapsed:
 *   split
 *   |-- navigation
 *       |-- table
 *       |-- location (optional)
 *
 * notCollapsed:
 *   split
 *   |-- navigation
 *   |   |-- table
 *   |-- location (optional)
 *
 */

- (SCCListViewController *)listViewController {
    UINavigationController *navigationController = self.viewControllers[0];
    NSAssert([navigationController isKindOfClass:[UINavigationController class]],
             @"navigationController: UINavigationController");
    
    SCCListViewController *listController = navigationController.viewControllers[0];
    NSAssert([listController isKindOfClass:[SCCListViewController class]],
             @"listController: SCCListViewController");
    return listController;
}

- (SCCLocationViewController *)detailViewController {
    NSArray<__kindof UIViewController *> *viewControllers = self.viewControllers;
    
    UINavigationController *navigationController = viewControllers[0];
    NSAssert([navigationController isKindOfClass:[UINavigationController class]],
             @"navigationController: UINavigationController");
    SCCLocationViewController *locationController = nil;
    
    if (self.collapsed) {
        NSArray<__kindof UIViewController *> *navControllers = navigationController.viewControllers;
        if (navControllers.count > 1) {
            locationController = navControllers[1];
        }
    } else {
        if (viewControllers.count > 1) {
            locationController = viewControllers[1];
        }
    }
    
    NSAssert((locationController == nil) || [locationController isKindOfClass:[SCCLocationViewController class]],
             @"locationController: SCCLocationViewController");
    return locationController;
}

@end
