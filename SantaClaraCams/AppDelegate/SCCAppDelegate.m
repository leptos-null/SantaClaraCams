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
        
        UINavigationController *navController = (__kindof UIViewController *)self.window.rootViewController;
        NSAssert([navController isKindOfClass:[UINavigationController class]], @"rootViewController: UINavigationController");
        
        SCCViewController *rootController = nil;
        for (__kindof UIViewController *controller in navController.viewControllers) {
            if ([controller isKindOfClass:[SCCLocationViewController class]]) {
                SCCLocationViewController *locationController = controller;
                locationController.model = model;
                return YES;
            } else if ([controller isKindOfClass:[SCCViewController class]]) {
                rootController = controller;
            }
        }
        if (rootController) {
            [rootController navigateForModel:model animated:NO];
            return YES;
        }
    }
    return NO;
}

@end
