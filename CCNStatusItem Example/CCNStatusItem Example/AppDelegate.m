//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "AppDelegate.h"
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowConfiguration.h"
#import "ContentViewController.h"


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *enableDisableCheckbox;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    CCNStatusItemWindowConfiguration *windowConfig = [CCNStatusItemWindowConfiguration defaultConfiguration];
    windowConfig.presentationTransition = CCNPresentationTransitionSlideAndFade;
//    windowConfig.cornerRadius = 85.0;
    windowConfig.pinned = YES;
    [CCNStatusItem setWindowConfiguration:windowConfig];

    [CCNStatusItem presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                        contentViewController:[ContentViewController viewController]];
}

- (IBAction)enableDisableCheckboxAction:(id)sender {
    [CCNStatusItem sharedInstance].statusItem.button.appearsDisabled = (self.enableDisableCheckbox.state == NSOnState);
}

@end
