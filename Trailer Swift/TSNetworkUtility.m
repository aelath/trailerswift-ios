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

#define kTSURLLocationDataEndpoint @"http://www.trailer-swift.com/users/%@/%@/locations"
#define kTSTourID @(8)  // Not sure how we will determine this yet?


@interface TSNetworkUtility ()

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *pendingParams;

@end

@implementation TSNetworkUtility

- (void)logIn
{
    
}

- (void)sendGeoLocations:(NSArray *)geoLocs
{
    if (!self.authToken) {
        [self authenticate];
    }
    // Build the URL for the request
    NSString *url = [NSString stringWithFormat:kTSURLLocationDataEndpoint, self.userID, kTSTourID];
    
    // Build the request body from the geoLocs array plus auth
    NSDictionary *parameters = [self formulateParameters:geoLocs];
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                          URLString:url
                                                                         parameters:parameters
                                                                              error:nil];
    
    // Start sending the request:
    
    // Options! I can use either the MANAGER...
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        // Call the "delegate" method in the TSGeoLocManager
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // Cry
    }];
    
    // ... or I can use the reqeust operation directly!
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // Cry
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (NSDictionary*)formulateParameters:(NSArray *)params
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject: self.authToken forKey:@"auth_token"];
    NSMutableArray *locsArray;
    
    for (TSGeoLoc *geoLoc in params) {
        CLLocation *location = geoLoc.location;
        NSString *date = [self.dateFormatter stringFromDate:location.timestamp];
        NSDictionary *entryDict = @{@"lat": @(location.coordinate.latitude),
                                    @"lng": @(location.coordinate.longitude),
                                    @"located_at": date};
        [locsArray addObject:entryDict];
    }
    
    NSDictionary *locsDict = @{@"locations": locsArray};
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
    // Make a request with username password and POST it
    
    // Competion block should call authResponse
}

- (void)authResponse
{
    // Set the authToken && userID ivar
    
    // Send any pending requests that got caught on auth
    if (self.pendingParams.count > 0) {
        [self sendGeoLocations:self.pendingParams];
    }
}
@end
