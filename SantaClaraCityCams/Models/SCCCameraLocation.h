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

NS_ASSUME_NONNULL_BEGIN

@interface SCCCameraLocation : NSObject <MKAnnotation>

@property (strong, class, nonatomic, readonly) NSArray<SCCCameraLocation *> *knownLocations;

@property (strong, nonatomic, readonly) NSString *localizedName;
@property (strong, nonatomic, readonly) NSString *key;
@property (strong, nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLLocationDirection heading;

@property (nonatomic, readonly) double framesPerSecond;
@property (nonatomic, readonly) SCCFrameIndex maxFrame;

- (instancetype)initWithLocalizedName:(NSString *)name key:(NSString *)key location:(CLLocation *)location heading:(CLLocationDirection)heading;
+ (instancetype)cameraWithName:(NSString *)name key:(NSString *)key location:(CLLocation *)location heading:(CLLocationDirection)heading;

- (void)currentFrameWithCallback:(void(^)(SCCFrameIndex index, NSError *err))callback;

- (NSURL *)urlForFrame:(SCCFrameIndex)frame;

// MARK: - Utility methods

+ (NSDate *)lastModifiedDateFromServerResponse:(NSURLResponse *)response error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
