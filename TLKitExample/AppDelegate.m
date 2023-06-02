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

#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <TLKit/TLLaunchOptions.h>

NSString *const TLKitStatusDidChangeNotification = @"TLKitStatusDidChangeNotification";

// API Key usually should be kept on server.
static NSString *const API_KEY = @"bdf760a8dbf64e35832c47d8d8dffcc0";

// Pre-registered user.
static NSString *const USERNAME = @"iosexample@tourmalinelabs.com";

// used to store if TLKit was started to user defaults
static NSString *const SHOULD_RESTART_TLKIT_AT_LAUNCH_KEY = @"SHOULD_RESTART_TLKIT_AT_LAUNCH_KEY";

@interface AppDelegate ()
@property (assign, nonatomic) BOOL shouldRestartTLKitAtLaunch;
@property (strong, nonatomic) NSDictionary *launchOptions;
@end

@implementation AppDelegate

+ (AppDelegate *)instance {
    return (AppDelegate *)UIApplication.sharedApplication.delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.authStatus = @"NOT AUTHENTICATED";
    self.launchOptions = launchOptions;
    if (self.shouldRestartTLKitAtLaunch) {
        [self initTLKit];
    }
    return YES;
}

#pragma mark -

- (NSString *)hashedId:(NSString *)uniqueId {
    NSData *strData = [uniqueId dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(strData.bytes,
              (unsigned int)strData.length,
              (unsigned char *)sha.mutableBytes);

    NSMutableString *hexStr = NSMutableString.string;
    [sha enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            [hexStr appendFormat:@"%02x", ((uint8_t *)bytes)[i]];
        }
    }];
    return hexStr.uppercaseString;
}

- (BOOL)shouldRestartTLKitAtLaunch {
    return [NSUserDefaults.standardUserDefaults boolForKey:SHOULD_RESTART_TLKIT_AT_LAUNCH_KEY];
}

- (void)setShouldRestartTLKitAtLaunch:(BOOL)isTLKitStarted {
    NSUserDefaults *standardUserDefaults = NSUserDefaults.standardUserDefaults;
    [standardUserDefaults setBool:isTLKitStarted forKey:SHOULD_RESTART_TLKIT_AT_LAUNCH_KEY];
    [standardUserDefaults synchronize];
}

- (void)initTLKit {
    // check if not already initialized
    if (TLKit.isInitialized) {
        NSLog(@"TLKit is already started! (mode: %@)", TLKit.modeStr);
        return;
    }

    // authentication status handler
    __weak __typeof__(self) weakSelf = self;
    TLAuthenticationStatusHandler authHandler = ^(TLAuthenticationStatus status, NSError *_Nullable error) {
        if (!weakSelf) return;
        switch (status) {
            case TLAuthenticationStatusNone:
                weakSelf.authStatus = @"NOT AUTHENTICATED";
                break;
            case TLAuthenticationStatusAuthenticated:
                weakSelf.authStatus = @"AUTHENTICATED";
                break;
            case TLAuthenticationStatusPasswordExpired:
                weakSelf.authStatus = @"PASSWORD EXPIRED";
                break;
            case TLAuthenticationStatusPasswordInvalid:
                weakSelf.authStatus = @"PASSWORD INVALID";
                break;
            case TLAuthenticationStatusUnActivated:
                weakSelf.authStatus = @"USER UNACTIVATED";
                break;
            case TLAuthenticationStatusUserDisabled:
                weakSelf.authStatus = @"USER DISABLED";
                break;
            default:
                weakSelf.authStatus = @"UNKNOWN ERROR";
                break;
        }
        if (error) {
            NSLog(@"Failed to authenticate TLKit with status: %@(%lu) error: %@",
                  weakSelf.authStatus, (unsigned long)status, error);
        }
        [NSNotificationCenter.defaultCenter
         postNotificationName:TLKitStatusDidChangeNotification object:nil];
    };

    NSMutableDictionary *launchOptions = NSMutableDictionary.dictionary;
    if (self.launchOptions) { // from application:didFinishLaunchingWithOptions
        launchOptions[TLAppDelegateLaunchOptionsKey] = self.launchOptions;
    }

    TLLaunchOptions *options = TLLaunchOptions.new;
    options.firstname = @"Bob";
    options.lastname = @"Smith";
    //options.externalId = @"my-company-identifier-xyz";
    //[options addGroupExternalIds:@[@"team_blue", @"team_green"] toOrgId:123];
    launchOptions[TLLaunchOptionsKey] = options;

    // TLKit initialization
    [TLKit initWithApiKey:API_KEY
                     area:TLCloudAreaUS
                 hashedId:[TLDigest sha256:USERNAME]
              authHandler:authHandler
                     mode:TLMonitoringModeAutomatic
            launchOptions:launchOptions.copy
        withResultToQueue:nil // defaults to main queue
              withHandler:^(BOOL successful, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to start TLKit: %@", error);
            // handle error...
            return;
        }
        weakSelf.shouldRestartTLKitAtLaunch = YES;
        [NSNotificationCenter.defaultCenter
         postNotificationName:TLKitStatusDidChangeNotification object:nil];
    }];
}

- (void)destroyTLKit {
    __weak __typeof__(self) weakSelf = self;
    [TLKit destroyWithResultToQueue:dispatch_get_main_queue()
                        withHandler:^(BOOL successful, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to stop TLKit with error: %@", error);
            // handle error...
            return;
        }
        weakSelf.shouldRestartTLKitAtLaunch = NO;
        weakSelf.authStatus = @"NOT AUTHENTICATED";
        [NSNotificationCenter.defaultCenter
         postNotificationName:TLKitStatusDidChangeNotification object:nil];
    }];
}

@end
