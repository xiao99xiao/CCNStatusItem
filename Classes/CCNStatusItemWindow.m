//
//  Created by Frank Gregor on 26.12.14.
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


#import "CCNStatusItemWindow.h"
#import "CCNStatusItemWindowBackgroundView.h"
#import "CCNStatusItemView.h"
#import "CCNStatusItemWindowDesign.h"

@interface CCNStatusItemWindow () {
    CCNStatusItemWindowDesign *_design;
}
@property (strong) CCNStatusItemView *statusItem;
@property (strong) NSView *userContentView;
@property (strong, nonatomic) CCNStatusItemWindowBackgroundView *backgroundView;
@end

@implementation CCNStatusItemWindow

+ (instancetype)statusItemWindowWithDesign:(CCNStatusItemWindowDesign *)design {
    return [[[self class] alloc] initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES design:design];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag design:(CCNStatusItemWindowDesign *)design {
    _design = design;
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        self.alphaValue = 0.0;
        self.opaque = NO;
        self.hasShadow = YES;
        self.level = NSStatusWindowLevel;
        self.backgroundColor = [NSColor clearColor];
    }
    return self;
}

-(BOOL)canBecomeKeyWindow{
    return YES;
}

-(BOOL)canBecomeMainWindow{
    return YES;
}

- (id)contentView {
    return self.userContentView;
}

- (void)setContentView:(id)contentView {
    if ([self.userContentView isEqual:contentView]) return;

    NSView *userContentView = (NSView *)contentView;
    NSRect bounds = userContentView.bounds;

    self.backgroundView = super.contentView;
    if (!self.backgroundView) {
        self.backgroundView = [[CCNStatusItemWindowBackgroundView alloc] initWithFrame:bounds design:_design];
        self.backgroundView.wantsLayer = YES;
        self.backgroundView.layer.frame = self.backgroundView.frame;
        self.backgroundView.layer.cornerRadius = _design.statusItemWindowCornerRadius;
        self.backgroundView.layer.masksToBounds = YES;
        self.backgroundView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        super.contentView = self.backgroundView;
    }

    if (self.userContentView) {
        [self.userContentView removeFromSuperview];
    }

    self.userContentView = userContentView;
    self.userContentView.frame = [self contentRectForFrameRect:bounds];
    self.userContentView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);

    [self.backgroundView addSubview:self.userContentView];
}

- (NSRect)frameRectForContentRect:(NSRect)contentRect {
    return NSMakeRect(NSMinX(contentRect), NSMinY(contentRect), NSWidth(contentRect), NSHeight(contentRect) + _design.statusItemWindowArrowHeight);
}

@end
