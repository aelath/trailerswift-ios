//
//  TSGeoLoc.h
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/18/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>


@interface TSGeoLoc : NSManagedObject

@property (nonatomic, retain) NSString *friendlyName;
@property (nonatomic, retain) NSData *locationData;
@property (nonatomic, retain) NSString *locationID;
@property (nonatomic, retain) NSNumber *sent;
@property (nonatomic, retain) NSDate *timeStamp;
@property (nonatomic, strong) CLLocation *location;

@end
