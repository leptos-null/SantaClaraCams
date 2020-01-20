//
//  SCCListViewController.m
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCListViewController.h"
#import "SCCSplitViewController.h"

@implementation SCCListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)navigateForModel:(SCCCameraLocation *)model animated:(BOOL)animated {
    SCCSplitViewController *splitController = (__kindof UISplitViewController *)self.splitViewController;
    SCCLocationViewController *controller = splitController.detailViewController;
    if (!controller) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationController"];
        controller.modelChangeDelegate = self;
        [splitController showDetailViewController:controller sender:self];
    }
    controller.model = model;
}

// MARK: - SCCLocationModelSetDelegate

- (void)modelController:(id)controller didChange:(SCCCameraLocation *)model {
    NSInteger index = [SCCCameraLocation.knownLocations indexOfObject:model];
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

// MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView == self.tableView);
    NSParameterAssert(indexPath.section == 0);
    
    [self navigateForModel:SCCCameraLocation.knownLocations[indexPath.row] animated:YES];
}

// MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView == self.tableView);
    NSParameterAssert(indexPath.section == 0);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CameraLocation"];
    cell.textLabel.text = SCCCameraLocation.knownLocations[indexPath.row].localizedName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSParameterAssert(tableView == self.tableView);
    NSParameterAssert(section == 0);
    
    return SCCCameraLocation.knownLocations.count;
}

@end
