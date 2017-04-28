//
//  CKLocation+Format.h
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import <TLKit/CKLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKLocation (Format)
- (NSString *)formattedLocation;
- (NSString *)formattedTime;
- (NSString *)formattedAddress;
- (NSString *)formattedState;
@end

NS_ASSUME_NONNULL_END
