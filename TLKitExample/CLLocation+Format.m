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

#import "CLLocation+Format.h"

@implementation CLLocation (Format)

- (NSString *)formattedLatLon {
    return [NSString stringWithFormat:@"%f, %f",
            self.coordinate.latitude,
            self.coordinate.longitude];
}

+ (NSString *)formattedAuthorization {
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            return @"Request Location Authorization";
        case kCLAuthorizationStatusAuthorizedAlways:
            return @"Authorized Always";
        case kCLAuthorizationStatusDenied:
            return @"Not Authorized";
        default:
            break;
    }
    return @"?";
}

@end
