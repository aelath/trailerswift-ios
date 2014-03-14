//
//  TSGeoLocManager.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TSGeoLocManager.h"
#import "TSGeoLocStore.h"
#import "TSNetworkUtility.h"

#define kTSGeoLocCreationInterval 60 // Seconds. Default is 1 hour, 3600
#define kTSGeoLocGPSBool NO // Use GPS?

@interface TSGeoLocManager () <CLLocationManagerDelegate>

@property (nonatomic, weak) TSGeoLocStore *store;
@property (nonatomic, assign) BOOL track;
@property (nonatomic, assign) BOOL useGPS;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) CLLocation *currenLocation;

@end

@implementation TSGeoLocManager

- (id)init
{
    self = [super init];
    if (self) {
        _store = [TSGeoLocStore sharedStore];
    }
    return self;
}

- (void)getLocation
{
    if (!self.track) {
        // Begin listening for location info
        self.track = YES;
        NSLog(@"** Start Listening for Location **");
        if (_useGPS == YES) {
            [self.locationManager startUpdatingLocation];
        }
        [self.locationManager startMonitoringSignificantLocationChanges];
    } else {
        self.track = NO;
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopMonitoringSignificantLocationChanges];
        NSLog(@"** Stopped Listening for Location **");
        return;
    }
}

- (CLLocationManager*)locationManager
{
    if (!_locationManager) {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        lm.distanceFilter = 100;
        _locationManager = lm;
    }
    return _locationManager;
}

- (void)makeNewLocation:(CLLocation*)location
{
    NSLog(@"** Making a New Location **");
    
    // Validate location
    if (self.lastLocation) {
        if (![self isValid:location]) {
            NSLog(@"Location: %@ is NOT valid", location);
            return;
        }
    }

    // Make a geoloc object with the selected location object
    TSGeoLoc *geoLoc = [self.store newGeoLocWithLocation:location];
    self.lastLocation = location;
    
    // Send the geoloc oject to the platform
    TSNetworkUtility *nu = [[TSNetworkUtility alloc] init];
    [nu sendGeoLocation:geoLoc sender:self];
}

- (void)locationResponseWithObject:(TSGeoLoc*)object locationID:(NSString*)locationID
{
    // If SUCCESS, update the geoloc to SENT, send unsent geolocs
    [self.store updateGeoLoc:object withSentandLocationID:locationID];
    [self sendUnsentGeoLocs];
}

- (BOOL)isValid:(CLLocation*)location
{
    BOOL valid = NO;
    
    if (!self.lastLocation) {
        valid = YES;
        return valid;
    }
    
    NSDate *candidateEventDate = location.timestamp;
    NSDate *cachedEventDate = self.lastLocation.timestamp;
    NSTimeInterval difference = [candidateEventDate timeIntervalSinceDate:cachedEventDate];
    
    if (abs(difference) > kTSGeoLocCreationInterval) {
        valid = YES;
    }
    
    return valid;
}

- (void)sendUnsentGeoLocs
{
    NSArray *unsent = [self.store getUnsentGeoLocs];
    if ([unsent count] > 0) {
        for (TSGeoLoc *geoLoc in unsent) {
            // Send to the platform via network utility
            TSNetworkUtility *nu = [[TSNetworkUtility alloc] init];
            [nu sendGeoLocation:geoLoc sender:self];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        [self makeNewLocation:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"** Failed to update location with error: %@", error);
}

@end
