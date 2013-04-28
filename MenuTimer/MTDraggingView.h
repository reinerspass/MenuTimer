//
//  MTDraggingView.h
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MTFloatingWindowController;
@class MTDraggingView;

@protocol MTDraggingViewDelegate <NSObject>

-(void)draggingView:(MTDraggingView*)draggingView didReceiveSeconds:(int)seconds;
-(void)draggingView:(MTDraggingView *)draggingView didReceiveMouseEvent:(NSEventType)mouseEvent;

@end


@interface MTDraggingView : NSView

@property (nonatomic, weak) id<MTDraggingViewDelegate> delegate;

@property (nonatomic, strong) MTFloatingWindowController *floatingWindowController;

@property (nonatomic, strong) id mouseUpMonitor;
@property (nonatomic, strong) id mouseOverMonitor;

@property (nonatomic, strong) NSTimer *animationTimer;
@property double seconds;

@property NSPoint startPoint;

-(void)updateWithSeconds:(double)seconds;


@end
