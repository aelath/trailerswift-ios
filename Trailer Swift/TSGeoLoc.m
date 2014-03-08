//
//  TSGeoLoc.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSGeoLoc.h"

@interface TSGeoLoc ()

@end

@implementation TSGeoLoc

- (id)initWithLocation:(CLLocation*)location
{
    self = [super init];
    self.location = location;
    self.timeStamp = location.timestamp;
    
    return self;
}

@end
