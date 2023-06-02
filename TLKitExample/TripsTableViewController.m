/* *****************************************************************************
 * Copyright 2023 Tourmaline Labs, Inc. All rights reserved.
 * Confidential & Proprietary - Tourmaline Labs, Inc. ("TLI")
 *
 * The party receiving this software directly from TLI (the "Recipient")
 * may use this software as reasonably necessary solely for the purposes
 * set forth in the agreement between the Recipient and TLI (the
 * "Agreement"). The software may be used in source code form solely by
 * the Recipient's employees (if any) authorized by the Agreement. Unless
 * expressly authorized in the Agreement, the Recipient may not sublicense,
 * assign, transfer or otherwise provide the source code to any third
 * party. Tourmaline Labs, Inc. retains all ownership rights in and
 * to the software
 *
 * This notice supersedes any other TLI notices contained within the software
 * except copyright notices indicating different years of publication for
 * different portions of the software. This notice does not supersede the
 * application of any third party copyright notice to that third party's
 * code.
 * ****************************************************************************/

#import "TripsTableViewController.h"
#import "TripCell.h"

#import <TLKit/TLActivityManager.h>
#import <TLKit/TLActivityEvent.h>
#import <TLKit/TLTrip.h>

@import SVProgressHUD;

NS_ASSUME_NONNULL_BEGIN

@interface TripsTableViewController () <UITableViewDataSource, UITableViewDelegate>
// IBActions
@property (weak,   nonatomic) IBOutlet UITableView *tableView;
// Internal
@property (strong, nonatomic) TLActivityManager  *activityManager;
@property (strong, nonatomic) NSArray<TLTrip *> *trips;
// Private
- (void)startTripMonitoring;
- (void)stopTripMonitoring;
- (void)mergeTripsWithEvent:(TLActivityEvent *)event;
- (void)queryTrips;
@end

NS_ASSUME_NONNULL_END

@implementation TripsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // holds the trips
    self.trips = @[];
    
    // starts trip monitoring
    [self startTripMonitoring];
    
    // query the trips
    [self queryTrips];
}

- (void)dealloc {
    // stop trip monitoring
    [self stopTripMonitoring];
    // dismiss progress i needed
    [SVProgressHUD dismiss];
}

- (void)startTripMonitoring {
    
    // initialize TLActivityManager
    NSLog(@"<< Initializing Activity Manager >>");
    self.activityManager = TLActivityManager.new;
    
    // start trip monitoring
    NSLog(@"<< Starting Trip Monitoring >>");
    __weak __typeof__(self) weakSelf = self;
    [self.activityManager listenForTripEventsToQueue:dispatch_get_main_queue()
                                         withHandler:^(TLActivityEvent * _Nullable evt, NSError * _Nullable error) {
        // handle error
        if (error) {
            NSLog(@"Failed to register lstnr: %@", error);
            return;
        }

        NSLog(@"New TLActivityEvent: %@", evt);
        if (!weakSelf) return;
        [weakSelf mergeTripsWithEvent:evt];
    }];
}

- (void)stopTripMonitoring {
    // stop trip Monitoring
    [self.activityManager stopListeningForTripEvents];
    NSLog(@"<< Stopped Trips monitoring >>");
}

- (void)mergeTripsWithEvent:(TLActivityEvent *)event {
    NSMutableArray<TLTrip *> *trips = self.trips.mutableCopy;
    
    // new event trip id
    NSUUID *uuid = event.activity.id;
    
    // lookup for the trip
    TLTrip *trip = nil;
    for (TLTrip *d in trips) {
        if ([d.id isEqual:uuid]) {
            trip = d;
            break;
        }
    }
    
    // removes the trip if found
    if (trip) {
        [trips removeObject:trip];
    }
    
    // add the last event's trip
    [trips addObject:(TLTrip *)event.activity];
    
    // sort the trips
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO];
    [trips sortUsingDescriptors:@[sort]];
    self.trips = trips.copy;

    [self.tableView reloadData];
}

- (void)queryTrips {
    // show progress
    [SVProgressHUD show];
    
    __weak __typeof__(self) weakSelf = self;
    // query trips since last week with a limit of max 10 results
    [self.activityManager queryTripsFromDate:NSDate.distantPast
                                      toDate:NSDate.distantFuture
                                   withLimit:10
                                     toQueue:dispatch_get_main_queue()
                                 withHandler:^(NSArray<__kindof TLActivity *> * _Nullable activities, NSError * _Nullable err) {
        [SVProgressHUD dismiss];

        // handle error
        if (err) {
            NSLog(@"Query Trips failed with error: %@", err);
            return;
        }

        NSLog(@"Query Trips result: %@", activities);
        if (!weakSelf) return;

        weakSelf.trips = activities;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TripCellIdentifier";
    TripCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    TLTrip *trip = self.trips[indexPath.row];
    [cell configureCellWithTrip:trip];
    return cell;
}

@end
