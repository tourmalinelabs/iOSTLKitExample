//
//  CMMotionActivityManager+TLKit.h
//  TLKitExample
//
//  Created by Cédric Malka on 31/05/2023.
//  Copyright © 2023 TL. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMMotionActivityManager (TLKit)
+ (BOOL)authorized;
+ (void)requestAuthorization;
+ (NSString *)formattedAuthorizationStatus;
+ (nullable NSString *)formattedAuthorizationStatusFooter;
@end

NS_ASSUME_NONNULL_END
