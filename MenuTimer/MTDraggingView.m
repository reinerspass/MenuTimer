//
//  MTDraggingView.m
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTDraggingView.h"

#import "MTFloatingWindowController.h"

@implementation MTDraggingView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clockAngle = 0;
    }
    return self;
}

-(void)viewDidMoveToSuperview {
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"register mouse monitors");

    self.startPoint = [self mousePosition];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                  target:self
                                                selector:@selector(draggingTimerEvent:)
                                                userInfo:nil
                                                 repeats:YES];



    self.mouseUpMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDragged handler:^(NSEvent *event) {

        NSLog(@"mouse up");
        self.floatingWindowController = nil;

        [self.timer invalidate];
        self.timer = nil;

        [NSEvent removeMonitor:self.mouseUpMonitor];
        
        /**
         *  Alert delegate
         */
        NSPoint p = [self mousePosition];
        [self.delegate draggingView:self didReceiveSeconds:[self secondsForPosition:p]];
        
        return event;
    }];

    self.floatingWindowController = [[MTFloatingWindowController alloc] initWithWindowNibName:@"MTFloatingWindowController"];
}


/**
 *  Called every .2 seconds while dragging
 */
-(void)draggingTimerEvent:(NSTimer *)timer {
    /**
     *  Update floating Window
     */
    NSPoint p = [self mousePosition];
    self.seconds = [self secondsForPosition:p];
    [self.floatingWindowController upadteWithPosition:p seconds:self.seconds];
    self.clockAngle = fmod(self.seconds/10, 360);
    [self setNeedsDisplay:YES];
}

-(NSPoint)mousePosition {
    CGEventRef ourEvent = CGEventCreate(NULL);
    NSPoint point = CGEventGetLocation(ourEvent);
    [self secondsForPosition:point];
    point.y = [NSScreen mainScreen].frame.size.height - point.y;
    return point;
}

-(double)secondsForPosition:(NSPoint)position {
    double dx   = position.x - self.startPoint.x;   //horizontal difference
    double dy   = position.y - self.startPoint.y;   //vertical difference
    double dist = sqrt( dx*dx + dy*dy );            //distance using Pythagoras theorem
    double seconds = (int)(dist*dist/5000)*60;
    return seconds;
}

-(void)drawRect:(NSRect)dirtyRect {

    [[NSColor blackColor] setStroke];

    [[NSColor colorWithDeviceWhite:0 alpha:.3]  setFill];

    NSRect rect = NSMakeRect(2, 2, 18, 18);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect: rect];
    [circlePath fill];


    [[NSColor colorWithDeviceWhite:0 alpha:.5]  setFill];
    circlePath = [NSBezierPath bezierPath];
    [circlePath moveToPoint:NSMakePoint(11, 11)];
    [circlePath appendBezierPathWithArcWithCenter:NSMakePoint(11, 11) radius:9 startAngle:0 endAngle:self.clockAngle];
    [circlePath closePath];
    [circlePath fill];
    
    if (self.seconds > 3600) {
        int hours = self.seconds / 3600;
        NSLog(@"hours: %d", hours);

        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];

        NSString *hoursString = [NSString stringWithFormat:@"%d", hours];
        [hoursString drawAtPoint:NSMakePoint(8, 4) withAttributes:attr];
    }
    
//    [circlePath stroke];

}


@end
