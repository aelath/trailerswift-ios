//
//  TSNetworkUtility.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class TSGeoLoc;
@interface TSNetworkUtility : NSObject

- (id)initWithUsername:(NSString*)username password:(NSString*)password;
- (void)sendGeoLocation:(TSGeoLoc*)geoLoc sender:(id)sender;

@end
