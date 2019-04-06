//
//  SCCCameraLocation.m
//  SantaClaraCityCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCCameraLocation.h"

@implementation SCCCameraLocation

// MARK: - Class property synthesis

+ (NSArray<SCCCameraLocation *> *)knownLocations {
    static dispatch_once_t onceToken;
    static NSArray<SCCCameraLocation *> *ret;
    dispatch_once(&onceToken, ^{
        ret = @[
            [self cameraWithName:@"San Tomas Aquino Creek Trail @ Mission College" key:@"MissionCreekTrail"
                        location:[[CLLocation alloc] initWithLatitude:37.389137 longitude:-121.968255] heading:289],
            [self cameraWithName:@"Bowers Ave @ SB101 Ramps" key:@"Bowers101"
                        location:[[CLLocation alloc] initWithLatitude:37.384560 longitude:-121.977493] heading:41],
            [self cameraWithName:@"Great America @ 101 Off-Ramp NB" key:@"GA101"
                        location:[[CLLocation alloc] initWithLatitude:37.386760 longitude:-121.976634] heading:36],
            [self cameraWithName:@"Great America @ Bunker Hill" key:@"GAParkwayBunkerHill"
                        location:[[CLLocation alloc] initWithLatitude:37.405447 longitude:-121.977944] heading:19],
            [self cameraWithName:@"Great America @ Mission College" key:@"GAMissionCollege"
                        location:[[CLLocation alloc] initWithLatitude:37.392569 longitude:-121.976966] heading:117],
            [self cameraWithName:@"Great America @ Patrick Henry" key:@"GAPatrickHenry"
                        location:[[CLLocation alloc] initWithLatitude:37.395812 longitude:-121.978110] heading:24],
            [self cameraWithName:@"Great America @ Old Glory" key:@"GAOldGlory"
                        location:[[CLLocation alloc] initWithLatitude:37.399989 longitude:-121.978148] heading:146],
            [self cameraWithName:@"Great America @ Tasman" key:@"GATasman"
                        location:[[CLLocation alloc] initWithLatitude:37.403059 longitude:-121.978006] heading:65],
            [self cameraWithName:@"Great America @ Old Mtn View Alviso" key:@"GAOldMtnViewAlviso"
                        location:[[CLLocation alloc] initWithLatitude:37.410354 longitude:-121.977903] heading:162],
            [self cameraWithName:@"Great America @ Great America Pkwy" key:@"GAGAParkway"
                        location:[[CLLocation alloc] initWithLatitude:37.414011 longitude:-121.977409] heading:337],
            [self cameraWithName:@"Mission College @ Agnew" key:@"MissionCollegeAgnew"
                        location:[[CLLocation alloc] initWithLatitude:37.388898 longitude:-121.969322] heading:305],
            [self cameraWithName:@"Mission College @ Mission College Circle" key:@"GAMissionCollegeCircle"
                        location:[[CLLocation alloc] initWithLatitude:37.391697 longitude:-121.978794] heading:308],
            [self cameraWithName:@"Tasman @ Convention Center" key:@"TasmanConventionCenter"
                        location:[[CLLocation alloc] initWithLatitude:37.403637 longitude:-121.975551] heading:120],
            [self cameraWithName:@"Tasman @ Old Ironsides" key:@"TasmanOldIronsides"
                        location:[[CLLocation alloc] initWithLatitude:37.403143 longitude:-121.979995] heading:309],
            [self cameraWithName:@"Tasman @ Calle De Sol" key:@"TasmanCalleDeSol"
                        location:[[CLLocation alloc] initWithLatitude:37.407359 longitude:-121.963758] heading:282],
            [self cameraWithName:@"Tasman @ Lick Mill" key:@"TasmanLickMill"
                        location:[[CLLocation alloc] initWithLatitude:37.408365 longitude:-121.961359] heading:251],
        ];
    });
    return ret;
}

// MARK: - Initializers

+ (instancetype)cameraWithName:(NSString *)name key:(NSString *)key location:(CLLocation *)location heading:(CLLocationDirection)heading {
    return [[self alloc] initWithLocalizedName:name key:key location:location heading:heading];
}

- (instancetype)initWithLocalizedName:(NSString *)name key:(NSString *)key location:(CLLocation *)location heading:(CLLocationDirection)heading {
    if (self = [self init]) {
        _localizedName = name;
        _key = key;
        _location = location;
        _heading = heading;
    }
    return self;
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
    NSURL *feedDir = [[self _baseURL] URLByAppendingPathComponent:self.key isDirectory:YES];
    NSString *imageName = [NSString stringWithFormat:@"snap_%03u_c1.jpg", frame];
    return [feedDir URLByAppendingPathComponent:imageName isDirectory:NO];
}

- (void)currentFrameWithCallback:(void(^)(SCCFrameIndex index, NSError *err))callback {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForFrame:1]];
    request.HTTPMethod = @"HEAD";
    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            return callback(0, error);
        }

        NSDate *firstFrameDate = [self.class lastModifiedDateFromServerResponse:response error:&error];
        if (error) {
            return callback(0, error);
        }
        
        NSTimeInterval diff = -firstFrameDate.timeIntervalSinceNow; // flip the sign bit
        if (signbit(diff)) { // check if the sign bit is still set
            return callback(0, [self.class _errorWithSubdomain:@"serverResponse" description:@"Parsed date returned by server is in the future"]);
        }
        double frameOffset = floor(diff * self.framesPerSecond);
        frameOffset -= 3; // lag patch
        SCCFrameIndex realFrame = self.maxFrame;
        realFrame = frameOffset - realFrame*floor(frameOffset/realFrame);
        if (realFrame == 0) {
            realFrame = self.maxFrame;
        }
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
    return [NSString stringWithFormat:@"<%@: %p> key: %@", [self class], self, self.key];
}

@end
