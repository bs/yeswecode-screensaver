//
//  AppDelegate.h
//  yeswecodeDebuggingPreview
//
//  Created by Britt Selvitelle on 10/2/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//
//  Huge thanks to Simon Whitaker, without whom I'd still not be able to debug this.
//  https://github.com/simonwhitaker/twirly-screensaver

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, assign) IBOutlet ScreenSaverView * view;
@property (nonatomic, retain) NSTimer * timer;

@end
