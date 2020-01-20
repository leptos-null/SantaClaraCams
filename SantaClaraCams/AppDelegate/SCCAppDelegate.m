//
//  SCCAppDelegate.m
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCAppDelegate.h"
#import "../ViewControllers/SCCSplitViewController.h"

@implementation SCCAppDelegate

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *))restorationHandler {
    if ([userActivity.activityType isEqualToString:SCCCameraLocationActivityType]) {
        SCCCameraLocation *model = [SCCCameraLocation cameraWithUserActivity:userActivity];
        
        SCCSplitViewController *splitController = (__kindof UIViewController *)self.window.rootViewController;
        NSAssert([splitController isKindOfClass:[UISplitViewController class]], @"rootViewController: SCCSplitViewController");
        
        [splitController.listViewController navigateForModel:model animated:NO];
        return YES;
    }
    return NO;
}

@end
