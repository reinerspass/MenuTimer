//
//  MTFloatingWindow.m
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTFloatingWindow.h"
#import "MTTransparentPointingRect.h"

@implementation MTFloatingWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)windowStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation
{
    self = [super
            initWithContentRect:contentRect
            styleMask:NSBorderlessWindowMask
            backing:bufferingType
            defer:deferCreation];
    if (self)
    {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
    }
    return self;
}

-(void)setFrame:(NSRect)frameRect display:(BOOL)flag {
    [super setFrame:frameRect display:flag];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [self orderOut:self];
}

@end
