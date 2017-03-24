/*******************************************************************************
 * Copyright 2016 Tourmaline Labs, Inc. All rights reserved.
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
 ******************************************************************************/

#import "FeaturesTableViewController.h"
#import <TLKit/CKLocationManager.h>
#import <TLKit/CKActivityManager.h>

@interface FeaturesTableViewController ()
@property(nonatomic) CKLocationManager *locationManager;
@property(nonatomic) CKActivityManager *activityManager;
@end

@implementation FeaturesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Features";

    // Instantiate CK managers
    self.locationManager = [CKLocationManager new];
    self.activityManager = [CKActivityManager new];

    // Register CK Feature listeners
    [self setupContextKitFeatures];
}

- (void)setupContextKitFeatures {
    [self startLocationMonitoring];
    [self startDriveMonitoring];
}

- (void)startLocationMonitoring {
    // Register for Location Monitoring with CKLocationManager
    [self.locationManager
            startUpdatingLocationsToQueue:dispatch_get_main_queue()
                              withHandler:^(CKLocation *location) {
                                  NSLog(@"Got Location Update: %@", location);
                              }
                               completion:^(BOOL successful, NSError *error) {
                                   if (error) {
                                       NSLog(@"Failed to start loma: %@",
                                             error);
                                       return;
                                   }

                                   NSLog(@"<< Started Location Monitoring >>");
                               }];
}


- (void)startDriveMonitoring {
    // Register for Drive Monitoring with CKActivityManager
    [self.activityManager
            startDriveMonitoringToQueue:dispatch_get_main_queue()
                            withHandler:
                                    ^(CKActivityEvent *evt,
                                            NSError *err) {
                                        NSLog(@"Drive evt: %@", evt);
                                    }];
    NSLog(@"<<<<< Started Drive Monitoring >>>>>");
}

#pragma mark - Table view delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"DrivesSegue" sender:nil];
            }
            break;
        case 1:
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"LocationsSegue" sender:nil];
            }
            break;
        default:
            break;
    }
}

@end
