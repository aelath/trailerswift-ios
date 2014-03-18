//
//  TSGeoLocStore.m
//  Trailer Swift
//
//  Created by Jacob Kobernik on 3/8/14.
//  Copyright (c) 2014 Jacob Kobernik. All rights reserved.
//

#import "TSGeoLocStore.h"
#import "TSGeoLoc.h"
#import "TSGeoLocPrivateProperties.h"
@import CoreData;

@interface TSGeoLocStore ()

@property (nonatomic, strong) TSGeoLocManager *gLocMan;
@property (nonatomic, strong) NSMutableArray *allGeoLocs;
@property (nonatomic, strong) NSMutableArray *unsentGeoLocs;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation TSGeoLocStore

#pragma mark - Setup

+ (instancetype)sharedStore
{
    static TSGeoLocStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[TSGeoLocStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        NSString *path = [self archivePathForCoreData:YES];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            @throw [NSException exceptionWithName:@"Open Failure"
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = psc;
        
        [self loadAllGeoLocs];
        [self loadUnsentGeoLocs];
        
    };
    return self;
}

- (NSString*)archivePathForCoreData:(BOOL)coreData
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    if (coreData == YES) {
        return [documentDirectory stringByAppendingString:@"store.data"];
    } else {
        return [documentDirectory stringByAppendingString:@"config.archive"];
    }
}

- (void)loadAllGeoLocs
{
    if (!self.allGeoLocs) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"TSGeoLoc"
                                             inManagedObjectContext:self.context];
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];

        request.entity = e;
        request.sortDescriptors = @[sd];
        
        NSError *error = nil;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch Failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
    
        self.allGeoLocs = [[NSMutableArray alloc] initWithArray:result];
    }
    
}

- (void)loadUnsentGeoLocs
{
    if (!self.unsentGeoLocs) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [NSEntityDescription entityForName:@"TSGeoLoc"
                                             inManagedObjectContext:self.context];
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
        NSPredicate *p = [NSPredicate predicateWithFormat:@"sent == NO"];
        
        request.entity = e;
        request.sortDescriptors = @[sd];
        request.predicate = p;
        
        NSError *error = nil;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch Failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.unsentGeoLocs = [[NSMutableArray alloc] initWithArray:result];

    }
}

#pragma mark - Operations

- (TSGeoLoc*)newGeoLocWithLocation:(CLLocation *)location
{
    TSGeoLoc *geoLoc = [NSEntityDescription insertNewObjectForEntityForName:@"TSGeoLoc"
                                                     inManagedObjectContext:self.context];
//    if (!self.allGeoLocs) {
//        self.allGeoLocs = [NSMutableArray arrayWithObject:geoLoc];
//        if (!self.unsentGeoLocs) {
//            self.unsentGeoLocs = [NSMutableArray arrayWithObject:geoLoc];
//        } else {
//            [self.unsentGeoLocs addObject:geoLoc];
//        }
//    } else {
//        [self.allGeoLocs addObject:geoLoc];
//    }

    [self.unsentGeoLocs addObject:geoLoc];
    [self.allGeoLocs addObject:geoLoc];
    
    return geoLoc;
}

- (TSGeoLocManager*)availableGeoLocManager
{
    if (!self.gLocMan) {
        self.gLocMan = [[TSGeoLocManager alloc] init];
    }
    return self.gLocMan;
}

- (void)updateGeoLoc:(TSGeoLoc *)geoLoc withSentandLocationID:(NSString *)locationID
{
    geoLoc.sent = YES;
    geoLoc.locationID = locationID;
    [self.unsentGeoLocs removeObject:geoLoc];
}

- (NSArray*)getUnsentGeoLocs
{
    return self.unsentGeoLocs;
}

- (void)deleteGeoLoc:(TSGeoLoc *)geoLoc
{
    [self.allGeoLocs removeObject:geoLoc];
    if (!geoLoc.sent) {
        [self.unsentGeoLocs removeObject:geoLoc];
    }
    geoLoc = nil;
}

- (BOOL)saveChanges
{
    NSError *error = nil;
    BOOL successful = [self.context save:&error];
    if (!successful) {
        NSLog(@"Error Saving: %@", [error localizedDescription]);
    }
    return successful;
}

@end
