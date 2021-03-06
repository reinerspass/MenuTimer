//
//  MTDraggingView.m
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTDraggingView.h"

#import "MAAttachedWindow.h"
#import "NSString+MTTime.h"

@implementation MTDraggingView

#pragma mark - View Lifecycle Stuff

-(BOOL)darkModeEnabled {
    if (![[[NSUserDefaults standardUserDefaults]
           stringForKey:@"AppleInterfaceStyle"]
          isEqualToString:@"Light"]) {
        return true;
    } else {
        return false;
    }
}

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
    [[NSColor colorWithDeviceWhite:0 alpha:.2]  setFill];
    
    /**
     *  Angle Drawing Magic
     */
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    float clockAngle = fmod(self.seconds/10, 360);
    if ([self darkModeEnabled]) {
        [[NSColor colorWithDeviceWhite:1.0 alpha:0.5] setFill];
    } else {
        [[NSColor colorWithDeviceWhite:0.0 alpha:0.5] setFill];
    }
    circlePath = [NSBezierPath bezierPath];
    [circlePath moveToPoint:NSMakePoint(11, 11)];
    [circlePath appendBezierPathWithArcWithCenter:NSMakePoint(11, 11) radius:9 startAngle:90 endAngle:90-clockAngle clockwise:YES];
    [circlePath closePath];
    [circlePath fill];
    
    /**
     *  String Drawing Magic
     */
    if (YES) { //self.seconds >= 3600
        int hours = self.seconds / 3600;
        
        [[NSColor colorWithDeviceWhite:1 alpha:.7]  setFill];
        NSRect rect = NSMakeRect(5, 5, 12, 12);
        NSBezierPath* circlePath = [NSBezierPath bezierPath];
        [circlePath appendBezierPathWithOvalInRect: rect];
        [circlePath fill];

        
        CGSize shadowSize = CGSizeMake(0, 0);
        CGContextSetShadowWithColor([[NSGraphicsContext currentContext] graphicsPort], shadowSize, 0,
                                    [NSColor clearColor].CGColor);

        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSCenterTextAlignment];

        NSString *hoursString;
        CGPoint position ;
        NSColor *drawColor;
        if (self.seconds >= 3600) {
            position = NSMakePoint(8.5,5);
            hoursString = [NSString stringWithFormat:@"%d", hours];
            drawColor = [NSColor blackColor];
        } else {
            position = NSMakePoint(7.4,5);
            hoursString = @"M";
            drawColor = [NSColor blackColor];
        }
        
        [hoursString drawAtPoint:position withAttributes:[NSDictionary
                                                                    dictionaryWithObjectsAndKeys:
                                                                    drawColor, NSForegroundColorAttributeName,
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

        [self.attachedWindow orderOut:self];
        self.attachedWindow = nil;

        [self.animationTimer invalidate];
        self.animationTimer = nil;

        [NSEvent removeMonitor:self.mouseUpMonitor];
        
        /**
         *  Alert delegate
         */
        
        if (self.seconds == 0) {
            [self.delegate draggingView:self didReceiveMouseEvent:NSRightMouseDown];
        } else {
            [self.delegate draggingView:self didReceiveSeconds:self.seconds];
        }
        
        return event;
    }];

    
    float attachedWindowWidth = 140;
    
    self.attachedWindowTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 12, attachedWindowWidth, 15)];
    [self.attachedWindowTextField setEditable:NO];
    [self.attachedWindowTextField setSelectable:NO];
    [self.attachedWindowTextField setBackgroundColor:[NSColor clearColor]];
    [self.attachedWindowTextField setTextColor:[NSColor whiteColor]];
    [self.attachedWindowTextField setBordered:NO];
    [self.attachedWindowTextField setAlignment:NSCenterTextAlignment];
    [self.attachedWindowTextField setFont:[NSFont fontWithName:@"Helvetica-Bold" size:14]];
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, attachedWindowWidth, 35)];
    [view addSubview:self.attachedWindowTextField];
    
    
    
    self.attachedWindow = [[MAAttachedWindow alloc] initWithView:view
                                                 attachedToPoint:NSMakePoint(0, 0)
                                                        inWindow:nil
                                                          onSide:MAPositionRight
                                                      atDistance:15.];
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    [self.delegate draggingView:self didReceiveMouseEvent:NSRightMouseDown];
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
//    [self.floatingWindowController upadteWithPosition:p seconds:self.seconds];
    
    self.attachedWindowTextField.stringValue = [NSString timeStringFromSecondsPlusEndingTime:self.seconds];
    self.attachedWindow.point = p;
    
    if (![self.attachedWindow isVisible] && self.seconds >=1) {
        [self.attachedWindow makeKeyAndOrderFront:self];
    }
    
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
