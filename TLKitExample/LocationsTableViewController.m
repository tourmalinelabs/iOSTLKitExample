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

#import "LocationsTableViewController.h"
#import "LocationCell.h"

#import <TLKit/TLLocationManager.h>
#import <TLKit/TLLocation.h>

@import SVProgressHUD;

@interface LocationsTableViewController ()
@property(nonatomic) TLLocationManager     *locationManager;
@property(nonatomic) NSArray<TLLocation *> *locations;
- (void)startLocationsMonitoring;
- (void)stopLocationsMonitoring;
- (void)queryLocations;
@end

@implementation LocationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // hold the locations
    self.locations = @[];
    
    // start monitoring locations
    [self startLocationsMonitoring];

    // query locations
    [self queryLocations];
}

- (void)dealloc {
    // stop monitoring locations
    [self stopLocationsMonitoring];
    // dimiss progress if needed
    [SVProgressHUD dismiss];
}

- (void)startLocationsMonitoring {
    
    // Instantiates CKLocationManager
    NSLog(@"<< Initializing Location Manager >>");
    self.locationManager = TLLocationManager.new;
    
    // Starts monitoring Locations
    NSLog(@"<< Starting Location Monitoring >>");
    [self.locationManager listenForLocationEventsToQueue:dispatch_get_main_queue()
                                             withHandler:^(TLLocation * _Nonnull location) {
        NSLog(@"Location Update: %@", location);
    } completion:^(BOOL successful, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to start location monitoring with error: %@", error);
            return;
        }
        NSLog(@"<< Started Location Monitoring >>");
    }];
}

- (void)stopLocationsMonitoring {
    // stop location monitoring
    [self.locationManager stopListeningForLocationEvents];
    NSLog(@"<< Stopped Location monitoring >>");
}

- (void)queryLocations {
    // shows progress
    [SVProgressHUD show];

    NSDate *now = NSDate.date;
    NSDate *lastWeek = [now dateByAddingTimeInterval:-604800];

    // query locations since last week with a limit of max 20 results
    __weak __typeof__(self) weakSelf = self;
    [self.locationManager queryLocationsFromDate:lastWeek
                                          toDate:now
                                       withLimit:20
                                         toQueue:dispatch_get_main_queue()
                                     withHandler:^(NSArray<TLLocation *> * _Nullable locations, NSError * _Nullable err) {
                                         // dismiss progress
                                         [SVProgressHUD dismiss];
                                         
                                         // handle error
                                         if (err) {
                                             NSLog(@"Query Locations failed with error: %@", err);
                                             return;
                                         }
                                         NSLog(@"Query Locations result: %@", locations);
                                         
                                         if (!weakSelf) return;
                                         
                                         // updates the ui
                                         weakSelf.locations = locations;
                                         [weakSelf.tableView reloadData];
                                     }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LocationCellIdentifier";
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell configureCellWithLocation:self.locations[indexPath.row]];
    return cell;
}

@end
