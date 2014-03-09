//
//  TSNetworkUtility.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TSNetworkUtility : NSObject

- (void)sendGeoLocations:(NSArray*)geoLocs;

@end
