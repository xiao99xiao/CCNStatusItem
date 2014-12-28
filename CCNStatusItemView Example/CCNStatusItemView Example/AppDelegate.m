//
//  AppDelegate.m
//  CCNStatusItemView Example
//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItemView.h"
#import "CCNStatusItemWindowDesign.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

//    CCNStatusItemWindowDesign *design = [CCNStatusItemWindowDesign defaultDesign];
//    design.statusItemWindowBackgroundColor = [NSColor colorWithCalibratedRed:0.780 green:0.807 blue:0.818 alpha:1.000];
//    design.statusItemWindowCornerRadius = 9.0;
//    [CCNStatusItemView setDesign:design];

    [CCNStatusItemView presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                                   alternateImage:[NSImage imageNamed:@"statusbar-alternate-icon"]
                            contentViewController:[[ContentViewController alloc] initWithNibName:NSStringFromClass([ContentViewController class]) bundle:nil]];

}

@end
