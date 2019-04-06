//
//  SCCLocationViewController.m
//  SantaClaraCams
//
//  Created by Leptos on 3/23/19.
//  Copyright © 2019 Leptos. All rights reserved.
//

#import "SCCLocationViewController.h"

@implementation SCCLocationViewController {
    NSTimer *_updateFrameTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize currentViewSize = self.view.frame.size;
    self.navigationController.navigationBarHidden = (currentViewSize.width > currentViewSize.height);
    
    for (SCCCameraLocation *location in SCCCameraLocation.knownLocations) {
        [self.mapView addAnnotation:location];
    }
    
    [self _setupMapCameraForModel:self.model];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    /* I've been trying to figure out if a `_updateFrameTimer.valid` check is needed
     * NSTimer is an abstract class, the concrete class is __NSCFTimer
     * The implementation of -[__NSCFTimer invalidate] is {
     *     CFRunLoopTimerInvalidate(self);
     * }
     * the implementation of CFRunLoopTimerInvalidate can be found in CF/CFRunLoop.c
     * the main code is only execute if (__CFIsValid(rlt))
     */
    [_updateFrameTimer invalidate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_updateFrameTimer.valid) {
        [self _setupFrameUpdateTimerForModel:self.model];
    }
}

- (IBAction)_toggleDebugView:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.shouldShowDebugInfo ^= YES;
    }
}

- (IBAction)_imageDoubleTapSkip:(UIGestureRecognizer *)recognizer {
    SCCFrameIndex const skipFrames = 5;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint hitPoint = [recognizer locationInView:self.imageView];
        if (hitPoint.x > CGRectGetMidX(self.imageView.frame)) {
            self.currentFrame += skipFrames;
        } else {
            self.currentFrame -= skipFrames;
        }
    }
}

- (void)setModel:(SCCCameraLocation *)model {
    _model = model;
    
    self.title = model.localizedName;
    
    [self _setupFrameUpdateTimerForModel:model];
    if (self.viewLoaded) {
        [self _setupMapCameraForModel:model];
    }
}

- (void)_setupMapCameraForModel:(SCCCameraLocation *)model {
    if (model) {
        BOOL shouldAnimate = (self.navigationController.visibleViewController == self);
        /* these pitch and distance numbers are kind of estimated by what looked good */
        MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:model.location.coordinate fromDistance:32 pitch:60 heading:model.heading];
        [self.mapView setCamera:camera animated:shouldAnimate];
    }
}

- (void)_setupFrameUpdateTimerForModel:(SCCCameraLocation *)model {
    [_updateFrameTimer invalidate];
    
    if (model) {
        __weak __typeof(self) weakself = self;
        [model currentFrameWithCallback:^(SCCFrameIndex index, NSError *err) {
            if (err) {
                NSLog(@"Failed to find the current frame: %@", err);
            } else if (index) {
                weakself.currentFrame = index;
                if (weakself) {
                    __typeof(self) strongself = weakself;
                    const NSTimeInterval secondsPerFrame = 1/model.framesPerSecond;
                    NSTimer *frameTimer = [NSTimer timerWithTimeInterval:secondsPerFrame repeats:YES block:^(NSTimer *timer) {
                        weakself.currentFrame++;
                    }];
                    [NSRunLoop.mainRunLoop addTimer:frameTimer forMode:NSDefaultRunLoopMode];
                    strongself->_updateFrameTimer = frameTimer;
                }
            }
        }];
    }
}

- (void)setDebugInfo:(NSString *)debugInfo {
    _debugInfo = debugInfo;
    [self _setDebugLabelTextAppropriately];
}

- (void)setShouldShowDebugInfo:(BOOL)shouldShowDebugInfo {
    _shouldShowDebugInfo = shouldShowDebugInfo;
    [self _setDebugLabelTextAppropriately];
}

- (void)_setDebugLabelTextAppropriately {
    self.debugLabel.text = self.shouldShowDebugInfo ? self.debugInfo : nil;
}

- (void)setCurrentFrame:(SCCFrameIndex)currentFrame {
    // typically it's [0, upper), but this is (0, upper]
    currentFrame %= self.model.maxFrame;
    // `left ?:= value` would be a nice operation (assign `left` to `value` if `!left`)
    if (currentFrame == 0) {
        currentFrame = self.model.maxFrame;
    }
    _currentFrame = currentFrame;
    
    __weak __typeof(self) weakself = self;
    NSURL *endpoint = [self.model urlForFrame:currentFrame];
    [[NSURLSession.sharedSession dataTaskWithURL:endpoint completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *imageFrame = nil;
        NSString *debugText = nil;
        if (error) {
            debugText = error.localizedDescription;
        } else if (data) {
            imageFrame = [UIImage imageWithData:data];
            
            NSDate *frameDate = [SCCCameraLocation lastModifiedDateFromServerResponse:response error:&error];
            if (error) {
                debugText = error.localizedDescription;
            } else {
                static NSDateFormatter *displayFormatter;
                static dispatch_once_t createDisplayFormatterOnce;
                dispatch_once(&createDisplayFormatterOnce, ^{
                    displayFormatter = [NSDateFormatter new];
                    displayFormatter.timeStyle = NSDateFormatterMediumStyle;
                });
                
                NSDate *nowTime = [NSDate date];
                debugText = [NSString stringWithFormat:@""
                             "Key: %@\n"
                             "Now: %@\n"
                             "Frame: %@\n"
                             "Difference: %.4f\n"
                             "Index: %d",
                             weakself.model.key, [displayFormatter stringFromDate:nowTime],
                             [displayFormatter stringFromDate:frameDate], [nowTime timeIntervalSinceDate:frameDate], currentFrame];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.imageView.image = imageFrame;
            weakself.debugInfo = debugText;
        });
    }] resume];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.model != view.annotation) {
        self.model = view.annotation;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // in landscape, the camera goes full screen
    // todo: only hide the bar after some time, and make it possible to still go back, possibly by making the bar reappear on click
    [self.navigationController setNavigationBarHidden:(size.width > size.height) animated:YES];
}

- (void)dealloc {
    [_updateFrameTimer invalidate];
}
// either the map is visible, or the camera is full screen, either way, we don't want the home indicator
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
// in landscape, the nav bar can be hidden, so the status bar should go away too
- (BOOL)prefersStatusBarHidden {
    return YES;
}
// this is here, just in case
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
