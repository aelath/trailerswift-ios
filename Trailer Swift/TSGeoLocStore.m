//
//  TSGeoLocStore.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSGeoLocStore.h"
#import "TSGeoLoc.h"


@implementation TSGeoLocStore

@dynamic allGeoLocs;
@dynamic unsentGeoLocs;
@dynamic geoLoc;

+ (TSGeoLocStore*)sharedStore
{
    static TSGeoLocStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[TSGeoLocStore alloc] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [TSGeoLocStore sharedStore];
}

- (id)init
{
    return self;
}

- (TSGeoLoc*)newGeoLocWithLocation:(CLLocation *)location
{
    TSGeoLoc *geoLoc = [[TSGeoLoc alloc] initWithLocation:location];
    [self.allGeoLocs addObject:geoLoc];
    [self.unsentGeoLocs addObject:geoLoc];
    
    return geoLoc;
}

- (void)updateSentWithGeoLoc:(TSGeoLoc *)geoLoc
{
    geoLoc.sent = YES;
    [self.unsentGeoLocs removeObject:geoLoc];
}

- (void)deleteGeoLoc:(TSGeoLoc *)geoLoc
{
    [self.allGeoLocs removeObject:geoLoc];
    if (!geoLoc.sent) {
        [self.unsentGeoLocs removeObject:geoLoc];
    }
    geoLoc = nil;
}
@end
