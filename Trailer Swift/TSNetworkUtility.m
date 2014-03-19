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
#import "TSGeoLocStore.h"
#import "TSGeoLoc.h"

#define kTSURLLocationDataEndpoint @"http://www.trailer-swift.com/tours/%@/locations.json"
#define kTSURLToursEndpoint @"http://www.trailer-swift.com/tours.json?user_email=%@&user_token=%@"
#define kTSURLAuthEndpoint @"http://www.trailer-swift.com/users/sign_in.json"
#define kTSTestingUsername @""
#define kTSTestingPassword @""

@interface TSNetworkUtility ()

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *tourID;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) TSGeoLoc *pendingParam;

@end

@implementation TSNetworkUtility

#pragma mark - Setup
- (id)initWithUsername:(NSString*)username password:(NSString*)password
{
    self = [super init];
    if (self) {
        _userID = username;
        _password = password;
    }
    return self;
}

- (id)init
{
    TSGeoLocStore *store = [TSGeoLocStore sharedStore];
    return [self initWithUsername:store.username password:store.password];
}

#pragma mark - Networking
- (void)sendGeoLocation:(TSGeoLoc *)geoLoc sender:(id)sender
{
    self.pendingParam = geoLoc;
    
    if (!self.authToken) {
        [self authenticate];
        return;
    } else if (!self.tourID) {
        [self getTours];
        return;
    }
    
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
        if ([sender respondsToSelector:@selector(locationResponseWithObject:locationID:)]) {
            [(TSGeoLocManager*)sender locationResponseWithObject:geoLoc locationID:[responseObject objectForKey:@"id"]];
        }
        self.pendingParam = nil;
        NSLog(@"** SUCCESS **");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request: %@", operation.request.allHTTPHeaderFields);
        NSLog(@"Error: %@", error);
        // Cry
    }];
}

- (NSDictionary*)formulateParameters:(TSGeoLoc *)geoLoc
{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:@[ self.authToken, self.userID ]
                                                                        forKeys:@[ @"user_token", @"user_email" ]];

    CLLocation *location = [geoLoc location];
    NSString *date = [self.dateFormatter stringFromDate:location.timestamp];
    NSDictionary *entryDict = @{@"lat": @(location.coordinate.latitude),
                                @"lng": @(location.coordinate.longitude),
                                @"located_at": date};
    
    NSDictionary *locsDict = @{@"location": entryDict};
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

    NSString *url = kTSURLAuthEndpoint;
    NSDictionary *parameters = @{@"user": @{@"email": kTSTestingUsername,
                                             @"password": kTSTestingPassword }
                                  };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self authResponseWithObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ \n\n Request Operation: %@", error, operation);
        // Cry
    }];
}

- (void)authResponseWithObject:(id)object
{
    // Set the authToken
    self.authToken = [object objectForKey:@"auth_token"];
    self.userID = [object objectForKey:@"email"];
    
    // Send any pending requests that got caught on auth
    if (self.pendingParam) {
        [self sendGeoLocation:self.pendingParam sender:[[TSGeoLocStore sharedStore] availableGeoLocManager]];
    }
}

- (void)getTours
{
    NSLog(@"** GET Tour ID **");
    
    if (!self.authToken) {
        [self authenticate];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:kTSURLToursEndpoint, self.userID, self.authToken];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Operation: %@", operation);
        NSLog(@"JSON: %@", responseObject);
        [self toursResponseWithObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)toursResponseWithObject:(id)object
{
    // Returns an array of tours...
    // Set the tour ID
    self.tourID = [[object firstObject] objectForKey:@"id"];
    
    // Send any pending requests that got caught on auth
    if (self.pendingParam) {
        [self sendGeoLocation:self.pendingParam sender:[[TSGeoLocStore sharedStore] availableGeoLocManager]];
    }
}
@end
