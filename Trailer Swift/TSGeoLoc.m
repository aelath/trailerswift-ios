//
//  TSGeoLoc.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSGeoLoc.h"
#import "TSGeoLocPrivateProperties.h"

@implementation TSGeoLoc

@dynamic location;
@dynamic friendlyName;
@dynamic timeStamp;
@dynamic locationID;
@dynamic sent;

- (id)awakeWithLocation:(CLLocation*)loc
{
    [super awakeFromInsert];
    self.location = loc;
    self.timeStamp = loc.timestamp;
    
    return self;
}

- (CLLocation*)location;
{
    return self.location;
}

@end
