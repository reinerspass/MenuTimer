//
//  NSString+MTTime.m
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "NSString+MTTime.h"

@implementation NSString (MTTime)

+(NSString*)timeStringFromSeconds:(double)seconds {
    int roundedSeconds = seconds / 60 * 60;
    int hours = roundedSeconds / 60 / 60;
    int minutes = (roundedSeconds - (60*60*hours)) / 60;
    NSString *formatString = [NSString stringWithFormat:@"%dh %dm", hours, minutes];
    return formatString;
}

@end
