//
//  SCCCameraLocation.m
//  SantaClaraCityCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCCameraLocation.h"

NSString *const SCCCameraLocationActivityType = @"null.leptos.SantaClaraCityCams.activity";

NSString *const SCCCameraLocationActivityNameKey = @"kSCCCameraNamerKey";
NSString *const SCCCameraLocationActivityCameraKey = @"kSCCCameraIdentiferKey";
NSString *const SCCCameraLocationActivityLatitudeKey = @"kSCCCameraLatitudeKey";
NSString *const SCCCameraLocationActivityLongitudeKey = @"kSCCCameraLongitudeKey";
NSString *const SCCCameraLocationActivityHeadingKey = @"kSCCCameraHeadingKey";

/// Constrict a given value into the range [0, b)
/// @return An interval offset of @c v
static inline double constrictValueBound(double v, double b) {
    return v - b*floor(v/b);
}

@implementation SCCCameraLocation

// MARK: - Class property synthesis

+ (NSArray<SCCCameraLocation *> *)knownLocations {
    static dispatch_once_t onceToken;
    static NSArray<SCCCameraLocation *> *ret;
    dispatch_once(&onceToken, ^{
        ret = @[
            [self cameraWithName:@"San Tomas Aquino Creek Trail @ Mission College" identifier:@"MissionCreekTrail"
                        location:[[CLLocation alloc] initWithLatitude:37.389137 longitude:-121.968255] heading:289],
            [self cameraWithName:@"Bowers Ave @ SB101 Ramps" identifier:@"Bowers101"
                        location:[[CLLocation alloc] initWithLatitude:37.384560 longitude:-121.977493] heading:41],
            [self cameraWithName:@"Great America @ 101 Off-Ramp NB" identifier:@"GA101"
                        location:[[CLLocation alloc] initWithLatitude:37.386760 longitude:-121.976634] heading:36],
            [self cameraWithName:@"Great America @ Bunker Hill" identifier:@"GAParkwayBunkerHill"
                        location:[[CLLocation alloc] initWithLatitude:37.405447 longitude:-121.977944] heading:19],
            [self cameraWithName:@"Great America @ Mission College" identifier:@"GAMissionCollege"
                        location:[[CLLocation alloc] initWithLatitude:37.392569 longitude:-121.976966] heading:117],
            [self cameraWithName:@"Great America @ Patrick Henry" identifier:@"GAPatrickHenry"
                        location:[[CLLocation alloc] initWithLatitude:37.395812 longitude:-121.978110] heading:24],
            [self cameraWithName:@"Great America @ Old Glory" identifier:@"GAOldGlory"
                        location:[[CLLocation alloc] initWithLatitude:37.399989 longitude:-121.978148] heading:146],
            [self cameraWithName:@"Great America @ Tasman" identifier:@"GATasman"
                        location:[[CLLocation alloc] initWithLatitude:37.403059 longitude:-121.978006] heading:65],
            [self cameraWithName:@"Great America @ Old Mtn View Alviso" identifier:@"GAOldMtnViewAlviso"
                        location:[[CLLocation alloc] initWithLatitude:37.410354 longitude:-121.977903] heading:162],
            [self cameraWithName:@"Great America @ Great America Pkwy" identifier:@"GAGAParkway"
                        location:[[CLLocation alloc] initWithLatitude:37.414011 longitude:-121.977409] heading:337],
            [self cameraWithName:@"Mission College @ Agnew" identifier:@"MissionCollegeAgnew"
                        location:[[CLLocation alloc] initWithLatitude:37.388898 longitude:-121.969322] heading:305],
            [self cameraWithName:@"Mission College @ Mission College Circle" identifier:@"GAMissionCollegeCircle"
                        location:[[CLLocation alloc] initWithLatitude:37.391697 longitude:-121.978794] heading:308],
            [self cameraWithName:@"Tasman @ Convention Center" identifier:@"TasmanConventionCenter"
                        location:[[CLLocation alloc] initWithLatitude:37.403637 longitude:-121.975551] heading:120],
            [self cameraWithName:@"Tasman @ Old Ironsides" identifier:@"TasmanOldIronsides"
                        location:[[CLLocation alloc] initWithLatitude:37.403143 longitude:-121.979995] heading:309],
            [self cameraWithName:@"Tasman @ Calle De Sol" identifier:@"TasmanCalleDeSol"
                        location:[[CLLocation alloc] initWithLatitude:37.407359 longitude:-121.963758] heading:282],
            [self cameraWithName:@"Tasman @ Lick Mill" identifier:@"TasmanLickMill"
                        location:[[CLLocation alloc] initWithLatitude:37.408365 longitude:-121.961359] heading:251],
        ];
    });
    return ret;
}

// MARK: - Initializers

+ (instancetype)cameraWithName:(NSString *)name identifier:(NSString *)identifier location:(CLLocation *)location heading:(CLLocationDirection)heading {
    return [[self alloc] initWithLocalizedName:name identifier:identifier location:location heading:heading];
}

- (instancetype)initWithLocalizedName:(NSString *)name identifier:(NSString *)identifier location:(CLLocation *)location heading:(CLLocationDirection)heading {
    if (self = [self init]) {
        _localizedName = name;
        _cameraID = identifier;
        _location = location;
        _heading = heading;
    }
    return self;
}

+ (instancetype)cameraWithUserActivity:(NSUserActivity *)userActivity {
    if ([userActivity.activityType isEqualToString:SCCCameraLocationActivityType]) {
        NSDictionary *userInfo = userActivity.userInfo;
        return [self cameraWithName:userInfo[SCCCameraLocationActivityNameKey]
                         identifier:userInfo[SCCCameraLocationActivityCameraKey]
                           location:[[CLLocation alloc]
                                     initWithLatitude:[userInfo[SCCCameraLocationActivityLatitudeKey] doubleValue]
                                     longitude:[userInfo[SCCCameraLocationActivityLongitudeKey] doubleValue]]
                            heading:[userInfo[SCCCameraLocationActivityHeadingKey] doubleValue]];
    }
    return nil;
}

// MARK: - Readonly property synthesis

- (double)framesPerSecond {
    return 8/9.0;
}

- (SCCFrameIndex)maxFrame {
    return 0xff;
}

// MARK: - Private methods

- (NSURL *)_baseURL {
    static dispatch_once_t onceToken;
    static NSURL *ret;
    dispatch_once(&onceToken, ^{
        ret = [NSURL URLWithString:@"https://trafficcam.santaclaraca.gov/Feeds"];
    });
    return ret;
}

+ (NSError *)_errorWithSubdomain:(NSString *)subdomain description:(NSString *)desc {
    NSString *domain = [@"null.leptos.SantaClaraCityCams" stringByAppendingPathExtension:subdomain];
    return [NSError errorWithDomain:domain code:1 userInfo:@{
        NSLocalizedDescriptionKey : desc
    }];
}

// MARK: - Public methods

+ (NSDate *)lastModifiedDateFromServerResponse:(NSURLResponse *)response error:(NSError **)error {
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (error) {
            *error = [self _errorWithSubdomain:@"serverResponse.dateParse" description:@"The server response was in an unexpected format"];
        }
        return nil;
    }
    
    NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
    NSString *fileDate = castedResponse.allHeaderFields[@"Last-Modified"];
    if (!fileDate) {
        if (error) {
            *error = [self _errorWithSubdomain:@"serverResponse.dateParse" description:@"The server did not provide a file modification date"];
        }
        return nil;
    }
    
    static NSDateFormatter *serverDateFormatter;
    static dispatch_once_t serverDateFormatterCreateOnceToken;
    dispatch_once(&serverDateFormatterCreateOnceToken, ^{
        serverDateFormatter = [NSDateFormatter new];
        serverDateFormatter.dateFormat = @"E, d MMM yyyy HH:mm:ss zzz";
    });
    
    NSDate *firstFrameDate = [serverDateFormatter dateFromString:fileDate];
    if (!firstFrameDate) {
        if (error) {
            *error = [self _errorWithSubdomain:@"serverResponse.dateParse" description:@"The server date format could not be parsed"];
        }
        return nil;
    }
    return firstFrameDate;
}

- (NSURL *)urlForFrame:(SCCFrameIndex)frame {
    NSURL *feedDir = [[self _baseURL] URLByAppendingPathComponent:self.cameraID isDirectory:YES];
    NSString *imageName = [NSString stringWithFormat:@"snap_%03u_c1.jpg", frame];
    return [feedDir URLByAppendingPathComponent:imageName isDirectory:NO];
}

- (NSUserActivity *)userActivity {
    NSString *webpageBase = @"https://trafficcam.santaclaraca.gov/TrafficCamera.aspx?CID=";
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:SCCCameraLocationActivityType];
    userActivity.title = self.localizedName;
    
    CLLocationCoordinate2D const coordinate = self.location.coordinate;
    userActivity.userInfo = @{
        SCCCameraLocationActivityNameKey : self.localizedName,
        SCCCameraLocationActivityCameraKey : self.cameraID,
        SCCCameraLocationActivityLatitudeKey : @(coordinate.latitude),
        SCCCameraLocationActivityLongitudeKey : @(coordinate.longitude),
        SCCCameraLocationActivityHeadingKey : @(self.heading)
    };
    userActivity.webpageURL = [NSURL URLWithString:[webpageBase stringByAppendingString:self.cameraID]];
    if (@available(iOS 9.0, *)) {
        userActivity.eligibleForSearch = YES;
        userActivity.eligibleForHandoff = YES;
    }
    return userActivity;
}

- (void)currentFrameWithCallback:(void(^)(SCCFrameIndex index, NSError *err))callback {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForFrame:1]];
    request.HTTPMethod = @"HEAD";
    __weak __typeof(self) weakself = self;
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            return callback(0, error);
        }
        
        NSDate *firstFrameDate = [[weakself class] lastModifiedDateFromServerResponse:response error:&error];
        if (error) {
            return callback(0, error);
        }
        
        NSTimeInterval diff = -firstFrameDate.timeIntervalSinceNow; // flip the sign bit
        if (signbit(diff)) { // check if the sign bit is now set
            return callback(0, [[weakself class] _errorWithSubdomain:@"serverResponse" description:@"Parsed date returned by server is in the future"]);
        }
        double frameOffset = floor(diff * weakself.framesPerSecond);
        frameOffset -= 3; // lag patch
        SCCFrameIndex realFrame = constrictValueBound(frameOffset, weakself.maxFrame);
        // this returns `[0, b)`, and we want `(0, b]`,
        //   however anyone using this value should understand
        callback(realFrame, nil);
    }] resume];
}

// MARK: - MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    return self.location.coordinate;
}

- (NSString *)title {
    return self.localizedName;
}

// MARK: - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> cid: %@", [self class], self, self.cameraID];
}

@end
