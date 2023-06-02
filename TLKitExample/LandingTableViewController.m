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

#import "LandingTableViewController.h"
#import "TripsTableViewController.h"
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>
#import "CLLocationManager+TLKit.h"
#import "CMMotionActivityManager+TLKit.h"

#import <TLKit/TLKit.h>

@interface LandingTableViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak,   nonatomic) id <NSObject> tlkitObserver;
@property (weak,   nonatomic) id <NSObject> activeObserver;
@end

@implementation LandingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSBundle.mainBundle.infoDictionary[(NSString *)kCFBundleNameKey];

    self.locationManager = CLLocationManager.new;
    self.locationManager.delegate = self;

    __weak __typeof__(self) weakSelf = self;
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    self.tlkitObserver =
    [center addObserverForName:TLKitStatusDidChangeNotification
                                                    object:nil
                                                     queue:NSOperationQueue.mainQueue
                                                usingBlock:^(NSNotification * _Nonnull __unused note) {
        if (!weakSelf) return;
        [weakSelf.tableView reloadData];
    }];

    self.activeObserver =
    [center addObserverForName:UIApplicationDidBecomeActiveNotification
                        object:nil
                         queue:NSOperationQueue.mainQueue
                    usingBlock:^(NSNotification * _Nonnull __unused note) {
        if (!weakSelf) return;
        [weakSelf.tableView reloadData];
    }];
}

- (void)dealloc {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    if (self.tlkitObserver) {
        [center removeObserver:self.tlkitObserver];
        self.tlkitObserver = nil;
    }
    if (self.activeObserver) {
        [center removeObserver:self.activeObserver];
        self.activeObserver = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TLKit.isInitialized ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    if (section == 0 && CMMotionActivityManager.isActivityAvailable == NO) {
        return count - 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell.detailTextLabel.text = self.locationManager.formattedAuthorizationStatus;
                    cell.detailTextLabel.textColor = self.locationManager.authorizedAlwaysWithFullAccuracy ? UIColor.systemGreenColor : UIColor.systemRedColor;
                    break;
                }
                case 1: {
                    cell.detailTextLabel.text = CMMotionActivityManager.formattedAuthorizationStatus;
                    cell.detailTextLabel.textColor = CMMotionActivityManager.authorized ? UIColor.systemGreenColor : UIColor.systemRedColor;
                    break;
                }
            }
            break;
        }
        case 1: {
            if (TLKit.isInitialized) {
                cell.textLabel.text = @"Stop TLKit";
                cell.textLabel.textColor = UIColor.whiteColor;
                cell.backgroundColor = UIColor.systemRedColor;
            } else {
                cell.textLabel.text = @"Start TLKit";
                cell.textLabel.textColor = UIColor.systemBlueColor;
                cell.backgroundColor = UIColor.whiteColor;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            NSMutableString *footer = NSMutableString.string;
            NSString *locFooter = self.locationManager.formattedAuthorizationStatusFooter;
            NSString *motFooter = CMMotionActivityManager.formattedAuthorizationStatusFooter;
            if (locFooter != nil || motFooter != nil) {
                [footer appendString:@"TLKit may not work correctly with this permissions:"];
                if (locFooter.length) {
                    [footer appendFormat:@"\n• %@", locFooter];
                }
                if (motFooter.length) {
                    [footer appendFormat:@"\n• %@", motFooter];
                }
            }
            return footer;
        }
        case 1: {
            NSString *title = [NSString stringWithFormat:@"Version: %@", TLKit.version];
            if (TLKit.isInitialized) {
                title = [title stringByAppendingFormat:@"\nMode: %@\nStatus: %@",
                         TLKit.modeStr, AppDelegate.instance.authStatus];
            }
            return title;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0 && self.locationManager.authorizedAlwaysWithFullAccuracy) {
            return nil;
        }
        if (indexPath.row == 1 && CMMotionActivityManager.authorized) {
            return nil;
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self openSettings];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0 && self.locationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
                [self.locationManager requestAlwaysAuthorization];
            } else if (indexPath.row == 1 && CMMotionActivityManager.authorizationStatus == CMAuthorizationStatusNotDetermined) {
                [CMMotionActivityManager requestAuthorization];
            } else {
                [self openSettings];
            }
            break;
        }
        case 1: {
            if (TLKit.isInitialized) {
                [AppDelegate.instance destroyTLKit];
            } else {
                [AppDelegate.instance initTLKit];
            }
            break;
        }
        default:
            break;
    }
}

- (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL __unused success) {}];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    [self.tableView reloadData];
}

@end
