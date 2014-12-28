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

#import <Cocoa/Cocoa.h>
#import "CCNStatusItemWindowDesign.h"


FOUNDATION_EXPORT NSString *const CCNStatusItemViewWillBecomeActiveNotification;
FOUNDATION_EXPORT NSString *const CCNStatusItemViewDidBecomeActiveNotification;
FOUNDATION_EXPORT NSString *const CCNStatusItemViewWillResignActiveNotification;
FOUNDATION_EXPORT NSString *const CCNStatusItemViewDidResignActiveNotification;


@class CCNStatusItemView;

typedef void(^CCNStatusItemViewLeftMouseActionHandler)(CCNStatusItemView *statusItem);
typedef void(^CCNStatusItemViewRightMouseActionHandler)(CCNStatusItemView *statusItem);

typedef NS_ENUM(NSUInteger, CCNStatusItemPresentationMode) {
    CCNStatusItemPresentationModeUndefined = 0,
    CCNStatusItemPresentationModeImage,
    CCNStatusItemPresentationModeCustomView
};


#pragma mark - CCNStatusItemView

@interface CCNStatusItemView : NSView

#pragma mark - Creating and Displaying a StatusBarItem

+ (void)presentStatusItemWithImage:(NSImage *)defaultImage
                    alternateImage:(NSImage *)alternateImage
             contentViewController:(NSViewController *)contentViewController;

//+ (void)presentStatusItemWithImage:(NSImage *)defaultImage
//                    alternateImage:(NSImage *)alternateImage
//                   leftMouseAction:(CCNStatusItemViewLeftMouseActionHandler)leftMouseAction
//                  rightMouseAction:(CCNStatusItemViewRightMouseActionHandler)rightMouseAction;

#pragma mark - Handling the StatusBarItem Image

@property (strong, nonatomic) NSImage *image;
@property (strong, nonatomic) NSImage *alternateImage;
@property (readonly, nonatomic) BOOL isStatusItemWindowVisible;
@property (readonly, nonatomic) CCNStatusItemPresentationMode presentationMode;


#pragma mark - Handling StatusItem Layout

@property (readonly, nonatomic) CCNStatusItemWindowDesign *design;
+ (void)setDesign:(CCNStatusItemWindowDesign *)design;

@end
