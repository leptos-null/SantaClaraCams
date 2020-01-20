//
//  SCCLocationViewController.h
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

@import UIKit;
@import MapKit;
@import SantaClaraCityCams;

@protocol SCCLocationModelChangeDelegate <NSObject>
- (void)modelController:(id)controller didChange:(SCCCameraLocation *)model;
@end

@interface SCCLocationViewController : UIViewController <MKMapViewDelegate, UIUserActivityRestoring>

@property (weak, nonatomic) id<SCCLocationModelChangeDelegate> modelChangeDelegate;

@property (strong, nonatomic) SCCCameraLocation *model;
- (void)setModel:(SCCCameraLocation *)model animated:(BOOL)animated;

@property (nonatomic) SCCFrameIndex currentFrame;

@property (nonatomic) BOOL shouldShowDebugInfo;
@property (strong, nonatomic, readonly) NSString *debugInfo;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *debugLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
