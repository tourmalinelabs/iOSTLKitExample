//
//  CMMotionActivityManager+TLKit.m
//  TLKitExample
//
//  Created by Cédric Malka on 31/05/2023.
//  Copyright © 2023 TL. All rights reserved.
//

#import "CMMotionActivityManager+TLKit.h"

@implementation CMMotionActivityManager (TLKit)

+ (BOOL)authorized {
    return CMMotionActivityManager.authorizationStatus == CMAuthorizationStatusAuthorized;
}

+ (void)requestAuthorization {
    if (CMMotionActivityManager.isActivityAvailable == NO) return;
    NSDate *now = NSDate.date;
    NSDate *oneMinuteAgo = [now dateByAddingTimeInterval:-60];
    CMMotionActivityManager *manager = CMMotionActivityManager.new;
    [manager queryActivityStartingFromDate:oneMinuteAgo
                                    toDate:now
                                   toQueue:NSOperationQueue.mainQueue
                               withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
    }];
}

+ (NSString *)formattedAuthorizationStatus {
    switch (CMMotionActivityManager.authorizationStatus) {
        case CMAuthorizationStatusNotDetermined : return @"Request";
        case CMAuthorizationStatusRestricted    : return @"Restricted";
        case CMAuthorizationStatusDenied        : return @"Denied";
        case CMAuthorizationStatusAuthorized    : return @"Authorized";
    }
}

+ (nullable NSString *)formattedAuthorizationStatusFooter {
    if (CMMotionActivityManager.isActivityAvailable == NO) return nil;
    if (CMMotionActivityManager.authorized) return nil;
    if (CMMotionActivityManager.authorizationStatus == CMAuthorizationStatusNotDetermined) {
        return @"TLKit needs to access Motion & Fitness data to improve drive detection accuracy.";
    }
    return @"Please go to 'Settings/Privacy/Motion & Fitness' and allow 'TLKitExample' Motion & Fitness access";
}

@end
