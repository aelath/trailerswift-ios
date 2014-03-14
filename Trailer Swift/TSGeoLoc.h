//
//  TSGeoLoc.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TSGeoLoc : NSObject

- (id)initWithLocation:(CLLocation*)loc;
- (CLLocation*)location;

@end
