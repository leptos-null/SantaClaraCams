//
//  SCCAppDelegate.m
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCAppDelegate.h"
#import "../ViewControllers/SCCViewController.h"
#import "../ViewControllers/SCCLocationViewController.h"

@implementation SCCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *))restorationHandler {
    if ([userActivity.activityType isEqualToString:SCCCameraLocationActivityType]) {
        SCCCameraLocation *model = [SCCCameraLocation cameraWithUserActivity:userActivity];
        
        UISplitViewController *splitController = (__kindof UIViewController *)self.window.rootViewController;
        NSAssert([splitController isKindOfClass:[UISplitViewController class]], @"rootViewController: UISplitViewController");
        
        UINavigationController *navController = splitController.viewControllers.firstObject;
        NSAssert([navController isKindOfClass:[UINavigationController class]], @"navController: UINavigationController");
        
        SCCViewController *tableController = navController.viewControllers.firstObject;
        NSAssert([tableController isKindOfClass:[SCCViewController class]], @"tableController: SCCViewController");

        [tableController navigateForModel:model animated:NO];
        return YES;
    }
    return NO;
}

@end
