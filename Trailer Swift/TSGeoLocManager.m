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

#define kTSGeoLocCreationInterval 3600

@interface TSGeoLocManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) TSGeoLocStore *store;
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
    // Begin listening for location info
    
    [self.locationManager startUpdatingLocation];

}

- (CLLocationManager*)locationManager
{
    if (!_locationManager) {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        lm.distanceFilter = 1000;
        _locationManager = lm;
    }
    return _locationManager;
}

- (void)makeNewLocation:(CLLocation*)location
{
    // Validate location
    if (self.lastLocation) {
        if (![self isValid:location]) {
            NSLog(@"Location: %@ is NOT valid", location);
            return;
        }
    }
    
    // If valid, stop listening for location info
    [self.locationManager stopUpdatingLocation];
    
    // Make a geoloc object with the selected location object
    TSGeoLoc *geoLoc = [self.store newGeoLocWithLocation:location];
    self.lastLocation = location;
    
    // Send the geoloc oject to the platform
    
    // If SUCCESS, update the geoloc to SENT, send unsent geolocs
    [self.store updateSentWithGeoLoc:geoLoc];
    [self sendUnsentGeoLocs];
    
}

- (BOOL)isValid:(CLLocation*)location
{
    BOOL valid = NO;
    
    if (!self.lastLocation) return valid;
    
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
    NSArray *unsent = self.store.unsentGeoLocs;
    if ([unsent count] > 0) {
        for (TSGeoLoc *geoLoc in unsent) {
            // Send to the platform via network utility
            
            [self.store updateSentWithGeoLoc:geoLoc];
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
