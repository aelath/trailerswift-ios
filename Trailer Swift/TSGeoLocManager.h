//
//  TSGeoLocManager.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSGeoLoc;
@interface TSGeoLocManager : NSObject

- (void)getLocation;
- (void)locationResponseWithObject:(TSGeoLoc*)object locationID:(NSString*)locationID;

@end
