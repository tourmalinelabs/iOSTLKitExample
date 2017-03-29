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

@import SVProgressHUD;

@interface DrivesTableViewController ()
@property (strong, nonatomic) CKActivityManager  *activityManager;
@property (strong, nonatomic) NSArray<CKDrive *> *drives;
- (IBAction)onBarButtonItemStop:(id)sender;
- (void)startDriveMonitoring;
- (void)stopDriveMonitoring;
- (void)queryDrives;
@end

@implementation DrivesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // holds the drives
    self.drives = @[];
    
    // starts drive monitoring
    [self startDriveMonitoring];
    
    // query the drives
    [self queryDrives];
}

- (void)dealloc {
    // stop drive mpnitoring
    [self stopDriveMonitoring];
    // dismiss progress i needed
    [SVProgressHUD dismiss];
}

- (IBAction)onBarButtonItemStop:(id)sender {
    [self stopDriveMonitoring];
}

- (void)startDriveMonitoring {
    
    // initialize CKActivityManager
    NSLog(@"<< Initializing Activity Manager >>");
    self.activityManager = CKActivityManager.new;
    
    // start drive monitoring
    NSLog(@"<< Starting Drive Monitoring >>");
    __weak __typeof__(self) weakSelf = self;
    [self.activityManager startDriveMonitoringToQueue:dispatch_get_main_queue()
                                          withHandler:^(CKActivityEvent * _Nullable evt, NSError * _Nullable error) {
                                              // handle error
                                              if (error) {
                                                  NSLog(@"Failed to start drive monitoring with error: %@", error);
                                                  return;
                                              }
                                              NSLog(@"New CKActivityEvent: %@", evt);
                                              
                                              if (!weakSelf) return;
                                              
                                              // update the drives once the activity is finalized
                                              if (evt.type == CKActivityEventFinalized) {
                                                  [weakSelf queryDrives];
                                              }
                                          }];
}

- (void)stopDriveMonitoring {
    // stop Drive Monitoring
    [self.activityManager stopDriveMonitoring];
    NSLog(@"<< Stopped Drive monitoring >>");
}

- (void)queryDrives {
    // show progress
    [SVProgressHUD show];
    
    __weak __typeof__(self) weakSelf = self;
    // query drives since last week with a limit of max 50 results
    [self.activityManager queryDrivesFromDate:[NSDate.date dateByAddingTimeInterval:-7*24*60*60]
                                       toDate:NSDate.distantFuture
                                    withLimit:50
                                      toQueue:dispatch_get_main_queue()
                                  withHandler:^(NSArray<__kindof CKActivity *> * _Nullable activities, NSError * _Nullable err) {
                                      [SVProgressHUD dismiss];
                                      
                                      if (err) {
                                          NSLog(@"Query Drives failed with error: %@", err);
                                          return;
                                      }
                                      
                                      NSLog(@"Query Drives result: %@", activities);
                                      if (!weakSelf) return;
                                      
                                      // updates the ui
                                      weakSelf.drives = activities;
                                      [weakSelf.tableView reloadData];
                                  }];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.drives.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.drives[indexPath.row].description;
    return cell;
}

@end
