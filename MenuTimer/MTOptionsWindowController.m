//
//  MTOptionsWindowController.m
//  MenuTimer
//
//  Created by Markus Teufel on 30.04.13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTOptionsWindowController.h"
#import <DPHue/DPHue.h>
#import <DPHue/DPHueDiscover.h>

#import "MTDefine.h"

@interface MTOptionsWindowController ()

@end

@implementation MTOptionsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (void)foundHueAt:(NSString *)host discoveryLog:(NSString *)log {
    NSLog(@"*** DELEGATE FOUNDDDD!!!: %@ %@", host, log);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *newUsername;
    
    [defaults setValue:host forKey:PREF_KEY_HUE_HOST];
    [defaults synchronize];
    
    if ([defaults valueForKey:PREF_KEY_HUE_USERNAME] == nil || YES) {
        newUsername = [DPHue generateUsername];
        [defaults setValue:newUsername forKey:PREF_KEY_HUE_USERNAME];

    } else {
        newUsername = [defaults valueForKey:PREF_KEY_HUE_USERNAME];
    }
    
    [self test];
}


-(void)test {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *newUsername = [defaults valueForKey:PREF_KEY_HUE_USERNAME];
    NSString *host = [defaults valueForKey:PREF_KEY_HUE_HOST];
    
    DPHue *hue = [[DPHue alloc] initWithHueHost:host username:newUsername];
    
    
    int authenticatedTimes = 0;
    
    while (!hue.authenticated) {
        
        if (authenticatedTimes >= 30) {
            break;
        }
        
        authenticatedTimes++;
        [hue registerUsername];
        
        [NSThread sleepForTimeInterval:1];
        NSLog(@"*** press button (%d/30)", authenticatedTimes);
    }
    
    if (hue.authenticated) {
        NSLog(@"SUCESS REGISTERING HUE!!!!!");
        
        [hue readWithCompletion:^(DPHue *hue, NSError *err) {
            if (err != nil) {
                NSLog(@"*** error: %@", err.description);
            } else {
                
                
                [hue allLightsOn];

                
            }
        }];

        
        
    } else {
        NSLog(@"TIME OUT REGISTERING HUE :(");
    }

    

}

- (IBAction)discoverHueButtonAction:(id)sender {
    self.dhd = [[DPHueDiscover alloc] initWithDelegate:self];
    [self.dhd discoverForDuration:30 withCompletion:^(NSMutableString *log) {
            NSLog(@"in block found blah %@", log);
    }];
}

@end
