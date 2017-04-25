//
//  CKLocation+Format.m
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import "CKLocation+Format.h"
#import "NSDate+Format.h"

@implementation CKLocation (Format)

- (NSString *)formattedLocation {
    return [NSString stringWithFormat:@"Location: %f, %f",
            self.coordinate.latitude,
            self.coordinate.longitude];
}

- (NSString *)formattedTime {
    return [NSString stringWithFormat:@"Start time: %@",
            [self.timestamp formattedDateTimeWithTimeZone:self.timezone]];
}

- (NSString *)formattedAddress {
    return [NSString stringWithFormat:@"Address: %@",
            self.address.length ? self.address : @"-"];
}

- (NSString *)formattedState {
    return [NSString stringWithFormat:@"State: %@",
            self.activityStateStr];
}

@end
