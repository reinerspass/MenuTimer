//
//  MTFloatingWindowController.m
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTFloatingWindowController.h"
#import "NSString+MTTime.h"
#import "MTTransparentPointingRect.h"
#import "MTFloatingWindow.h"
#import "NSView+Animation.h"

@interface MTFloatingWindowController ()

@end

@implementation MTFloatingWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.styleMask = NSBorderlessWindowMask;
    self.window.level = NSScreenSaverWindowLevel;
    [self.window makeKeyAndOrderFront:self];
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
}

-(void)upadteWithPosition:(NSPoint)position seconds:(double)seconds {

    position.y -= self.window.frame.size.height / 2;
    position.x += self.window.frame.size.height / 2;

    [self setWindowOrigin:position];
    
    NSString *formatString = [NSString timeStringFromSeconds:seconds];
    
    self.infoLabel.stringValue = formatString;
}

-(void)setPointerPosition:(MTTransparentPointRectPointerPosition)pointerPosition {
    self->_pointerPosition = pointerPosition;
    MTTransparentPointingRect *pointerView = ((MTFloatingWindow*)self.window).view;
    pointerView.pointerPosition = pointerPosition;
    
    [self setWindowFrame:self.window.frame];
}


-(void)setWindowFrame:(NSRect)frame {
    NSRect windowRect = frame;
    switch (self.pointerPosition) {
        case MTTransparentPointingRectTop: {
            
            windowRect.origin.y -= windowRect.size.height;
            windowRect.origin.x -= (windowRect.size.width / 2) - POINTER_HEIGHT / 2;
            
//            windowRect.origin.x -= 4;            
            break;
        }
            
            
        default: {
//            windowRect.origin.y = 0;//windowRect.size.width / 2 - 1000;
//            windowRect.origin.x = 0;//windowRect.size.width / 2 - 1000;
//            windowRect.size.width = 0;
//            windowRect.size.height = 0;
            break;

        }
    }
    
    [self.window setFrame:windowRect display:YES];
}

-(void)setWindowOrigin:(NSPoint)point {
    [self.window setFrameOrigin:point];
}

-(void)windowShowTime:(double)timeinterval {
    self.fadeAwayTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval // Normal Speed is 1
                                                           target:self
                                                         selector:@selector(timerDidEnd:)
                                                         userInfo:nil
                                                          repeats:NO];
}

-(void)timerDidEnd:(NSTimer*)timer {
    MTFloatingWindow *window = (MTFloatingWindow*)self.window;
    NSView *view = window.view;
    [window orderOut:self];
}

-(void)addCustomView:(NSView*)customView {
    MTFloatingWindow *window = (MTFloatingWindow*)self.window;
    NSView *view = window.view;
    for (NSView *subview in view.subviews) {
        [subview removeFromSuperview];
    }
    
    [view addSubview:customView];
    
    customView.frame = view.frame;
}

@end
