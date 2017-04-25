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
#import "DriveCell.h"

#import <TLKit/CKActivityManager.h>
#import <TLKit/CKActivityEvent.h>
#import <TLKit/CKDrive.h>

@import SVProgressHUD;

NS_ASSUME_NONNULL_BEGIN

@interface DrivesTableViewController () <UITableViewDataSource, UITableViewDelegate>
// IBActions
@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton    *buttonStartDrive;
// Internal
@property (strong, nonatomic) CKActivityManager  *activityManager;
@property (strong, nonatomic) NSArray<CKDrive *> *drives;
@property (strong, nonatomic) NSArray<CKDrive *> *active;
// IBActions
- (IBAction)onButtonStartDrive:(id)sender;
// Private
- (void)startDriveMonitoring;
- (void)stopDriveMonitoring;
- (void)mergeDrivesWithEvent:(CKActivityEvent *)event;
- (void)queryDrives;
- (void)queryActiveDrives;
- (BOOL)isDriveActiveManual:(CKDrive *)drive;
- (void)updateStartDriveButtonVisibility;
@end

NS_ASSUME_NONNULL_END

@implementation DrivesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // holds the drives
    self.drives = @[];
    // holds the current active manual drives
    self.active = @[];

    // show / hide Start manual drive button
    [self updateStartDriveButtonVisibility];
    
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

- (IBAction)onButtonStartDrive:(__unused id)sender {
    if (self.manual) {
        [self.activityManager startManualTrip];
    }
}

- (void)updateStartDriveButtonVisibility {
    UIEdgeInsets contentInset = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    if (self.manual) {
        CGFloat height = CGRectGetHeight(self.buttonStartDrive.bounds);
        contentInset.bottom = height;
        self.tableView.contentInset = contentInset;
        scrollIndicatorInsets.bottom = height;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        self.buttonStartDrive.hidden = NO;
    } else {
        contentInset.bottom = 0.0f;
        self.tableView.contentInset = contentInset;
        scrollIndicatorInsets.bottom = 0.0f;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
        self.buttonStartDrive.hidden = YES;
    }
}

- (void)startDriveMonitoring {
    
    // initialize CKActivityManager
    NSLog(@"<< Initializing Activity Manager >>");
    self.activityManager = CKActivityManager.new;
    
    // start drive monitoring
    NSLog(@"<< Starting Drive Monitoring >>");
    __weak __typeof__(self) weakSelf = self;
    [self.activityManager
        listenForDriveEventsToQueue:dispatch_get_main_queue()
                        withHandler:^(CKActivityEvent * _Nullable evt,
                            NSError * _Nullable error) {
                                              
                            // handle error
                            if (error) {
                                NSLog(@"Failed to register lstnr: %@", error);
                                return;
                            }
                                              
                            NSLog(@"New CKActivityEvent: %@", evt);
                            if (!weakSelf) return;

                            // update the drives once the activity is finalized
                            if (evt.type == CKActivityEventFinalized) {
                                [weakSelf queryDrives];
                            } else {
                                [weakSelf mergeDrivesWithEvent:evt];
                            }
                        }];
}

- (void)stopDriveMonitoring {
    // stop Drive Monitoring
    [self.activityManager stopListeningForDriveEvents];
    NSLog(@"<< Stopped Drive monitoring >>");
}

- (void)mergeDrivesWithEvent:(CKActivityEvent *)event {
    NSMutableArray<CKDrive *> *drives = self.drives.mutableCopy;
    
    // new event drive id
    NSUUID *uuid = event.activity.id;
    
    // lookup for the drive
    CKDrive *drive = nil;
    for (CKDrive *d in drives) {
        if ([d.id isEqual:uuid]) {
            drive = d;
            break;
        }
    }
    
    // removes the drive if found
    if (drive) {
        [drives removeObject:drive];
    }
    
    // add the last event's drive
    [drives addObject:(CKDrive *)event.activity];
    
    // sort the drives
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO];
    [drives sortUsingDescriptors:@[sort]];
    self.drives = drives.copy;
    
    // query active manual drives before reloading
    [self queryActiveDrives];
    [self.tableView reloadData];
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
                                      
                                      // handle error
                                      if (err) {
                                          NSLog(@"Query Drives failed with error: %@", err);
                                          return;
                                      }
                                      
                                      NSLog(@"Query Drives result: %@", activities);
                                      if (!weakSelf) return;
                                      
                                      weakSelf.drives = activities;
                                      if (weakSelf.manual) {
                                          [weakSelf queryActiveDrives];
                                      } else {
                                          [weakSelf.tableView reloadData];
                                      }
                                  }];
}

- (void)queryActiveDrives {
    // only query manual active drives if in manual drive detection mode
    if (self.manual) {
        __weak __typeof__(self) weakSelf = self;
        [self.activityManager queryManualTripstoQueue:dispatch_get_main_queue()
                                          withHandler:^(NSArray<__kindof CKActivity *> * _Nullable activities, NSError * _Nullable err) {
                                              // handle error
                                              if (err) {
                                                  NSLog(@"Query Active Manual Drives failed with error: %@", err);
                                                  return;
                                              }
                                              
                                              NSLog(@"Query Active Manual Drives result: %@", activities);
                                              if (!weakSelf) return;
                                              
                                              weakSelf.active = activities;
                                              [weakSelf.tableView reloadData];
                                          }];
    }
}

- (BOOL)isDriveActiveManual:(CKDrive *)drive {
    if (self.manual) {
        for (CKDrive *act in self.active)
            if ([act.id isEqual:drive.id])
                return YES;
    }
    return NO;
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.drives.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DriveCellIdentifier";
    DriveCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    CKDrive *drive = self.drives[indexPath.row];
    [cell configureCellWithDrive:drive active:[self isDriveActiveManual:drive]];
    return cell;
}

@end
