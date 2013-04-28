//
//  MTFloatingWindow.h
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTDefine.h"

@class MTTransparentPointingRect;

@interface MTFloatingWindow : NSWindow
@property (weak) IBOutlet MTTransparentPointingRect *view;

@end
