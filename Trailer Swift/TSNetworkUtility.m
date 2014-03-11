//
//  TSNetworkUtility.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSNetworkUtility.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import "TSGeoLoc.h"

#define kTSURLLocationDataEndpoint @"http://www.trailer-swift.com/%@/locations.json"
#define kTSURLToursEndpoint @"http://www.trailer-swift.com/tours.json?user_email=%@&user_token=%@"
#define kTSURLAuthEndpoint @"https://www.trailer-swift.com/users/sign_in.json"
#define kTSTestingUsername @"ptk921@gmail.com"
#define kTSTestingPassword @"password"

@interface TSNetworkUtility ()

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *tourID;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) TSGeoLoc *pendingParam;

@end

@implementation TSNetworkUtility

- (void)sendGeoLocation:(TSGeoLoc *)geoLoc
{
    self.pendingParam = geoLoc;
    
    if (!self.authToken) {
        [self authenticate];
        return;
    } else if (!self.tourID) {
        [self getTours];
        return;
    }
    
    __weak TSNetworkUtility *me = self;
    // Build the URL for the request
    NSString *url = [NSString stringWithFormat:kTSURLLocationDataEndpoint, self.tourID];
    
    // Build the request body from the geoLocs array plus auth
    NSDictionary *parameters = [self formulateParameters:geoLoc];
    
    NSLog(@"** Sending the Location **");
    // Start sending the request:
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        // Call the "delegate" method in the TSGeoLocManager
        me.pendingParam = nil;
        NSLog(@"** SUCCESS **");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // Cry
    }];
}

- (NSDictionary*)formulateParameters:(TSGeoLoc *)geoLoc
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:@[ self.authToken, self.userID ]
                                                                        forKeys:@[ @"user_token", @"user_email" ]];

    CLLocation *location = geoLoc.location;
    NSString *date = [self.dateFormatter stringFromDate:location.timestamp];
    NSDictionary *entryDict = @{@"lat": @(location.coordinate.latitude),
                                @"lng": @(location.coordinate.longitude),
                                @"located_at": date};
    
    NSDictionary *locsDict = @{@"locations": entryDict};
    [paramDict addEntriesFromDictionary:locsDict];
    
    return paramDict;
}

- (NSDateFormatter*)dateFormatter
{
    // If the ISO8601 date formatter doesn't exist, create/return it
    if (!_dateFormatter) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        _dateFormatter = df;
    }
    return _dateFormatter;
}

- (void)authenticate
{
    NSLog(@"** Authenticating **");
    // Make a request with username password and POST it
    __weak TSNetworkUtility *me = self;

    NSString *url = kTSURLAuthEndpoint;
    NSDictionary *parameters = @{@"user": @{@"email": kTSTestingUsername,
                                             @"password": kTSTestingPassword }
                                  };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [me authResponseWithObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // Cry
    }];
}

- (void)authResponseWithObject:(id)object
{
    // Set the authToken
    self.authToken = [object objectForKey:@"auth_token"];
    
    // Send any pending requests that got caught on auth
    if (self.pendingParam) {
        [self sendGeoLocation:self.pendingParam];
    }
}

- (void)getTours
{
    NSLog(@"** GET Tour ID **");
    __weak TSNetworkUtility *me = self;
    
    if (!self.authToken) {
        [self authenticate];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:kTSURLToursEndpoint, self.userID, self.authToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [me toursResponseWithObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)toursResponseWithObject:(id)object
{
    // Set the tour ID
    self.tourID = [object objectForKey:@"tour"];
    
    // Send any pending requests that got caught on auth
    if (self.pendingParam) {
        [self sendGeoLocation:self.pendingParam];
    }
}
@end
