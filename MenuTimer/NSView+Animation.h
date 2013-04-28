//
//  NSView+Animation.h
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Animation)
+ (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock;
+ (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock;
+ (void)runEndBlock:(void (^)(void))completionBlock;

@end
