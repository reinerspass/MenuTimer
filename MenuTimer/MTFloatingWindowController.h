//
//  MTFloatingWindowController.h
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTDefine.h"

@interface MTFloatingWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *infoLabel;
@property (nonatomic) MTTransparentPointRectPointerPosition pointerPosition;
@property (nonatomic, strong) NSTimer *fadeAwayTimer;

-(void)upadteWithPosition:(NSPoint)position seconds:(double)seconds;
-(void)setWindowFrame:(NSRect)frame;
-(void)windowShowTime:(double)timeinterval;
-(void)addCustomView:(NSView*)customView;

@end
