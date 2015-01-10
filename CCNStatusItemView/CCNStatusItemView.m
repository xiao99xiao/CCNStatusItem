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

NSString *const CCNInterfaceStyleDefaultsKey = @"AppleInterfaceStyle";
NSString *const CCNAppleInterfaceThemeChangedNotification = @"AppleInterfaceThemeChangedNotification";

static NSImage  *_itemImage, *_alternateItemImage;

typedef NS_ENUM(NSUInteger, CCNStatusItemViewInterfaceStyle) {
    CCNStatusItemViewInterfaceStyleLight = 0,
    CCNStatusItemViewInterfaceStyleDark
};


@interface CCNStatusItemView () <NSWindowDelegate>
@property (strong) NSStatusItem *statusItem;
@property (strong, nonatomic) NSImage *image;
@property (strong, nonatomic) NSImage *alternateImage;
@property (readonly, nonatomic) BOOL hasStatusBarButton;

@property (readonly) CCNStatusItemViewInterfaceStyle interfaceStyle;
@property (assign, nonatomic, getter = isHighlighted) BOOL highlighted;
@property (copy) CCNStatusItemLeftMouseActionHandler leftMouseDownActionHandler;

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
        _itemImage = nil;
        _alternateItemImage = nil;

        _statusItem = nil;
        _highlighted = NO;
        _leftMouseDownActionHandler = nil;
        _presentationMode = CCNStatusItemPresentationModeUndefined;
        _canHandleMouseEvent = YES;
        _isStatusItemWindowVisible = NO;
        _statusItemWindowController = nil;
        _style = [CCNStatusItemWindowStyle defaultStyle];
        _appearsDisabled = NO;
    }
    return self;
}

- (void)dealloc {
    _leftMouseDownActionHandler = nil;
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
    self.presentationMode = CCNStatusItemPresentationModeUndefined;
    self.statusItemWindowController = nil;
    self.appearsDisabled = NO;
}

- (void)configureWithImage:(NSImage *)itemImage alternateImage:(NSImage *)alternateImage {
    NSAssert(itemImage, @"[%@] The default Image must not be nil!", [self className]);
    NSAssert(alternateImage, @"[%@] The alternate Image must not be nil!", [self className]);

    CCNStatusItemView *sharedItem = [CCNStatusItemView sharedInstance];
    if (sharedItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWindowDidResignKeyNotification:) name:NSWindowDidResignKeyNotification object:nil];

        _itemImage = itemImage;
        _alternateItemImage = alternateImage;

        sharedItem.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        if ([sharedItem.statusItem respondsToSelector:@selector(button)]) {
            [self configureCustomStatusItem];
        }
        else {
            [self configureCustomStatusItem];
        }
    }
}

- (void)configureStatusItemButton {
    [self.image setTemplate:YES];

    self.statusItem.button.image = self.image;
    self.statusItem.button.target = self;
    self.statusItem.button.action = @selector(handleStatusItemButtonAction:);
}

- (void)configureCustomStatusItem {
    self.image = [self imageForCurrentInterfaceStyle];
    self.alternateImage = [self alternateImageForCurrentInterfaceStyle];
    self.frame = NSMakeRect(0, 0, self.image.size.width, [NSStatusBar systemStatusBar].thickness);
    self.statusItem.view = [CCNStatusItemView sharedInstance];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppleInterfaceThemeChangedNotification:) name:CCNAppleInterfaceThemeChangedNotification object:nil];
}

#pragma mark - Creating and Displaying a StatusBarItem

+ (void)presentStatusItemWithImage:(NSImage *)itemImage
                    alternateImage:(NSImage *)alternateImage
             contentViewController:(NSViewController *)contentViewController {

    CCNStatusItemView *sharedItem = [CCNStatusItemView sharedInstance];
    [sharedItem reset];
    [sharedItem configureWithImage:itemImage alternateImage:alternateImage];

    sharedItem.presentationMode = CCNStatusItemPresentationModeImage;
    sharedItem.statusItemWindowController = [[CCNStatusItemWindowController alloc] initWithConnectedStatusItem:sharedItem
                                                                                         contentViewController:contentViewController
                                                                                                         style:sharedItem.style];
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

- (void)handleAppleInterfaceThemeChangedNotification:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

#pragma mark - Button Action Handling

- (void)handleStatusItemButtonAction:(id)sender {
    NSLog(@"handleStatusItemButtonAction");
    [self.statusItem.button highlight:YES];
    self.statusItem.button.highlighted = YES;
    if (self.leftMouseDownActionHandler) {
        self.leftMouseDownActionHandler(self);
    }
}


#pragma mark - Custom Accessors

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay:YES];
    }
}

- (NSImage *)image {
    return [self imageForCurrentInterfaceStyle];
}

- (void)setImage:(NSImage *)newImage {
    if (_itemImage != newImage) {
        _itemImage = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (NSImage *)alternateImage {
    return [self alternateImageForCurrentInterfaceStyle];
}

- (void)setAlternateImage:(NSImage *)newImage {
    if (_alternateItemImage != newImage) {
        _alternateItemImage = newImage;
        [self setNeedsDisplay:YES];
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

- (void)setAppearsDisabled:(BOOL)appearsDisabled {
    if (_appearsDisabled != appearsDisabled) {
        _appearsDisabled = appearsDisabled;
        if (self.statusItem.view) {
            [self setNeedsDisplay:YES];
        }
        else {
            self.statusItem.button.appearsDisabled = _appearsDisabled;
        }
    }
}

- (CCNStatusItemViewInterfaceStyle)interfaceStyle {
    NSString *style = [[NSUserDefaults standardUserDefaults] stringForKey:CCNInterfaceStyleDefaultsKey];
    return ([style isEqualToString:@"Dark"] ? CCNStatusItemViewInterfaceStyleDark : CCNStatusItemViewInterfaceStyleLight);
}

- (BOOL)hasStatusBarButton {
    id statusItem = [[NSStatusItem alloc] init];
    return [statusItem respondsToSelector:@selector(button)];
}

#pragma mark - Helper

- (NSImage *)tintedImage:(NSImage *)image withColor:(NSColor *)tintColor  {
    if (tintColor) {
        NSImage *tintedImage = [image copy];
        NSSize iconSize = [tintedImage size];
        NSRect iconRect = {NSZeroPoint, iconSize};

        [tintedImage lockFocus];
        [tintColor set];
        NSRectFillUsingOperation(iconRect, NSCompositeSourceAtop);
        [tintedImage unlockFocus];

        return tintedImage;
    }
    else {
        return image;
    }
}

- (NSImage *)tintedStatusItemImageForCurrentInterfaceStyle:(NSImage *)originalImage {
    NSImage *tintedImage;
    if (self.interfaceStyle == CCNStatusItemViewInterfaceStyleLight) {
        if (self.appearsDisabled) {
            if (self.isHighlighted) {
                tintedImage = [self tintedImage:originalImage withColor:[NSColor colorWithCalibratedWhite:0.190 alpha:1.000]];
            }
            else {
                tintedImage = [self tintedImage:originalImage withColor:[NSColor colorWithCalibratedWhite:0.706 alpha:1.000]];
            }
        }
        else {
            tintedImage = originalImage;
        }
    } else {
        if (self.appearsDisabled) {
            if (self.isHighlighted) {
                tintedImage = [self tintedImage:originalImage withColor:[[NSColor whiteColor] colorWithAlphaComponent:0.30]];
            } else {
                tintedImage = [self tintedImage:originalImage withColor:[NSColor colorWithCalibratedWhite:0.322 alpha:1.000]];
            }
        }
        else {
            tintedImage = [self tintedImage:originalImage withColor:[NSColor whiteColor]];
        }
    }
    return tintedImage;
}

- (NSImage *)imageForCurrentInterfaceStyle {
    return [self tintedStatusItemImageForCurrentInterfaceStyle:_itemImage];
}

- (NSImage *)alternateImageForCurrentInterfaceStyle {
    return [self tintedStatusItemImageForCurrentInterfaceStyle:_alternateItemImage];
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

#pragma mark - NSWindowDelegate

- (void)windowDidResignKey:(NSNotification *)note {
    self.highlighted = !self.highlighted;
}

@end
