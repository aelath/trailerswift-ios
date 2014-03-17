//
//  TSGeoLocStore.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSGeoLocStore.h"
#import "TSGeoLoc.h"
#import "TSGeoLocPrivateProperties.h"

@interface TSGeoLocStore ()

@property (nonatomic, strong) TSGeoLocManager *gLocMan;
@property (nonatomic, strong) NSMutableArray *allGeoLocs;
@property (nonatomic, strong) NSMutableArray *unsentGeoLocs;

@end

@implementation TSGeoLocStore

@dynamic allGeoLocs;
@dynamic unsentGeoLocs;
@dynamic gLocMan;
@dynamic username;
@dynamic password;

+ (TSGeoLocStore*)sharedStore
{
    static TSGeoLocStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[TSGeoLocStore alloc] init];
    }
    return sharedStore;
}

- (id)init
{
    self = [super init];
    return self;
}

- (TSGeoLoc*)newGeoLocWithLocation:(CLLocation *)location
{
    TSGeoLoc *geoLoc = [[TSGeoLoc alloc] initWithLocation:location];
    if (!self.allGeoLocs) {
        self.allGeoLocs = [NSMutableArray arrayWithObject:geoLoc];
    } else {
        [self.allGeoLocs addObject:geoLoc];
    }
    if (!self.unsentGeoLocs) {
        self.unsentGeoLocs = [NSMutableArray arrayWithObject:geoLoc];
    } else {
        [self.unsentGeoLocs addObject:geoLoc];
    }
    return geoLoc;
}

- (TSGeoLocManager*)availableGeoLocManager
{
    if (!self.gLocMan) {
        self.gLocMan = [[TSGeoLocManager alloc] init];
    }
    return self.gLocMan;
}

- (void)updateGeoLoc:(TSGeoLoc *)geoLoc withSentandLocationID:(NSString *)locationID
{
    geoLoc.sent = YES;
    [self.unsentGeoLocs removeObject:geoLoc];
    
    geoLoc.locationID = locationID;
}

- (NSArray*)getUnsentGeoLocs
{
    return self.unsentGeoLocs;
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
