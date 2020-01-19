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

@interface SCCLocationViewController : UIViewController <MKMapViewDelegate, UIUserActivityRestoring>

@property (strong, nonatomic) SCCCameraLocation *model;
@property (nonatomic) SCCFrameIndex currentFrame;

@property (nonatomic) BOOL shouldShowDebugInfo;
@property (strong, nonatomic, readonly) NSString *debugInfo;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *debugLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
