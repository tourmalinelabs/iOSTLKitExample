//
//  NSDate+Format.m
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

+ (NSDateFormatter *)formatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale    = NSLocale.currentLocale;
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    });
    return formatter;
}

- (NSString *)formattedDateTimeWithTimeZone:(NSTimeZone *)timeZone {
    NSDate.formatter.timeZone = timeZone;
    return [NSDate.formatter stringFromDate:self];
}

@end
