//
//  NSDate+Format.h
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Format)
- (NSString *)formattedDateTimeWithTimeZone:(nullable NSTimeZone *)timeZone;
@end

NS_ASSUME_NONNULL_END
