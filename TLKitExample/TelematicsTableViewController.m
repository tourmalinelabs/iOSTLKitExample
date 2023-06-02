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

#import "TelematicsTableViewController.h"
#import "TelematicsCell.h"
#import <TLKit/TLActivityManager.h>
#import <TLKit/TLTelematicsEvent.h>
#import <TLKit/TLActivity.h>

@import SVProgressHUD;

NS_ASSUME_NONNULL_BEGIN

@interface TelematicsTableViewController ()
// Internal
@property (strong, nonatomic) TLActivityManager *activityManager;
@property (strong, nonatomic) NSArray<TLTelematicsEvent *> *events;
// Private
- (void)startTelematicsMonitoring;
- (void)stopTelematicsMonitoring;
- (void)queryTelematicsEvents;
@end

NS_ASSUME_NONNULL_END

@implementation TelematicsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // holds the events
    self.events = @[];
    
    // start telematics events monitoring
    [self startTelematicsMonitoring];
    
    // query previous telematics events
    [self queryTelematicsEvents];
}

- (void)dealloc {
    // stop telematics events monitoring
    [self stopTelematicsMonitoring];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startTelematicsMonitoring {
    // initialize TLActivityManager
    NSLog(@"<< Initializing Activity Manager >>");
    self.activityManager = TLActivityManager.new;
    
    // start telematics event monitoring
    NSLog(@"<< Starting Telematics events Monitoring >>");
    __weak __typeof__(self) weakSelf = self;
    [self.activityManager listenForTelematicsEventsToQueue:dispatch_get_main_queue()
                                               withHandler:^(TLTelematicsEvent * _Nullable evt, NSError * _Nullable err) {
        // handle error
        if (err) {
            NSLog(@"Failed to register lstnr: %@", err);
            return;
        }

        NSLog(@"New TLTelematicsEvent: %@", evt);
        if (!weakSelf) return;

        // hold the new telematics event
        weakSelf.events = [weakSelf.events arrayByAddingObject:evt];

        // reload table view
        [weakSelf.tableView reloadData];
    }];
}

- (void)stopTelematicsMonitoring {
    // stop Telematics events Monitoring
    [self.activityManager stopListeningForTelematicsEvents];
    NSLog(@"<< Stopped Telematics monitoring >>");
}

- (void)queryTelematicsEvents {
    // show progress
    [SVProgressHUD setMinimumDismissTimeInterval:1.0f];
    [SVProgressHUD show];
    
    __weak __typeof__(self) weakSelf = self;
    
    void(^QueryTelematicsForTrip)(NSUUID *tripId) = ^(NSUUID *tripId) {
        
        if (!weakSelf) {
            [SVProgressHUD dismiss];
            return;
        }
        
        [weakSelf.activityManager queryTelematicsEventsForTrip:tripId
                                                       toQueue:dispatch_get_main_queue()
                                                   withHandler:^(NSArray * _Nullable results, NSError * _Nullable error) {
            [SVProgressHUD dismiss];

            // handle error
            if (error) {
                NSLog(@"Query Telematics failed with error: %@",
                      error);
                return;
            }

            NSLog(@"Query Telematics events result: %@", results);
            if (!weakSelf) return;

            if (results.count == 0) {
                [SVProgressHUD showInfoWithStatus:@"No Data"];
            }

            // holds events and reload table view
            weakSelf.events = results;
            [weakSelf.tableView reloadData];
        }];
    };

    NSDate *now = NSDate.date;
    NSDate *lastMonth = [now dateByAddingTimeInterval:-2592000];
    
    [self.activityManager queryTripsFromDate:lastMonth
                                      toDate:now
                                   withLimit:1
                                     toQueue:dispatch_get_main_queue()
                                 withHandler:^(NSArray<__kindof TLActivity *> * _Nullable activities, NSError * _Nullable err) {
        if (!weakSelf) {
            [SVProgressHUD dismiss];
            return;
        }

        // handle error
        if (err) {
            NSLog(@"Query Trips failed with error: %@", err);
            [SVProgressHUD showErrorWithStatus:@"Query Trips failed"];
            return;
        }
        // no data to display
        if (activities.count == 0) {
            [SVProgressHUD showInfoWithStatus:@"No Data"];
            return;
        }
        
        // query telematics for the latest drive
        QueryTelematicsForTrip(activities.firstObject.id);
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TelematicsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TelematicsCellIdentifier" forIndexPath:indexPath];
    [cell configureCellWithTelematicsEvent:self.events[indexPath.row]];
    return cell;
}

@end
