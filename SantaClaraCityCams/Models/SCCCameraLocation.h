//
//  SCCCameraLocation.h
//  SantaClaraCityCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

@import CoreLocation;
@import MapKit;

typedef uint32_t SCCFrameIndex;

FOUNDATION_EXPORT NSString *const SCCCameraLocationActivityType;

@interface SCCCameraLocation : NSObject <MKAnnotation>

@property (strong, class, nonatomic, readonly) NSArray<SCCCameraLocation *> *knownLocations;

@property (strong, nonatomic, readonly) NSString *localizedName;
@property (strong, nonatomic, readonly) NSString *cameraID;
@property (strong, nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationDirection heading;

@property (nonatomic, readonly) double framesPerSecond;
@property (nonatomic, readonly) SCCFrameIndex maxFrame;

+ (instancetype)cameraWithUserActivity:(NSUserActivity *)userActivity;

- (instancetype)initWithLocalizedName:(NSString *)name identifier:(NSString *)identifier location:(CLLocation *)location heading:(CLLocationDirection)heading;
+ (instancetype)cameraWithName:(NSString *)name identifier:(NSString *)identifier location:(CLLocation *)location heading:(CLLocationDirection)heading;

- (void)currentFrameWithCallback:(void(^)(SCCFrameIndex index, NSError *err))callback;

- (NSURL *)urlForFrame:(SCCFrameIndex)frame;

- (NSUserActivity *)userActivity;

// MARK: - Utility methods

+ (NSDate *)lastModifiedDateFromServerResponse:(NSURLResponse *)response error:(NSError **)error;

@end
