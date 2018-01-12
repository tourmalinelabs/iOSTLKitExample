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

// API Key usually should be kept on server.
static NSString *const API_KEY  = @"bdf760a8dbf64e35832c47d8d8dffcc0";

// Pre-registered user and password.
static NSString *const USERNAME = @"iosexample@tourmalinelabs.com";

// used to store the last monitoring state to user defaults
static NSString *const MONITORING_STATE_KEY = @"MONITORING_STATE_KEY";

#pragma mark - MonitoringState enumeration values
typedef NS_ENUM(NSUInteger, MonitoringState) {
    MonitoringStateStop,
    MonitoringStateAuto,
    MonitoringStateManual,
    __MonitoringStateCount__, // Don't touch me!
};

@interface LandingTableViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *clLocationManager;
@property (assign, nonatomic) MonitoringState monitoringState;
- (NSString *)monitoringStateString;
- (void)stopMonitoring;
- (void)startMonitoring:(MonitoringState)monitoringState;
@end

@implementation LandingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clLocationManager = CLLocationManager.new;
    self.clLocationManager.delegate = self;
    
    switch (self.monitoringState) {
        case MonitoringStateStop:
            break;
        case MonitoringStateAuto:
            [self startMonitoring: MonitoringStateAuto];
            break;
        case MonitoringStateManual:
            [self startMonitoring:MonitoringStateManual];
            break;
        default:
            break;
    }
}

- (MonitoringState)monitoringState {
    return [NSUserDefaults.standardUserDefaults integerForKey:MONITORING_STATE_KEY];
}

- (void)setMonitoringState:(MonitoringState)monitoringState {
    NSUserDefaults *standardUserDefaults = NSUserDefaults.standardUserDefaults;
    [standardUserDefaults setInteger:monitoringState forKey:MONITORING_STATE_KEY];
    [standardUserDefaults synchronize];
}

- (NSString *)monitoringStateString {
    switch (self.monitoringState) {
        case MonitoringStateStop:
            return @"Not monitoring";
        case MonitoringStateAuto:
            return @"Automatic Monitoring";
        case MonitoringStateManual:
            return @"Manual Monitoring";
        default:
            break;
    }
    return @"?";
}

- (void)stopMonitoring {
    // destroy engine
    __weak __typeof__(self) weakSelf = self;
    [CKContextKit destroyWithResultToQueue:dispatch_get_main_queue()
                               withHandler:^(BOOL __unused successful, NSError * _Nullable error) {
                                   if (error) {
                                       NSLog(@"Failed to stop TLKit with error: %@", error);
                                       return;
                                   }
                                   weakSelf.monitoringState = MonitoringStateStop;
                                   [weakSelf.tableView reloadData];
                               }];
}

-(NSString*)hashedId:(NSString*)uniqueId {
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

- (void)startMonitoring:(MonitoringState)monitoringState {
    // check if not already initialized
    if (CKContextKit.isInitialized) {
        NSLog(@"TLKit is already started! (mode: %@)",
            self.monitoringStateString);
        return;
    }

    NSString* hashedId = [self hashedId:USERNAME];
    // initializes engine with automatic drive detection
    __weak __typeof__(self) weakSelf = self;
    [CKContextKit initWithApiKey:API_KEY
                        hashedId:hashedId
                       automatic:monitoringState == MonitoringStateAuto
                        launchOptions:nil
                    withResultToQueue:dispatch_get_main_queue()
                          withHandler:^(BOOL __unused successful,
                              NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"Failed to start TLKit: %@", error);
                                  return;
                              }
                              weakSelf.monitoringState = monitoringState;
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
                enabled = indexPath.row == MonitoringStateStop;
            } else {
                enabled = indexPath.row != MonitoringStateStop;
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
        case 1: return [NSString stringWithFormat:@"TLKit state: %@", self.monitoringStateString];
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
                if (indexPath.row != MonitoringStateStop) return nil;
            } else {
                if (indexPath.row == MonitoringStateStop) return nil;
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
                case MonitoringStateStop:
                    [self stopMonitoring];
                    break;
                case MonitoringStateAuto:
                    [self startMonitoring:MonitoringStateAuto];
                    break;
                case MonitoringStateManual:
                    [self startMonitoring:MonitoringStateManual];
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
        ((DrivesTableViewController *)segue.destinationViewController).manual = self.monitoringState == MonitoringStateManual;
    }
}

@end
