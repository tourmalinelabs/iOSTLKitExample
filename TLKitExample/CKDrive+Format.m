//
//  CKDrive+Format.m
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import "CKDrive+Format.h"
#import "NSDate+Format.h"
#import "CLLocation+Format.h"

@implementation CKDrive (Format)

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
            location ? location.formattedLatLon : @"-"];
}

- (NSString *)formattedEndLocation {
    CLLocation *location = self.locations.lastObject;
    return [NSString stringWithFormat:@"End location: %@",
            location ? location.formattedLatLon : @"-"];
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
