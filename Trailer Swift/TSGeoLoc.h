//
//  TSGeoLoc.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

@interface TSGeoLoc : NSManagedObject

- (id)awakeWithLocation:(CLLocation*)loc;
- (CLLocation*)location;

@end
