//
//  TSGeoLocStore.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TSGeoLoc;
@class CLLocation;

@interface TSGeoLocStore : NSManagedObject

@property (nonatomic, retain) NSMutableArray *allGeoLocs;
@property (nonatomic, retain) NSMutableArray *unsentGeoLocs;
@property (nonatomic, retain) TSGeoLoc *geoLoc;

+ (TSGeoLocStore*)sharedStore;
- (TSGeoLoc*)newGeoLocWithLocation:(CLLocation*)location;
- (void)updateSentWithGeoLoc:(TSGeoLoc*)geoLoc;
- (void)deleteGeoLoc:(TSGeoLoc*)geoLoc;

@end
