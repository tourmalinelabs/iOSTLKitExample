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

#import "DrivesTableViewController.h"
#import <TLKit/CKActivityManager.h>
#import <TLKit/CKActivityEvent.h>
#import <TLKit/CKDrive.h>

@interface DrivesTableViewController ()
@property(strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property(nonatomic) CKActivityManager *actMgr;
@property(nonatomic) NSArray *dataSource;
@end

@implementation DrivesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // UI Code
    self.navigationItem.title = @"Drives";
    self.navigationItem.rightBarButtonItem = self.stopButton;

    // Init CK Activity Manager
    self.actMgr = [CKActivityManager new];

    // Update the Data Source (to update the UI)
    [self updateDataSource];

    // Register Listener to get drive event updates
    [self registerDriveListener];
}

- (void)updateDataSource {
    // Query for all drives
    __weak DrivesTableViewController *weakSelf = self;
    [self.actMgr queryDrivesFromDate:[NSDate distantPast]
                              toDate:[NSDate distantFuture]
                           withLimit:INT32_MAX
                             toQueue:dispatch_get_main_queue()
                         withHandler:^(NSArray *drives, NSError *error) {
                             if (error) {
                                 NSLog(@"Drive query error: %@", error);
                                 return;
                             }

                             NSLog(@"Drive query result");
                             for (id drive in drives) {
                                 NSLog(@"    %@", drive);
                             }

                             //Set data source and refresh the TableView
                             weakSelf.dataSource = drives;
                             [weakSelf.tableView reloadData];
                         }];

    // Query for single drive
    NSUUID *driveId = nil;
    [self.actMgr queryDriveById:driveId
                        toQueue:dispatch_get_main_queue()
                    withHandler:^(NSArray *drives, NSError *error) {
                        if (error) {
                            NSLog(@"Drive query error: %@", error);
                            return;
                        }

                        if (drives.count) {
                            NSLog(@"Found drive: %@", [drives firstObject]);
                        }
                    }];
}

- (void)registerDriveListener {
    NSLog(@"Listening for new drive events...");
    __weak DrivesTableViewController *weakSelf = self;
    [self.actMgr
        startDriveMonitoringToQueue:dispatch_get_main_queue()
                        withHandler:^(CKActivityEvent *evt, NSError * err) {
                            // Update UI
                            [weakSelf updateDataSource];
                            NSLog(@"Drive event: %@", evt);
                        }];
}

- (IBAction)stopDriveButtonPressed:(id)sender {
    // Stop Drive Monitoring
    [self.actMgr stopDriveMonitoring];
    NSLog(@"Stopped Drive monitoring");
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"cell"
                                        forIndexPath:indexPath];

    CKDrive *drive = self.dataSource[indexPath.row];

    cell.textLabel.text = [drive description];

    return cell;
}

#pragma mark - TableView delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
