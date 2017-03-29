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

#import "LandingTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <TLKit/CKContextKit.h>
#import <TLKit/CKAuthenticationManagerDelegate.h>
#import <TLKit/CKDefaultAuth.h>

// API Key usually should be kept on server.
static NSString *const API_KEY  = @"bdf760a8dbf64e35832c47d8d8dffcc0";

// Pre-registered user and password.
static NSString *const USERNAME = @"example@tourmalinelabs.com";
static NSString *const PASSWORD = @"password";

@interface LandingTableViewController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *clLocationManager;
@end

@implementation LandingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Is the engine already started ?
    if (!CKContextKit.isInitialized) {
        
        // Initializes the engine with the test account
        [CKContextKit initWithApiKey:API_KEY
                             authMgr:[[CKDefaultAuth alloc] initWithApiKey:API_KEY userId:USERNAME pass:PASSWORD]
                       launchOptions:nil
                   withResultToQueue:dispatch_get_main_queue()
                         withHandler:^(BOOL successful, NSError *error) {
                             if (error) {
                                 NSLog(@"Failed to start TLKit with error: %@", error);
                                 return;
                             }
                         }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        switch (CLLocationManager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined: {
                cell.textLabel.text = @"Request Location Authorization";
                break;
            }
            case kCLAuthorizationStatusAuthorizedAlways: {
                cell.textLabel.text = @"Authorized Always";
                break;
            }
            case kCLAuthorizationStatusDenied: {
                cell.textLabel.text = @"Not Authorized";
                break;
            }
            default:
                break;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                [self requestLocationPermissions];
            }
            break;
        }
        case 1: {
            if (indexPath.row == 0) {
                CKContextKit.isMonitoring = YES;
                [self performSegueWithIdentifier:@"FeaturesSegue" sender:nil];
            } else if (indexPath.row == 1) {
                CKContextKit.isMonitoring = NO;
            }
            break;
        }
        default:
            break;
    }
}

- (void)requestLocationPermissions {
    
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        
        // Request "Always" Location permissions
        self.clLocationManager = CLLocationManager.new;
        self.clLocationManager.delegate = self;

        if ([self.clLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.clLocationManager requestAlwaysAuthorization];
        } else {
            [self.clLocationManager startUpdatingLocation];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self.tableView reloadData];
}

@end
