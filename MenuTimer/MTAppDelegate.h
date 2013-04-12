//
//  MTAppDelegate.h
//  MenuTimer
//
//  Created by Markus Teufel on 4/10/13.
//  Copyright (c) 2013 Markus Teufel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTDraggingView.h"

@interface MTAppDelegate : NSObject <NSApplicationDelegate, MTDraggingViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) MTDraggingView *draggingView;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property double countdown;

- (IBAction)saveAction:(id)sender;

@end
