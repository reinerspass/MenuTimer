//
//  MTFloatingWindowController.m
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTFloatingWindowController.h"
#import "NSString+MTTime.h"

@interface MTFloatingWindowController ()

@end

@implementation MTFloatingWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.styleMask = NSBorderlessWindowMask;
    self.window.level = NSScreenSaverWindowLevel;
    [self.window makeKeyAndOrderFront:self];
    self.window.alphaValue = .5;
}

-(void)upadteWithPosition:(NSPoint)position seconds:(double)seconds {

    position.y -= self.window.frame.size.height / 2;
    position.x += self.window.frame.size.height / 2;

    [self.window setFrameOrigin:position];
    
    NSString *formatString = [NSString timeStringFromSeconds:seconds];
    
    self.infoLabel.stringValue = formatString;
}

@end
