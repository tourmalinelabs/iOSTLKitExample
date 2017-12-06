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

#import "CKTelematicsEvent+Format.h"
#import "NSDate+Format.h"

@implementation CKTelematicsEvent (Format)

- (NSString *)formattedTripID {
    return [NSString stringWithFormat:@"Trip ID: %@",
            self.tripId.UUIDString];
}

- (NSString *)formattedType {
    return [NSString stringWithFormat:@"Type: %@",
            self.typeStr];
}

- (NSString *)formattedTime {
    return [NSString stringWithFormat:@"Time: %@",
            [self.time formattedDateTimeWithTimeZone:self.timeZone]];
}

- (NSString *)formattedDuration {
    return [NSString stringWithFormat:@"Duration (seconds): %f",
            self.duration];
}

- (NSString *)formattedCoordinate {
    return [NSString stringWithFormat:@"Coordinate: %f, %f",
            self.latitude,
            self.longitude];
}

- (NSString *)formattedSpeed {
    return [NSString stringWithFormat:@"Speed: %f",
            self.speed];
}

- (NSString *)formattedSeverity {
    return [NSString stringWithFormat:@"Severity: %f",
            self.severity];
}

@end
