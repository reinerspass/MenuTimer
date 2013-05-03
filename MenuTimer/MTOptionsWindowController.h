//
//  MTOptionsWindowController.h
//  MenuTimer
//
//  Created by Markus Teufel on 30.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <DPHue/DPHueDiscover.h>

@interface MTOptionsWindowController : NSWindowController <DPHueDiscoverDelegate>


@property (nonatomic, strong) DPHueDiscover* dhd;



@end
