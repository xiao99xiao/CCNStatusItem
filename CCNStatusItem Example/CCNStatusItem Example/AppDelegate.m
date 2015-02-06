//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowAppearance.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *enableDisableCheckbox;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    CCNStatusItemWindowAppearance *appearance = [CCNStatusItemWindowAppearance defaultAppearance];
//    appearance.cornerRadius = 85.0;
    appearance.presentationTransition = CCNPresentationTransitionSlideAndFade;
    appearance.backgroundColor = [NSColor colorWithCalibratedRed:0.196 green:0.200 blue:0.204 alpha:0.950];
    [CCNStatusItem setWindowAppearance:appearance];

    [CCNStatusItem presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                        contentViewController:[ContentViewController viewController]];
}

- (IBAction)enableDisableCheckboxAction:(id)sender {
    [CCNStatusItem sharedInstance].appearsDisabled = (self.enableDisableCheckbox.state == NSOnState);
}

@end
