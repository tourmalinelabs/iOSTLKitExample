//
//  CKDrive+Format.h
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import <TLKit/CKDrive.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKDrive (Format)
- (NSString *)formattedID;
- (NSString *)formattedType;
- (NSString *)formattedState;
- (NSString *)formattedAnalysisState;
- (NSString *)formattedDistance;
- (NSString *)formattedStartTime;
- (NSString *)formattedEndTime;
- (NSString *)formattedStartLocation;
- (NSString *)formattedEndLocation;
- (NSString *)formattedStartAddress;
- (NSString *)formattedEndAddress;
@end

NS_ASSUME_NONNULL_END
