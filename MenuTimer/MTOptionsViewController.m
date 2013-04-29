//
//  MTOptionsViewController.m
//  MenuTimer
//
//  Created by Markus Teufel on 28.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTOptionsViewController.h"

#import <DPHue.h>

@interface MTOptionsViewController ()

@end

@implementation MTOptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DPHue *hue = [[DPHue alloc] init];
        
    }
    
    return self;
}

@end
