//
//  ContentViewController.m
//  CCNStatusItemView Example
//
//  Created by Frank Gregor on 28.12.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@end

@implementation ContentViewController

- (IBAction)quitButtonAction:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (CGSize)preferredContentSize {
    return self.view.frame.size;
}

@end
