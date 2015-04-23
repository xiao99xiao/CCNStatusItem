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

#import <Availability.h>
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowController.h"


static NSString *const CCNStatusItemFrameKeyPath = @"statusItem.button.window.frame";


@interface NSStatusBarButton (Tools)
@end
@implementation NSStatusBarButton (Tools)
- (void)rightMouseDown:(NSEvent *)theEvent {}
@end



#pragma mark - CCNStatusItemView
#pragma mark -

@interface CCNStatusItem () <NSWindowDelegate> {
    id _globalDragEventMonitor;
    BOOL _proximityDragCollisionHandled;
    NSBezierPath *_proximityDragCollisionArea;
    NSInteger _pbChangeCount;
}
@property (strong) NSStatusItem *statusItem;
@property (copy) CCNStatusItemDropHandler dropHandler;
@property (assign) CCNStatusItemPresentationMode presentationMode;
@property (assign, nonatomic) BOOL isStatusItemWindowVisible;

@property (strong, nonatomic) CCNStatusItemWindowController *statusItemWindowController;
@property (strong, nonatomic) CCNStatusItemWindowConfiguration *windowConfiguration;
@end

@implementation CCNStatusItem

#pragma mark - Initialization

+ (instancetype)sharedInstance {
    static dispatch_once_t _onceToken;
    __strong static CCNStatusItem *_sharedInstance;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] initSingleton];
    });
    return _sharedInstance;
}

- (instancetype)init {
    NSString *exceptionMessage = [NSString stringWithFormat:@"You must NOT init '%@' manually! Use class method 'sharedInstance' instead.", [self className]];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:exceptionMessage userInfo:nil];
}

- (instancetype)initSingleton {
    self = [super init];
    if (self) {
        _globalDragEventMonitor = nil;
        _proximityDragCollisionHandled = NO;

        _pbChangeCount = [NSPasteboard pasteboardWithName:NSDragPboard].changeCount;

        self.statusItem = nil;
        self.presentationMode = CCNStatusItemPresentationModeUndefined;
        self.isStatusItemWindowVisible = NO;
        self.statusItemWindowController = nil;
        self.windowConfiguration = [CCNStatusItemWindowConfiguration defaultConfiguration];

        self.dropHandler = nil;
        self.proximityDragDetectionEnabled = NO;
        self.proximityDragDistance = 23.0;
        self.proximityDragDetectionHandler = nil;

        // We need to observe that because when an status bar item has been removed from the status bar
        // and OS X reorganize all items, we must recalculate our _proximityDragCollisionArea.
        [self addObserver:self forKeyPath:CCNStatusItemFrameKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:CCNStatusItemFrameKeyPath];

    _statusItem = nil;
    _statusItemWindowController = nil;
    _windowConfiguration = nil;
    _dropHandler = nil;
    _proximityDragDetectionHandler = nil;
    _proximityDragCollisionArea = nil;
}

- (void)configureWithImage:(NSImage *)itemImage {
    [itemImage setTemplate:YES];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    NSStatusBarButton *button = self.statusItem.button;
    button.target = self;
    button.action = @selector(handleStatusItemButtonAction:);
    button.image = itemImage;
}

- (void)configureWithView:(NSView *)itemView {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSWidth(itemView.frame)];

    NSStatusBarButton *button = self.statusItem.button;
    button.frame = itemView.frame;
    [button addSubview:itemView];
    itemView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
}

- (void)configureProximityDragCollisionArea {
    NSRect statusItemFrame = self.statusItem.button.window.frame;
    NSRect collisionFrame = NSInsetRect(statusItemFrame, -_proximityDragDistance, -_proximityDragDistance);
    _proximityDragCollisionArea = [NSBezierPath bezierPathWithRoundedRect:collisionFrame xRadius:NSWidth(collisionFrame)/2 yRadius:NSHeight(collisionFrame)/2];
}

#pragma mark - Creating and Displaying a StatusBarItem

+ (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController {
    [[self class] presentStatusItemWithImage:itemImage contentViewController:contentViewController dropHandler:nil];
}

+ (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (sharedItem.presentationMode == CCNStatusItemPresentationModeUndefined) {
        sharedItem.dropHandler = dropHandler;
        [sharedItem configureWithImage:itemImage];
        [sharedItem configureProximityDragCollisionArea];
        sharedItem.presentationMode = CCNStatusItemPresentationModeImage;
        sharedItem.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:sharedItem
                                                                                             contentViewController:contentViewController
                                                                                               windowConfiguration:sharedItem.windowConfiguration];
    }
}

+ (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController {
    [[self class] presentStatusItemWithView:itemView contentViewController:contentViewController dropHandler:nil];
}

+ (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    if (sharedItem.presentationMode == CCNStatusItemPresentationModeUndefined) {
        sharedItem.dropHandler = dropHandler;
        [sharedItem configureWithView:itemView];
        [sharedItem configureProximityDragCollisionArea];
        sharedItem.presentationMode = CCNStatusItemPresentationModeCustomView;
        sharedItem.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:sharedItem
                                                                                             contentViewController:contentViewController
                                                                                               windowConfiguration:sharedItem.windowConfiguration];
    }
}

#pragma mark - Button Action Handling

- (void)handleStatusItemButtonAction:(id)sender {
    if (self.isStatusItemWindowVisible) {
        [self dismissStatusItemWindow];
    } else {
        [self showStatusItemWindow];
    }
}

#pragma mark - Custom Accessors

- (BOOL)isStatusItemWindowVisible {
    return (self.statusItemWindowController ? self.statusItemWindowController.windowIsOpen : NO);
}

- (void)setWindowConfiguration:(CCNStatusItemWindowConfiguration *)configuration {
    _windowConfiguration = configuration;
    self.statusItem.button.toolTip = configuration.toolTip;
}

- (BOOL)isDarkMode {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    return ( style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );
}

- (void)setProximityDragDetectionEnabled:(BOOL)proximityDraggingDetectionEnabled {
    if (_proximityDragDetectionEnabled != proximityDraggingDetectionEnabled) {
        _proximityDragDetectionEnabled = proximityDraggingDetectionEnabled;

        if (_proximityDragDetectionEnabled) {
            __weak typeof(self) wSelf = self;
            _globalDragEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask handler:^(NSEvent *event) {
                NSPoint eventLocation = [event locationInWindow];
                if ([_proximityDragCollisionArea containsPoint:eventLocation]) {
                    // This is for detection if files has been dragged. If it happens the NSPasteboard's changeCount will be incremented.
                    // Dragging a window will keep that changeCount untouched.
                    // (Thank you Matthias aka @eternalstorms Gansrigler for that smart hint!).
                    NSInteger currentChangeCount = [NSPasteboard pasteboardWithName:NSDragPboard].changeCount;
                    if (_pbChangeCount == currentChangeCount) {
                        return;
                    }
                    _pbChangeCount = currentChangeCount;

                    if (!_proximityDragCollisionHandled) {
                        if (wSelf.proximityDragDetectionHandler) {
                            wSelf.proximityDragDetectionHandler(wSelf, eventLocation, CCNProximityDragStatusEntered);
                        }
                        _proximityDragCollisionHandled = YES;
                    }
                }
                else {
                    if (wSelf.proximityDragDetectionHandler) {
                        wSelf.proximityDragDetectionHandler(wSelf, eventLocation, CCNProximityDragStatusExited);
                    }
                    _proximityDragCollisionHandled = NO;
                }
            }];
        }
        else {
            [NSEvent removeMonitor:_globalDragEventMonitor];
        }
    }
}

#pragma mark - Handling the Status Item Window

- (void)showStatusItemWindow {
    [self.statusItemWindowController showStatusItemWindow];
}

- (void)dismissStatusItemWindow {
    [self.statusItemWindowController dismissStatusItemWindow];
}

#pragma mark - Handling StatusItem Layout

+ (void)setWindowConfiguration:(CCNStatusItemWindowConfiguration *)configuration {
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration = configuration;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:CCNStatusItemFrameKeyPath]) {
        [self configureProximityDragCollisionArea];
    }
}

@end
