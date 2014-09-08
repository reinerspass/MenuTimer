//
//  NSString+MTTime.h
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MTTime)

+(NSString*)timeStringFromSeconds:(double)seconds;
+(NSString*)timeStringFromSecondsPlusEndingTime:(double)seconds;
@end
