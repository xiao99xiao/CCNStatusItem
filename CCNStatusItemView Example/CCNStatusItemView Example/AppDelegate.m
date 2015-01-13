//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItemView.h"
#import "CCNStatusItemWindowStyle.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *enableDisableCheckbox;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    CCNStatusItemWindowStyle *style = [CCNStatusItemWindowStyle defaultStyle];
//    style.backgroundColor = [NSColor colorWithCalibratedRed:0.780 green:0.807 blue:0.818 alpha:1.000];
//    style.cornerRadius = 13.0;
    style.presentationTransition = CCNPresentationTransitionSlideAndFade;
    [CCNStatusItemView setWindowStyle:style];

    [CCNStatusItemView presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                                   alternateImage:[NSImage imageNamed:@"statusbar-alternate-icon"]
                            contentViewController:[[ContentViewController alloc] initWithNibName:NSStringFromClass([ContentViewController class]) bundle:nil]];
}

- (IBAction)enableDisableCheckboxAction:(id)sender {
    CCNStatusItemView *item = [CCNStatusItemView sharedInstance];
    item.appearsDisabled = self.enableDisableCheckbox.state == NSOnState;
}

@end
