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

#import "TLLocation+Format.h"
#import "NSDate+Format.h"

@implementation TLLocation (Format)

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
