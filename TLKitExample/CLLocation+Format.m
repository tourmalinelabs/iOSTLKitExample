//
//  CLLocation+Format.m
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

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
