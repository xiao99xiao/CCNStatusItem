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


#import <Foundation/Foundation.h>

@interface CCNStatusItemWindowDesign : NSObject

+ (instancetype)defaultDesign;

@property (assign, nonatomic) CGFloat statusItemWindowArrowHeight;                  // default: 9.0
@property (assign, nonatomic) CGFloat statusItemWindowArrowWidth;                   // default: 21.0
@property (assign, nonatomic) CGFloat statusItemWindowCornerRadius;                 // default: 5.0
@property (assign, nonatomic) CGFloat statusItemWindowToStatusItemMargin;           // default: 2.0
@property (assign, nonatomic) NSTimeInterval statusItemWindowAnimationDuration;     // default: 0.25
@property (strong, nonatomic) NSColor *statusItemWindowBackgroundColor;
@property (strong, nonatomic) NSString *statusItemToolTip;

@end
