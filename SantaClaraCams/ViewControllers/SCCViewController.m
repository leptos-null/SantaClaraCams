//
//  SCCViewController.m
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCViewController.h"
#import "SCCLocationViewController.h"

@implementation SCCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)navigateForModel:(SCCCameraLocation *)model animated:(BOOL)animated {
    SCCLocationViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationController"];
    [controller loadViewIfNeeded];
    controller.model = model;
    [self.navigationController pushViewController:controller animated:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView == self.tableView);
    NSParameterAssert(indexPath.section == 0);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CameraLocation"];
    cell.textLabel.text = SCCCameraLocation.knownLocations[indexPath.row].localizedName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView == self.tableView);
    NSParameterAssert(indexPath.section == 0);
    
    [self navigateForModel:SCCCameraLocation.knownLocations[indexPath.row] animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSParameterAssert(tableView == self.tableView);
    NSParameterAssert(section == 0);
    
    return SCCCameraLocation.knownLocations.count;
}

@end
