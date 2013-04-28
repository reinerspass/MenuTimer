//
//  MTFloating.m
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTTransparentPointingRect.h"
#import "MTDefine.h"

@implementation MTTransparentPointingRect

@synthesize pointerPosition = _pointerPosition;

-(void)setPointerPosition:(MTTransparentPointRectPointerPosition)pointerPosition {
    self->_pointerPosition = pointerPosition;
    [self setNeedsDisplay:YES];
}

-(MTTransparentPointRectPointerPosition)pointerPosition {
    return self->_pointerPosition;
}

-(void)drawRect:(NSRect)dirtyRect {
    float pointerWidth = POINTER_WIDTH;
    float pointerHeight = POINTER_HEIGHT;
    
    NSRect pathRect;
    NSPoint first, second, third;
    pathRect = self.frame;
    
    
    if (self.pointerPosition == MTTransparentPointingRectTop ||
        self.pointerPosition == MTTransparentPointingRectBottom) {
        float tmp = pointerHeight;
        pointerHeight = pointerWidth;
        pointerWidth = tmp;
    }
    
    switch (self.pointerPosition) {
        case MTTransparentPointingRectNone: {
            first = NSMakePoint(0, 0);
            second = NSMakePoint(0, 0);
            third = NSMakePoint(0, 0);
            break;
        }
        case MTTransparentPointingRectTop: {
            pathRect.size.height -= pointerHeight;
            first = NSMakePoint(pathRect.size.width/2, self.frame.size.height);
            second = NSMakePoint(pathRect.size.width/2 + pointerWidth / 2, self.frame.size.height-pointerHeight);
            third = NSMakePoint(pathRect.size.width/2 - pointerWidth / 2, self.frame.size.height-pointerHeight);
            break;
        }
        case MTTransparentPointingRectLeft: {
            pathRect.origin.x += pointerWidth;
            pathRect.size.width -= pointerWidth;
            first = NSMakePoint(0, pathRect.size.height/2);
            second = NSMakePoint(pointerWidth, pathRect.size.height/2 + pointerHeight / 2);
            third = NSMakePoint(pointerWidth, pathRect.size.height/2 - pointerHeight / 2);
            break;
        }
        case MTTransparentPointingRectBottom: {
//            pathRect.origin.x += pointerWidth;
//            pathRect.size.width -= pointerWidth;
//            first = NSMakePoint(0, pathRect.size.height/2);
//            second = NSMakePoint(pointerWidth, pathRect.size.height/2 + pointerHeight / 2);
//            third = NSMakePoint(pointerWidth, pathRect.size.height/2 - pointerHeight / 2);
            break;
        }
        case MTTransparentPointingRectRight: {
            pathRect.origin.x += pointerWidth;
            pathRect.size.width -= pointerWidth;
            first = NSMakePoint(0, pathRect.size.height/2);
            second = NSMakePoint(pointerWidth, pathRect.size.height/2 + pointerHeight / 2);
            third = NSMakePoint(pointerWidth, pathRect.size.height/2 - pointerHeight / 2);
            break;
        }

            
        default:
            break;
    }
    /**
     *  draw rounded rect
     */
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:pathRect xRadius:5 yRadius:5];
    [[NSColor colorWithDeviceWhite:0 alpha:.8] setFill];
    [path fill];
    
    /**
     *  Draw Pointer
     */
    NSBezierPath *pointerPath = [NSBezierPath bezierPath];
    [pointerPath moveToPoint:first];
    [pointerPath lineToPoint:second];
    [pointerPath lineToPoint:third];
    [pointerPath fill];
}

@end
