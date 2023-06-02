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

#import "TLTrip+Format.h"
#import "NSDate+Format.h"
#import "CLLocation+Format.h"

@implementation TLTrip (Format)

- (NSString *)formattedID {
    return [NSString stringWithFormat:@"ID: %@",
            self.id.UUIDString];
}

- (NSString *)formattedType {
    return [NSString stringWithFormat:@"Type: %@",
            self.typeStr];
}

- (NSString *)formattedState {
    return [NSString stringWithFormat:@"State: %@",
            self.stateStr];
}

- (NSString *)formattedAnalysisState {
    return [NSString stringWithFormat:@"Analysis state: %@",
            self.analysisStateStr];
}

- (NSString *)formattedDistance {
    return [NSString stringWithFormat:@"Distance: %f meters",
            self.distance];
}

- (NSString *)formattedStartTime {
    return [NSString stringWithFormat:@"Start time: %@",
            [self.startTime formattedDateTimeWithTimeZone:self.startTimeZone]];
}

- (NSString *)formattedEndTime {
    return [NSString stringWithFormat:@"End time: %@",
            [self.endTime formattedDateTimeWithTimeZone:self.endTimeZone]];
}

- (NSString *)formattedStartLocation {
    CLLocation *location = self.locations.firstObject;
    return [NSString stringWithFormat:@"Start location: %@",
            location ? location.formattedLatLng : @"-"];
}

- (NSString *)formattedEndLocation {
    CLLocation *location = self.locations.lastObject;
    return [NSString stringWithFormat:@"End location: %@",
            location ? location.formattedLatLng : @"-"];
}

- (NSString *)formattedStartAddress {
    return [NSString stringWithFormat:@"Start address: %@",
            self.startAddress.length ? self.startAddress : @"-"];
}

- (NSString *)formattedEndAddress {
    return [NSString stringWithFormat:@"End address: %@",
            self.endAddress.length ? self.endAddress : @"-"];
}

@end
