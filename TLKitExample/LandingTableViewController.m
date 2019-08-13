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
#import <CommonCrypto/CommonDigest.h>
#import "LandingTableViewController.h"
#import "DrivesTableViewController.h"
#import "CLLocation+Format.h"
#import <CoreLocation/CoreLocation.h>
#import <TLKit/CKContextKit.h>
#import <TLKit/CKAuthenticationManagerDelegate.h>
#import <TLKit/CKDefaultAuth.h>
#import <TLKit/CKActivityManager.h>
#import <TLKit/CKTelematicsEvent.h>

// API Key usually should be kept on server.
static NSString *const API_KEY  = @"bdf760a8dbf64e35832c47d8d8dffcc0";

// Pre-registered user and password.
static NSString *const USERNAME = @"iosexample@tourmalinelabs.com";

// used to store the last monitoring mode to user defaults
static NSString *const MONITORING_MODE_KEY = @"MONITORING_MODE_KEY";

@interface LandingTableViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *clLocationManager;
@property (assign, nonatomic) CKMonitoringMode mode;
- (NSString *)monitoringModeString;
- (void)startTLKit;
- (void)stopTLKit;
@end

@implementation LandingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *standardUserDefaults = NSUserDefaults.standardUserDefaults;
    [standardUserDefaults registerDefaults:@{ MONITORING_MODE_KEY: @(CKMonitoringModeAutomatic) }];
    [standardUserDefaults synchronize];
    
    self.clLocationManager = CLLocationManager.new;
    self.clLocationManager.delegate = self;

    if (self.mode != CKMonitoringModeUnmonitored) {
        [self startTLKit];
    }
}

- (CKMonitoringMode)mode {
    return [NSUserDefaults.standardUserDefaults integerForKey:MONITORING_MODE_KEY];
}

- (void)setMode:(CKMonitoringMode)mode {
    NSUserDefaults *standardUserDefaults = NSUserDefaults.standardUserDefaults;
    [standardUserDefaults setInteger:mode forKey:MONITORING_MODE_KEY];
    [standardUserDefaults synchronize];
}

- (NSString *)monitoringModeString {
    switch (self.mode) {
        case CKMonitoringModeAutomatic:
            return @"Automatic Monitoring";
        case CKMonitoringModeManual:
            return @"Manual Monitoring";
        case CKMonitoringModeUnmonitored:
            return @"Not monitoring";
        default:
            break;
    }
    return @"?";
}

- (void)stopTLKit { 
    // destroy engine
    __weak __typeof__(self) weakSelf = self;
    [CKContextKit destroyWithResultToQueue:dispatch_get_main_queue()
                               withHandler:^(BOOL __unused successful, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Failed to stop TLKit with error: %@", error);
                                       return;
                                   }
                                   [weakSelf.tableView reloadData];
                               }];
}

- (NSString *)hashedId:(NSString *)uniqueId {
    NSData *strData = [uniqueId dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(strData.bytes,
        (unsigned int)strData.length,
        (unsigned char*)sha.mutableBytes);

    NSMutableString* hexStr = [NSMutableString string];

    [sha enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            [hexStr appendFormat:@"%02x", ((uint8_t*)bytes)[i]];
        }
    }];
    return [hexStr uppercaseString];

}

- (void)startTLKit {
    // check if not already initialized
    if (CKContextKit.isInitialized) {
        NSLog(@"TLKit is already started! (mode: %@)",
            self.monitoringModeString);
        return;
    }

    NSString* hashedId = [self hashedId:USERNAME];
    // initializes engine with automatic drive detection
    __weak __typeof__(self) weakSelf = self;
    [CKContextKit initWithApiKey:API_KEY
                        hashedId:hashedId
                            mode:self.mode
                        launchOptions:nil
                    withResultToQueue:dispatch_get_main_queue()
                          withHandler:^(BOOL __unused successful,
                              NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"Failed to start TLKit: %@", error);
                                  return;
                              }
                              [weakSelf.tableView reloadData];
                          }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) return 1;
    return CKContextKit.isInitialized ? 3 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = CLLocation.formattedAuthorization;
            CLAuthorizationStatus authorizationStatus = CLLocationManager.authorizationStatus;
            if (authorizationStatus == kCLAuthorizationStatusNotDetermined ||
                authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType  = UITableViewCellAccessoryNone;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType  = UITableViewCellAccessoryDetailButton;
            }
            break;
        }
        case 1: {
            BOOL enabled = NO;
            if (CKContextKit.isInitialized) {
                enabled = indexPath.row == 0;
            } else {
                enabled = indexPath.row != 0;
            }
            cell.textLabel.enabled = enabled;
            cell.selectionStyle = enabled ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
            break;
        }
        case 2: {
            break;
        }
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0: return CLLocation.formattedAuthorizationDetail;
        case 1: return [NSString stringWithFormat:@"TLKit state: %@", self.monitoringModeString];
        default:
            break;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            // enable selection when authorization is not always
            if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) return nil;
            break;
        }
        case 1: {
            // avoid selecting stop if not initialized or any start if
            // initialized
            if (CKContextKit.isInitialized) {
                if (indexPath.row != 0) return nil;
            } else {
                if (indexPath.row == 0) return nil;
            }
            break;
        }
        default:
            break;
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
            if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
                [self requestLocationPermissions];
            } else {
                [self openSettings];
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0:
                    self.mode = CKMonitoringModeUnmonitored;
                    [self stopTLKit];
                    break;
                case 1:
                    self.mode = CKMonitoringModeAutomatic;
                    [self startTLKit];
                    break;
                case 2:
                    self.mode = CKMonitoringModeManual;
                    [self startTLKit];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)requestLocationPermissions {
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.clLocationManager requestAlwaysAuthorization];
    }
}

- (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [UIApplication.sharedApplication openURL:url];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:DrivesTableViewController.class]) {
        ((DrivesTableViewController *)segue.destinationViewController).manual = self.mode == CKMonitoringModeManual;
    }
}

@end
