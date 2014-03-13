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

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *friendlyName;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) NSString *locationID; // Comes from the server
@property (nonatomic, assign) BOOL sent;

- (id)initWithLocation:(CLLocation*)loc;

@end
