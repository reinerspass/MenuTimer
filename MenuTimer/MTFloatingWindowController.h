//
//  MTFloatingWindowController.h
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MTFloatingWindowController : NSWindowController
@property (weak) IBOutlet NSTextField *infoLabel;


-(void)upadteWithPosition:(NSPoint)position seconds:(double)seconds;
@end
