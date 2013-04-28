//
//  MTAppDelegate.h
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTDraggingView.h"

@interface MTAppDelegate : NSObject <NSApplicationDelegate, MTDraggingViewDelegate, NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusBarContextMenu;
@property (weak) IBOutlet NSMenuItem *timeLeftMenuItem;

@property (nonatomic, strong) MTDraggingView *draggingView;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property double countdown;
@property (nonatomic, strong) NSUserNotification *notification;




- (IBAction)saveAction:(id)sender;

@end
