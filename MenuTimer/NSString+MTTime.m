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

+(NSString*)timeStringFromSecondsPlusEndingTime:(double)seconds {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(float)seconds];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm"];
    NSString *hoursString = [df stringFromDate:date];
    
    NSString *formatString = [NSString stringWithFormat:@"%@ / %@", [self timeStringFromSeconds:seconds], hoursString];
    return formatString;
}


@end
