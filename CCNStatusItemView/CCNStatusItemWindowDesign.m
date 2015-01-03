//
//  Created by Frank Gregor on 27.12.14.
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


#import "CCNStatusItemWindowDesign.h"


static const CGFloat CCNStatusItemWindowDefaultArrowHeight              = 11.0;
static const CGFloat CCNStatusItemWindowDefaultArrowWidth               = 42.0;
static const CGFloat CCNStatusItemWindowDefaultCornerRadius             = 5.0;
static const CGFloat CCNStatusItemWindowDefaultStatusItemMargin         = 2.0;
static const NSTimeInterval CCNStatusItemWindowDefaultAnimationDuration = 0.20;
static NSColor *CCNStatusItemWindowDefaultBackgroundColor;
static const CGFloat CCNStatusItemIconDefaultHorizontalEdgeSpacing      = 10.0;


@implementation CCNStatusItemWindowDesign

+ (void)initialize {
    CCNStatusItemWindowDefaultBackgroundColor = [NSColor windowBackgroundColor];
}

+ (instancetype)defaultDesign {
    return [[[self class] alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.statusItemWindowArrowHeight         = CCNStatusItemWindowDefaultArrowHeight;
        self.statusItemWindowArrowWidth          = CCNStatusItemWindowDefaultArrowWidth;
        self.statusItemWindowCornerRadius        = CCNStatusItemWindowDefaultCornerRadius;
        self.statusItemWindowToStatusItemMargin  = CCNStatusItemWindowDefaultStatusItemMargin;
        self.statusItemWindowAnimationDuration   = CCNStatusItemWindowDefaultAnimationDuration;
        self.statusItemWindowBackgroundColor     = CCNStatusItemWindowDefaultBackgroundColor;

        self.statusItemToolTip                   = nil;
        self.statusItemIconHorizontalEdgeSpacing = CCNStatusItemIconDefaultHorizontalEdgeSpacing;
    }
    return self;
}

@end
