 //
//  MTAppDelegate.m
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import "MTAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+MTTime.h"
#import <DPHue/DPHue.h>
#import <DPHue/DPHueLight.h>
#import "MTDefine.h"


#import "MTOptionsWindowController.h"
#import "MAAttachedWindow.h"

@implementation MTAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setTitle:@"test"];
    self.draggingView = [[MTDraggingView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    self.draggingView.delegate = self;
    self.statusItem.view = self.draggingView;
    self.timeLeftMenuItem.title = @"No Timer Set";
    
    
    self.hue = [[DPHue alloc] initWithHueHost:HUE_HOST username:HUE_USER_NAME];
    [self.hue readWithCompletion:^(DPHue *hue, NSError *err) {
        if (err != nil) {
            NSLog(@"error: %@", err.description);
        } else {
            NSLog(@"hue success!!!");
        }
    }];
    
    
    [self fileNotifications];
    [self checkFirstLaunch];
}


- (void) receiveSleepNote: (NSNotification*) note
{
//    NSLog(@"receiveSleepNote: %@", [note name]);
 
    if (self.countdown > 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDate *alertDate = [NSDate dateWithTimeIntervalSinceNow: self.countdown];
        
        [defaults setValue:alertDate forKey:DEFAULTS_ALERT_DATE];
        [defaults synchronize];
    }
    
}

- (void) receiveWakeNote: (NSNotification*) note
{
//    NSLog(@"receiveSleepNote: %@", [note name]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *alertDate = [defaults valueForKey:DEFAULTS_ALERT_DATE];
    
    if (alertDate != nil) {
        double timerInterval = [alertDate timeIntervalSinceNow];
        
//        NSLog(@"timerInterval %f", timerInterval);
        
        self.countdown = timerInterval;
        
        if (timerInterval <= 0) {
            [self timerDidUpdate:nil];
        }
    }
}



- (void) fileNotifications
{
    //These notifications are filed on NSWorkspace's notification center, not the default
    // notification center. You will not receive sleep/wake notifications if you file
    //with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}


-(void)blinkHue:(int)times {
    DPHueLight *light = self.hue.lights.lastObject;
    // Lamp hue, in degrees*182, valid valuse are 0 - 65535.
    
    NSNumber *blinkColor = [NSNumber numberWithFloat:360*182];
    light.transitionTime = @0;
    
    int __block counter = times;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        light.hue = blinkColor;
        light.saturation = @255;
        light.brightness = @255;
        light.on = YES;
        [light write];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            light.on = NO;
            [light write];
            if (counter > 0) {
                [self blinkHue:counter-1];
            }
        });
        
    });
}


-(void)checkFirstLaunch {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL notFirstLaunch = [defaults boolForKey:DEFAULTS_NOT_FIRST_LAUNCH];

    if (!notFirstLaunch) {
        [defaults setBool:YES forKey:DEFAULTS_NOT_FIRST_LAUNCH];
        [defaults synchronize];
        
        
        NSRect frameRelativeToWindow = [self.draggingView
                                        convertRect:self.draggingView.bounds toView:nil
                                        ];
        
        NSPoint pointRelativeToScreen = [self.draggingView.window
                                         convertRectToScreen:frameRelativeToWindow
                                         ].origin;
        
        pointRelativeToScreen.x += 11;
        
        
        self.attachedWindow = [[MAAttachedWindow alloc] initWithView:self.introView
                                                attachedToPoint:pointRelativeToScreen
                                                       inWindow:nil
                                                         onSide:MAPositionBottom
                                                     atDistance:5.0];
        [self.attachedWindow makeKeyAndOrderFront:self];

    }
}

-(void)draggingView:(MTDraggingView *)draggingView didReceiveSeconds:(int)seconds {
    if (self.attachedWindow != nil) {
        [self.attachedWindow orderOut:self];
        self.attachedWindow = nil;
    }

    [self configureTimerWithSeconds:seconds];
}

-(void)draggingView:(MTDraggingView *)draggingView didReceiveMouseEvent:(NSEventType)mouseEvent {
    if (self.attachedWindow != nil) {
        [self.attachedWindow orderOut:self];
        self.attachedWindow = nil;
    }

    [self.statusItem popUpStatusItemMenu:self.statusBarContextMenu];
}


-(void)configureTimerWithSeconds:(int)seconds {
    self.countdown = seconds;
    
    if (self.countdownTimer != nil) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1. // Normal Speed is 1
                                                           target:self
                                                         selector:@selector(timerDidUpdate:)
                                                         userInfo:nil
                                                          repeats:YES];
    
    [self updateTimeLeftMenuItemText];
}

-(void)timerDidUpdate:(NSTimer*)timer {
    [self timerDidUpdate:timer withAlarm:YES];
}

-(void)timerDidUpdate:(NSTimer*)timer withAlarm:(BOOL)alarm {
    self.countdown -= 1;
    
    NSLog(@"countdown %f", self.countdown);

    if (self.countdown <= 0) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;


        if (alarm) {
            self.notification = nil;
            self.countdown = 0;
            self.notification = [[NSUserNotification alloc] init];
            self.notification.title = @"Menu Timer Done!";
            self.notification.informativeText = @"Tick Tack!";
            self.notification.soundName = @"InstaSound.aif";
            self.notification.hasActionButton = YES;
            self.notification.actionButtonTitle = @"Gimme 5";
            self.notification.otherButtonTitle = @"Done";
            
            [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:self.notification];
            
            [self blinkHue:3];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:nil forKey:DEFAULTS_ALERT_DATE];
        [defaults synchronize];
    }
    
    [self updateTimeLeftMenuItemText];
    
    [self.draggingView updateWithSeconds:self.countdown];
    
}

-(void)updateTimeLeftMenuItemText {
    NSString *formatString = [NSString timeStringFromSeconds:self.countdown];

    self.timeLeftMenuItem.title = formatString;

}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
//    NSLog(@"activate!!!! = action?");
    
    switch (notification.activationType) {
        case NSUserNotificationActivationTypeNone:
//            NSLog(@"no activation");
            break;
        case NSUserNotificationActivationTypeContentsClicked:
//            NSLog(@"clicked activation");
            break;
        case NSUserNotificationActivationTypeActionButtonClicked:
            [self configureTimerWithSeconds:5*60]; // Snooze
            break;
            
        default:
            break;
    }
}

//-(void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
//    
//}
//
//-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
//    return YES;
//}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "de.markusteufel.MenuTimer" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"de.markusteufel.MenuTimer"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MenuTimer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
//        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"MenuTimer.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
//        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (IBAction)cancelTimerAction:(id)sender {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    [self timerDidUpdate:nil];
    self.countdown = 0;
    [self timerDidUpdate:sender withAlarm:NO];
}

- (IBAction)aboutMenuTimerMenuAction:(id)sender {
//    https://github.com/reinerspass/FullscreenWriter
    [[NSWorkspace sharedWorkspace] openURL:[ NSURL URLWithString:@"https://github.com/reinerspass/MenuTimer"]];

    
//    NSLog(@"about menu item action");
}


- (IBAction)quitMenuTimerMenuAction:(id)sender {
//    NSLog(@"quit menu item action");
    
    exit(0);
}

- (IBAction)resetSettingsMenuAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:DEFAULTS_NOT_FIRST_LAUNCH];
    [defaults synchronize];
}

- (IBAction)optionsMenuAction:(id)sender {
    self.optionsWindowController = [[MTOptionsWindowController alloc] initWithWindowNibName:@"MTOptionsWindowController"];
    [self.optionsWindowController.window makeKeyAndOrderFront:self];
}
@end
