//
//  Created by Frank Gregor on 21/12/14.
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

#import "CCNStatusItemView.h"
#import "CCNStatusItemWindowController.h"


@interface CCNStatusItemView () <NSWindowDelegate>
@property (strong) NSStatusItem *statusItem;
@property (assign, nonatomic, getter = isHighlighted) BOOL highlighted;
@property (copy) CCNStatusItemViewLeftMouseActionHandler leftMouseDownActionHandler;
@property (copy) CCNStatusItemViewRightMouseActionHandler rightMouseDownActionHandler;

@property (assign) CCNStatusItemPresentationMode presentationMode;
@property (assign) BOOL canHandleMouseEvent;
@property (assign, nonatomic) BOOL isStatusItemWindowVisible;

@property (strong, nonatomic) CCNStatusItemWindowController *statusItemWindowController;
@property (strong, nonatomic) CCNStatusItemWindowStyle *style;
@end

@implementation CCNStatusItemView

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _image = nil;
        _alternateImage = nil;

        _statusItem = nil;
        _highlighted = NO;
        _leftMouseDownActionHandler = nil;
        _rightMouseDownActionHandler = nil;
        _presentationMode = CCNStatusItemPresentationModeUndefined;
        _canHandleMouseEvent = YES;
        _isStatusItemWindowVisible = NO;
        _statusItemWindowController = nil;
        _style = [CCNStatusItemWindowStyle defaultStyle];
    }
    return self;
}

- (void)dealloc {
    _image = nil;
    _alternateImage = nil;
    _leftMouseDownActionHandler = nil;
    _rightMouseDownActionHandler = nil;
    _statusItemWindowController = nil;
    _style = nil;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t _onceToken;
    __strong static CCNStatusItemView *_sharedInstance;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

- (void)reset {
    self.image = nil;
    self.alternateImage = nil;
    self.statusItem = nil;
    self.leftMouseDownActionHandler  = nil;
    self.rightMouseDownActionHandler = nil;
    self.presentationMode = CCNStatusItemPresentationModeUndefined;
    self.frame = NSZeroRect;
    self.statusItemWindowController = nil;
}

- (void)configureWithImage:(NSImage *)defaultImage alternateImage:(NSImage *)alternateImage {
    NSAssert(defaultImage, @"[%@] The default Image must not be nil!", [self className]);
    NSAssert(alternateImage, @"[%@] The alternate Image must not be nil!", [self className]);

    CCNStatusItemView *statusItemView = [CCNStatusItemView sharedInstance];
    if (statusItemView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWindowDidResignKeyNotification:) name:NSWindowDidResignKeyNotification object:nil];

        statusItemView.image = defaultImage;
        statusItemView.alternateImage = alternateImage;
        statusItemView.frame = NSMakeRect(0, 0, defaultImage.size.width, [NSStatusBar systemStatusBar].thickness);

        statusItemView.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:defaultImage.size.width + self.style.iconHorizontalEdgeSpacing];
        statusItemView.statusItem.view = statusItemView;

    }
}

#pragma mark - Creating and Displaying a StatusBarItem

+ (void)presentStatusItemWithImage:(NSImage *)defaultImage
                    alternateImage:(NSImage *)alternateImage
             contentViewController:(NSViewController *)contentViewController {

    CCNStatusItemView *sharedItem = [CCNStatusItemView sharedInstance];
    [sharedItem reset];
    [sharedItem configureWithImage:defaultImage alternateImage:alternateImage];

    sharedItem.presentationMode = CCNStatusItemPresentationModeImage;
    sharedItem.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:sharedItem
                                                                                         contentViewController:contentViewController
                                                                                                         style:sharedItem.style];
}

+ (void)presentStatusItemWithImage:(NSImage *)defaultImage
                    alternateImage:(NSImage *)alternateImage
                   leftMouseAction:(CCNStatusItemViewLeftMouseActionHandler)leftMouseDown
                  rightMouseAction:(CCNStatusItemViewRightMouseActionHandler)rightMouseDown {

    CCNStatusItemView *sharedItem = [CCNStatusItemView sharedInstance];
    [sharedItem reset];
    [sharedItem configureWithImage:defaultImage alternateImage:alternateImage];

    sharedItem.presentationMode = CCNStatusItemPresentationModeCustomView;
    sharedItem.leftMouseDownActionHandler = leftMouseDown;
    sharedItem.rightMouseDownActionHandler = rightMouseDown;
}

#pragma mark - NSView Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [_statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];

    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;

    NSSize iconSize = icon.size;
    NSRect bounds = self.bounds;
    CGFloat iconX = (NSWidth(bounds) - iconSize.width) / 2;
    CGFloat iconY = (NSHeight(bounds) - iconSize.height) / 2;
    CGPoint iconPoint = NSMakePoint(iconX, iconY);

    [icon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

#pragma mark - NSNotification

- (void)handleWindowDidResignKeyNotification:(NSNotification *)note {
    if (self.statusItemWindowController && [self.statusItemWindowController windowIsOpen]) {
        self.highlighted = !self.highlighted;
    }
}

#pragma mark - Custom Accessors

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay:YES];
    }
}

- (void)setImage:(NSImage *)newImage {
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage {
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

- (BOOL)isStatusItemWindowVisible {
    return (self.statusItemWindowController ? self.statusItemWindowController.windowIsOpen : NO);
}

- (void)setStatusItemWindowController:(CCNStatusItemWindowController *)statusItemWindowController {
    if (![_statusItemWindowController isEqual:statusItemWindowController]) {
        _statusItemWindowController = statusItemWindowController;
        self.leftMouseDownActionHandler = ^(CCNStatusItemView *statusItem) {
            if (statusItem.isStatusItemWindowVisible) {
                [statusItem.statusItemWindowController dismissStatusItemWindow];
            } else {
                [statusItem.statusItemWindowController showStatusItemWindow];
            }
        };
    }
}

- (void)setWindowStyle:(CCNStatusItemWindowStyle *)style {
    _style = style;
    self.toolTip = _style.toolTip;
}

#pragma mark - Handling StatusItem Layout

+ (void)setWindowStyle:(CCNStatusItemWindowStyle *)windowStyle {
    CCNStatusItemView *sharedInstance = [CCNStatusItemView sharedInstance];
    sharedInstance.windowStyle = windowStyle;
}

#pragma mark - NSResponder

- (void)mouseDown:(NSEvent *)theEvent {
    if (!self.canHandleMouseEvent) return;
    if (!self.leftMouseDownActionHandler) return;
    if (self.statusItemWindowController && self.statusItemWindowController.animationIsRunning) return;

    self.canHandleMouseEvent = NO;

    if (self.leftMouseDownActionHandler) {
        self.leftMouseDownActionHandler(self);
        self.highlighted = !self.highlighted;
        self.canHandleMouseEvent = YES;
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    if (!self.canHandleMouseEvent) return;
    if (!self.rightMouseDownActionHandler) return;
    if (self.statusItemWindowController && self.statusItemWindowController.animationIsRunning) return;

    self.canHandleMouseEvent = NO;

    if (self.rightMouseDownActionHandler) {
        self.rightMouseDownActionHandler(self);
        self.highlighted = !self.highlighted;
        self.canHandleMouseEvent = YES;
    }
}

#pragma mark - NSWindowDelegate

- (void)windowDidResignKey:(NSNotification *)note {
    self.highlighted = !self.highlighted;
}

@end
