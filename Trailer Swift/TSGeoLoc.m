//
//  TSGeoLoc.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/18/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSGeoLoc.h"


@implementation TSGeoLoc

@dynamic friendlyName;
@dynamic locationData;
@dynamic locationID;
@dynamic sent;
@dynamic timeStamp;
@synthesize location;

- (CLLocation*)location
{
    if (!location) {
        CLLocation *loc = [NSKeyedUnarchiver unarchiveObjectWithData:self.locationData];
        location = loc;
    }
    return location;
}

- (void)setLocation:(CLLocation *)loc
{
    location = loc;
    [self willChangeValueForKey:@"location"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:loc];
    self.locationData = data;
    [self didChangeValueForKey:@"location"];
}

- (void)setSent:(NSNumber *)sent
{
    [self willChangeValueForKey:@"sent"];
    [self setPrimitiveValue:sent forKey:@"sent"];
    [self didChangeValueForKey:@"sent"];
}
//
//- (void)setLocationID:(NSString *)locID
//{
//    NSString *key = @"locationID";
//    [self willChangeValueForKey:key];
//    ;
//    [self didChangeValueForKey:key];
//}
@end
