//
//  MTFloatingWindowController.m
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTFloatingWindowController.h"

@interface MTFloatingWindowController ()

@end

@implementation MTFloatingWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.styleMask = NSBorderlessWindowMask;
    self.window.level = NSScreenSaverWindowLevel;
    [self.window makeKeyAndOrderFront:self];
}

-(void)upadteWithPosition:(NSPoint)position seconds:(double)seconds {

    position.y -= self.window.frame.size.height / 2;
    position.x += self.window.frame.size.height / 2;

    [self.window setFrameOrigin:position];
    
    int roundedSeconds = seconds / 60 * 60;
    
//    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)roundedSeconds];
//    NSDateFormatter *timeFormat = self.infoLabel.formatter;
//    timeFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//    self.infoLabel.stringValue = [self.infoLabel.formatter stringFromDate:date];
    
    int hours = roundedSeconds / 60 / 60;
    int minutes = (roundedSeconds - (60*60*hours)) / 60;
    NSString *formatString = [NSString stringWithFormat:@"%dh %dm", hours, minutes];
    self.infoLabel.stringValue = formatString;
//    NSLog(@"seconds: %d / %@ / %@", roundedSeconds, [date description], [self.infoLabel.formatter stringFromDate:date]);

}

@end
