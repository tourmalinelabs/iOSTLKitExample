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

// Pre-registered user and password.
static NSString *const USERNAME = @"example@tourmalinelabs.com";
static NSString *const PASSWORD = @"password";

// API Key usually should be kept on server.
static NSString *const API_KEY  = @"bdf760a8dbf64e35832c47d8d8dffcc0";

@interface LandingTableViewController () <CLLocationManagerDelegate, CKAuthenticationManagerDelegate>
@property (nonatomic) CLLocationManager *clLocationManager;
@end

@implementation LandingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![CKContextKit isInitialized]) {

        [CKContextKit initWithApiKey:@"bdf760a8dbf64e35832c47d8d8dffcc0"
                             authMgr:[[CKDefaultAuth alloc]
                                 initWithApiKey:API_KEY
                                         userId:USERNAME
                                           pass:PASSWORD]
                       launchOptions:nil
                   withResultToQueue:dispatch_get_main_queue()
                         withHandler:^(BOOL successful, NSError *error) {
                             if (error) {
                                 NSLog(@"Failed to start TLKit with error: %@",
                                     error);
                                 return;
                             }
                         }];
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        return 1;
    }
    return 2;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                [self requestLocationPermissions];
            }
            break;
        case 1:
            if (indexPath.row == 0) {
                CKContextKit.isMonitoring = YES;
                [self performSegueWithIdentifier:@"FeaturesSegue" sender:nil];
            } else if (indexPath.row == 1) {
                CKContextKit.isMonitoring = NO;
            }
            break;
        default:
            break;
    }
}

- (void)requestLocationPermissions {
    // Request "Always" Location permissions
    self.clLocationManager = [CLLocationManager new];
    self.clLocationManager.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
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

// Note: here we call the BW server directly and authenticate against it.
// in production code this would call the application server which would in
// turn authenticate against the BW server.
- (void)getToken:(AuthenticationHandler)handler {

    NSURL* url = [ NSURL URLWithString:@"https://bw.api.tl/v1/identity-login" ];


    NSURLSession *session =
            [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    NSMutableURLRequest *request =
            [[NSMutableURLRequest alloc] initWithURL: url];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:API_KEY forHTTPHeaderField:@"api-key"];
    request.HTTPMethod = @"POST";
    request.HTTPBody =
            [NSJSONSerialization
                    dataWithJSONObject:@{ @"username" : USERNAME,
                                          @"password" : PASSWORD }
                               options:0
                                 error:nil];

    NSURLSessionDataTask *dataTask =
            [session dataTaskWithRequest:request
                       completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                           NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
                           NSLog(@"Got repsonse: %lu", rsp.statusCode);
                           if( rsp.statusCode != 200 ) {
                               handler(@"",@"");
                               return;
                           }
                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:0
                                                                                  error:nil];
                           NSString* authToken = json[@"accessToken"];
                           if( authToken ) {
                               NSLog(@"Got auth token %@", authToken);
                               handler( USERNAME, authToken );
                           } else {
                               handler(@"", @"");
                           }
                           return;
                       }];
    [dataTask resume];
}

#pragma mark - CKAuthenticationManagerDelegate
- (void)retrieveToken:(AuthenticationHandler)handler {
    // Note: an optimization here would be to cache a previously retrieved token
    // and return it first instead of getting a new token every time.
    // If the cached token is invalid onInvalidToken would be called and a new
    // token could be retrieved.

    [self getToken:handler];
}

- (void)onInvalidToken:(int)errCode newTokenCb:(AuthenticationHandler)handler {
    [self getToken:handler];
}

- (NSString *)userId {
    return USERNAME;
}


@end
