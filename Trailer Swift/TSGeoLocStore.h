//
//  TSGeoLocStore.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSGeoLocManager.h"

@class TSGeoLoc;
@class CLLocation;

@interface TSGeoLocStore : NSManagedObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

+ (TSGeoLocStore*)sharedStore;
- (TSGeoLoc*)newGeoLocWithLocation:(CLLocation*)location;
- (TSGeoLocManager*)availableGeoLocManager;
- (void)updateGeoLoc:(TSGeoLoc*)geoLoc withSentandLocationID:(NSString*)locationID;
- (void)deleteGeoLoc:(TSGeoLoc*)geoLoc;
- (NSArray*)getUnsentGeoLocs;

@end
