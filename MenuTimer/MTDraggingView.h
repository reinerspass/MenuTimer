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

@end


@interface MTDraggingView : NSView
@property (nonatomic, strong) id mouseUpMonitor;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) id moveMonitor;
@property (nonatomic, strong) MTFloatingWindowController *floatingWindowController;
@property double seconds;

@property (nonatomic, weak) id<MTDraggingViewDelegate> delegate;

@property NSPoint startPoint;

-(void)updateWithSeconds:(double)seconds;


@end
