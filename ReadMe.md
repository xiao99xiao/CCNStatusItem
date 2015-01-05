[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=phranck&url=https://github.com/phranck/CCNStatusItemView&title=CCNStatusItemView&tags=github&category=software)
![Travis Status](https://travis-ci.org/phranck/CCNStatusItemView.png?branch=master)



## Overview

`CCNStatusItemView` is a subclass of `NSView` to act as a custom view for `NSStatusItem`. It supports a customizable statusItemWindow handling any `NSViewController` instance for presenting the content.

Here is a shot of the included example application:

![CCNStatusItemView Example Application](https://dl.dropbox.com/u/34133216/WebImages/Github/CCNStatusItemView.png)


## Project Integration

You can add `CCNStatusItemView` by using CocoaPods. Just add this line to your Podfile:

```
pod 'CCNStatusItemView'
```


## Usage

After it is integrated into your project you are just a four-liner away from your (maybe) first `NSStatusItem` with a custom view. A good place to add these lines of code is your AppDelegate:

```Objective-C
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   ...
   [CCNStatusItemView presentStatusItemWithImage:[NSImage imageNamed:@"statusBarIcon"]
                                  alternateImage:[NSImage imageNamed:@"statusBarAlternateIcon"]
                           contentViewController:[[MyContentViewController alloc] initWithNibName:NSStringFromClass([MyContentViewController class]) bundle:nil]];
   ...
}
```

That's all! You will have some options to change the design of this statusItem popover window using `CCNStatusItemWindowDesign`. In the example above internally `CCNStatusItemView` uses `[CCNStatusItemWindowDesign defaultDesign]` to set a default design. The next example will show you how to change the design of your statusItem popover window:

```Objective-C
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ...
    
    CCNStatusItemWindowStyle *style = [CCNStatusItemWindowStyle defaultStyle];
    style.cornerRadius = 13.0;
    style.presentationTransition = CCNPresentationTransitionSlideAndFade;
    [CCNStatusItemView setWindowStyle:style];
    
    [CCNStatusItemView setDesign:design];
    [CCNStatusItemView presentStatusItemWithImage:[NSImage imageNamed:@"statusBarIcon"]
                                   alternateImage:[NSImage imageNamed:@"statusBarAlternateIcon"]
                            contentViewController:[[MyContentViewController alloc] initWithNibName:NSStringFromClass([MyContentViewController class]) bundle:nil]];
    ...
}
```


## Some Side Notes

The statusItem window's frame size will be determined automatically by calling `preferedContentSize` on the `contentViewController`. So you shouldn't forget to set it to a reasonable value. Using XIB's for building the content a good war to do so is returning:

```Objective-C
- (CGSize)preferredContentSize {
    return self.view.frame.size;
}

```


## Requirements

`CCNStatusItemView` was written using ARC and "modern" Objective-C 2. At the moment it has been tested only on OS X 10.10 Yosemite, but it should run on 10.9, too.


## Contribution

The code is provided as-is, and it is far off being complete or free of bugs. If you like this component feel free to support it. Make changes related to your needs, extend it or just use it in your own project. Pull-Requests and Feedbacks are very welcome. Just contact me at [phranck@cocoanaut.com](mailto:phranck@cocoanaut.com?Subject=[CCNStatusItemView] Your component on Github) or send me a ping on Twitter [@TheCocoaNaut](http://twitter.com/TheCocoaNaut). 


## Documentation
The complete documentation you will find on [CocoaDocs](http://cocoadocs.org/docsets/CCNStatusItemView/).


## License
This software is published under the [MIT License](http://cocoanaut.mit-license.org).
