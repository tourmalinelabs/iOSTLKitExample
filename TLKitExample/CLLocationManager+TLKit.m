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

#import "CLLocationManager+TLKit.h"

@implementation CLLocationManager (TLKit)

- (BOOL)authorizedAlwaysWithFullAccuracy {
    return (self.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways &&
            self.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy);
}

- (NSString *)formattedAuthorizationStatus {
    BOOL fullAccuracy = self.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy;
    switch (self.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return @"Request";
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            NSString *text = @"Always";
            if (fullAccuracy == NO) {
                text = [text stringByAppendingString:@" (Reduced Accuracy)"];
            }
            return text;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            NSString *text = @"Only When In Use";
            if (fullAccuracy == NO) {
                text = [text stringByAppendingString:@" (Reduced Accuracy)"];
            }
            return text;
        }
        case kCLAuthorizationStatusDenied: {
            return @"Never";
        }
        default:
            break;
    }
    return @"?";
}

- (nullable NSString *)formattedAuthorizationStatusFooter {
    if (self.authorizedAlwaysWithFullAccuracy) {
        return nil;
    }
    if (self.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        return @"TLKit needs Location Services to monitor safe driving behavior.";
    }
    return @"Please go to 'Settings/Privacy/Location Services/TLKitExample' and allow 'Always' & 'Precise' location access";
}

@end
