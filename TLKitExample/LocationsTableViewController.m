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

#import "LocationsTableViewController.h"
#import <TLKit/CKLocationManager.h>
#import <TLKit/CKLocation.h>

@interface LocationsTableViewController ()
@property(nonatomic) CKLocationManager *locationManager;
@property(nonatomic) NSArray *dataSource;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@end

@implementation LocationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // UI Code
    self.navigationItem.title = @"Locations";
    self.navigationItem.rightBarButtonItem = self.stopButton;

    // Init CK Location Manager
    self.locationManager = [CKLocationManager new];

    // Update the Data Source (to update the UI)
    [self updateDataSource];
}

- (void)updateDataSource {
    __weak LocationsTableViewController *weakSelf = self;

    // Query last 50 locations
    [self.locationManager
        queryLocationsFromDate:[NSDate distantPast]
                        toDate:[NSDate distantFuture]
                     withLimit:50
                       toQueue:dispatch_get_main_queue()
                   withHandler:^(NSArray *locations,
                       NSError *err) {
                       NSLog(@"Locations Query Result:");
                       for (id location in locations) {
                           NSLog(@"    %@", location);
                       }

                       weakSelf.dataSource = locations;
                       [weakSelf.tableView reloadData];
                   }];
}

- (IBAction)stopButtonPressed:(id)sender {
    // Unregisters locations listener, stops updating locations
    // Crashes on ver. 1.3-16010500 of CK
//    [self.locationManager stopUpdatingLocation];
    NSLog(@"Stopped Location Update Monitoring");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"cell"
                                        forIndexPath:indexPath];

    CKLocation *location = self.dataSource[indexPath.row];

    cell.textLabel.text = [location description];

    return cell;
}

#pragma mark - TableView delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
