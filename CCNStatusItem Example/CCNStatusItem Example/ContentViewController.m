//
//  ContentViewController.m
//  CCNStatusItemView Example
//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "ContentViewController.h"
#import "CCNStatusItem.h"

@interface ContentViewController ()
@end

@implementation ContentViewController

+ (instancetype)viewController {
    return [[[self class] alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (IBAction)quitButtonAction:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (CGSize)preferredContentSize {
    return self.view.frame.size;
}

@end
