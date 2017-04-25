//
//  CLLocation+Format.h
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation (Format)
- (NSString *)formattedLatLon;
+ (NSString *)formattedAuthorization;
@end

NS_ASSUME_NONNULL_END
