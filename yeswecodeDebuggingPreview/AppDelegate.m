//
//  AppDelegate.m
//  yeswecodeDebuggingPreview
//
//  Created by Britt Selvitelle on 10/2/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//
//  Huge thanks to Simon Whitaker, without whom I'd still not be able to debug this.
//  https://github.com/simonwhitaker/twirly-screensaver

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize timer=_timer;
@synthesize view=_view;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.view.animationTimeInterval
                                                  target:self.view
                                                selector:@selector(animateOneFrame)
                                                userInfo:nil
                                                 repeats:YES];
}

@end
