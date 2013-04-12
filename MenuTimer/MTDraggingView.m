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

#pragma mark - View Lifecycle Stuff

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.seconds = 0;
    }
    return self;
}

-(void)viewDidMoveToSuperview {
    [self setNeedsDisplay:YES];
}


-(void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor blackColor] setStroke];
    [[NSColor colorWithDeviceWhite:0 alpha:.3]  setFill];
    
    /**
     *  Circle Drawing Magic
     */
    NSRect rect = NSMakeRect(2, 2, 18, 18);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect: rect];
    [circlePath fill];
    
    /**
     *  Angle Drawing Magic
     */
    float clockAngle = fmod(self.seconds/10, 360);
    [[NSColor colorWithDeviceWhite:0 alpha:.5]  setFill];
    circlePath = [NSBezierPath bezierPath];
    [circlePath moveToPoint:NSMakePoint(11, 11)];
    [circlePath appendBezierPathWithArcWithCenter:NSMakePoint(11, 11) radius:9 startAngle:90 endAngle:90-clockAngle clockwise:YES];
    [circlePath closePath];
    [circlePath fill];
    
    /**
     *  String Drawing Magic
     */
    if (self.seconds >= 3600) {
        int hours = self.seconds / 3600;
        
        [[NSColor colorWithDeviceWhite:0 alpha:.7]  setFill];
        NSRect rect = NSMakeRect(5, 5, 12, 12);
        NSBezierPath* circlePath = [NSBezierPath bezierPath];
        [circlePath appendBezierPathWithOvalInRect: rect];
        [circlePath fill];
        
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];
        //        NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
        
        NSString *hoursString = [NSString stringWithFormat:@"%d", hours];
        //        [hoursString drawAtPoint:NSMakePoint(8, 4) withAttributes:attr];
        
        [hoursString drawAtPoint:NSMakePoint(8.5,5) withAttributes:[NSDictionary
                                                                    dictionaryWithObjectsAndKeys:
                                                                    [NSColor whiteColor], NSForegroundColorAttributeName,
                                                                    [NSFont fontWithName:@"Helvetica-Bold" size:9], NSFontAttributeName,
                                                                    nil]];
        
    }
    
}

#pragma mark - Mouse Events

-(void)mouseDown:(NSEvent *)theEvent {

    self.startPoint = [self mousePosition];

    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                  target:self
                                                selector:@selector(draggingTimerEvent:)
                                                userInfo:nil
                                                 repeats:YES];



    self.mouseUpMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDragged handler:^(NSEvent *event) {

        self.floatingWindowController = nil;

        [self.animationTimer invalidate];
        self.animationTimer = nil;

        [NSEvent removeMonitor:self.mouseUpMonitor];
        
        /**
         *  Alert delegate
         */
        [self.delegate draggingView:self didReceiveSeconds:self.seconds];
        
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
    [self setNeedsDisplay:YES];
}

#pragma mark - Calculations

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
    return fmin(seconds, 60*60*9);
}

#pragma mark - Public Methods

-(void)updateWithSeconds:(double)seconds {
    self.seconds = seconds;
    [self setNeedsDisplay:YES];
}


@end
