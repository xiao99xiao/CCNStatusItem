//
//  Created by Frank Gregor on 23.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2014 Frank Gregor, <phranck@cocoanaut.com>
 http://cocoanaut.mit-license.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import <QuartzCore/QuartzCore.h>
#import "CCNStatusItemWindowController.h"
#import "CCNStatusItemWindowDesign.h"


typedef NS_ENUM(NSUInteger, CCNStatusItemWindowAnimationType) {
    CCNStatusItemWindowAnimationTypeFadeIn = 0,
    CCNStatusItemWindowAnimationTypeFadeOut
};


#pragma mark - StatusItem Window Controller

@interface CCNStatusItemWindowController ()
@property (strong) CCNStatusItemView *statusItem;
@property (strong) CCNStatusItemWindowDesign *design;
@end

@implementation CCNStatusItemWindowController

- (id)initWithConnectedStatusItem:(CCNStatusItemView *)statusItem contentViewController:(NSViewController *)contentViewController design:(CCNStatusItemWindowDesign *)design {
    NSAssert(contentViewController.preferredContentSize.width != 0 && contentViewController.preferredContentSize.height != 0, @"[%@] The preferredContentSize of the contentViewController must not be NSZeroSize!", [self className]);

    self = [super init];
    if (self) {
        [self setupDefaults];

        self.statusItem = statusItem;
        self.design = design;

        // StatusItem Window
        self.window = [CCNStatusItemWindow statusItemWindowWithDesign:design];
        self.window.contentViewController = contentViewController;
    }
    return self;
}

- (void)setupDefaults {
    _windowIsOpen    = NO;
}

#pragma mark - Helper

- (void)updateWindowFrame {
    CGRect statusItemRect = [[self.statusItem window] frame];
    CGRect windowFrame = NSMakeRect(NSMinX(statusItemRect) - NSWidth(self.window.frame)/2 + NSWidth(statusItemRect)/2,
                                    NSMinY(statusItemRect) - NSHeight(self.window.frame) - 3,
                                    self.window.frame.size.width,
                                    self.window.frame.size.height);
    [self.window setFrame:windowFrame display:YES];

}

#pragma mark - Handling Window Visibility

- (void)showStatusItemWindow {
    if (self.animationIsRunning) return;

    [self updateWindowFrame];
    [self showWindow:nil];
    [self.window makeKeyAndOrderFront:self];
    [self animateWindow:self.window withAnimationType:CCNStatusItemWindowAnimationTypeFadeIn];
}

- (void)dismissStatusItemWindow {
    if (self.animationIsRunning) return;

    [self animateWindow:self.window withAnimationType:CCNStatusItemWindowAnimationTypeFadeOut];
}

- (void)animateWindow:(NSWindow *)window withAnimationType:(CCNStatusItemWindowAnimationType)animationType {
    __weak typeof(self) wSelf = self;
    self.animationIsRunning = YES;

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = self.design.statusItemWindowAnimationDuration;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [[window animator] setAlphaValue:(animationType == CCNStatusItemWindowAnimationTypeFadeIn ? 1.0 : 0.0)];

    } completionHandler:^{
        wSelf.animationIsRunning = NO;
        wSelf.windowIsOpen = (animationType == CCNStatusItemWindowAnimationTypeFadeIn);

        if (animationType == CCNStatusItemWindowAnimationTypeFadeIn) {
            [window makeKeyAndOrderFront:wSelf];
        }
        else {
            [window orderOut:wSelf];
            [window close];
        }
    }];
}

@end

