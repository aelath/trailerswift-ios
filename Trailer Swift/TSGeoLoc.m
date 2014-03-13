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

- (id)initWithLocation:(CLLocation*)loc
{
    self = [super init];
    self.location = loc;
    self.timeStamp = loc.timestamp;
    
    return self;
}

@end
