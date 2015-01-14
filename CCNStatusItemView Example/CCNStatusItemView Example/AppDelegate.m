//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItemView.h"
#import "CCNStatusItemWindowAppearance.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *enableDisableCheckbox;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    CCNStatusItemWindowAppearance *style = [CCNStatusItemWindowAppearance defaultAppearance];
    style.backgroundColor = [NSColor colorWithCalibratedRed:0.577 green:0.818 blue:0.130 alpha:1.000];
    style.cornerRadius = 115.0;
    style.presentationTransition = CCNPresentationTransitionSlideAndFade;
    [CCNStatusItemView setWindowAppearance:style];

    [CCNStatusItemView presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                                   alternateImage:[NSImage imageNamed:@"statusbar-alternate-icon"]
                            contentViewController:[[ContentViewController alloc] initWithNibName:NSStringFromClass([ContentViewController class]) bundle:nil]];
}

- (IBAction)enableDisableCheckboxAction:(id)sender {
    [CCNStatusItemView sharedInstance].appearsDisabled = (self.enableDisableCheckbox.state == NSOnState);
}

@end
