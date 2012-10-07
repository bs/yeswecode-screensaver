//
//  yeswecodeView.m
//  yeswecode
//
//  Created by Britt Selvitelle on 9/29/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//

#import "yeswecodeView.h"

@implementation yeswecodeView

- (void)commonInit {
    [self setAnimationTimeInterval:1/30.0];
    
    NSSize size = [self bounds].size;
    
    CGRect r = self.backgroundRect;
    r.origin.x = 0;
    r.origin.y = 0;
    r.size     = NSMakeSize(size.width, size.height);
    self.backgroundRect = r;
    
    // colorState - Indicates if we're fading the background from red to blue or visa-versa
    // 0 - blue to red
    // 1 - red to blue
    self.colorState = 0;
    
    // Load the octocat into an NSImageView
    NSBundle *saverBundle = [NSBundle bundleForClass:[self class]];
    NSString *octaPath = [saverBundle pathForImageResource:@"baracktocat.jpg"];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 600, 600)];
    imageView.image = [[NSImage alloc] initWithContentsOfFile:octaPath];
    [self addSubview:imageView];
    self.octoImageView = imageView;
    
    // Create a label to hold the "time remaining" string
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 20, self.bounds.size.width, 100)];
    
    // Allow the label to grow/shrink with the parent view
    label.autoresizingMask = NSViewWidthSizable;
    
    // Anchor the label to the bottom of the parent view
    label.autoresizingMask |= NSViewMaxYMargin;
    
    label.alignment = NSCenterTextAlignment;
    
    label.backgroundColor = [NSColor clearColor];
    [label setEditable:NO];
    [label setBezeled:NO];
    label.textColor = [NSColor colorWithDeviceRed:254.0f/255.0f
                                            green:229.0f/255.0f
                                             blue:161.0f/255.0f
                                            alpha:1.0];
    label.font = [NSFont fontWithName:@"Helvetica Neue" size:24.0];
    [self addSubview:label];
    self.timeLeftLabel = label;
    
    self.finalBlueToRed = [[NSMutableArray alloc] init];
    self.finalRedToBlue = [[NSMutableArray alloc] init];
    
    // Polar red value
    [self.finalBlueToRed addObject:[NSNumber numberWithDouble:238.0]];
    [self.finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];
    [self.finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];
    
    // Polar blue value
    [self.finalRedToBlue addObject:[NSNumber numberWithDouble:100.0]];
    [self.finalRedToBlue addObject:[NSNumber numberWithDouble:150.0]];
    [self.finalRedToBlue addObject:[NSNumber numberWithDouble:160.0]];
    
    // Calculate the step size to converge on
    double redStepSize = fmax([self.finalRedToBlue[0] doubleValue], [self.finalBlueToRed[0] doubleValue]) - fmin([self.finalRedToBlue[0] doubleValue], [self.finalBlueToRed[0] doubleValue]);
    
    double greenStepSize = fmax([self.finalRedToBlue[1] doubleValue], [self.finalBlueToRed[1] doubleValue]) - fmin([self.finalRedToBlue[1] doubleValue], [self.finalBlueToRed[1] doubleValue]);
    
    double blueStepSize = fmax([self.finalRedToBlue[2] doubleValue], [self.finalBlueToRed[2] doubleValue]) - fmin([self.finalRedToBlue[2] doubleValue], [self.finalBlueToRed[2] doubleValue]);
    
    double minStep = fmin(fmin(redStepSize, greenStepSize), blueStepSize);
    
    // Quick modification of the step sizes
    double mod = 400;
    
    self.redStep = redStepSize/(minStep * mod);
    self.greenStep = greenStepSize/(minStep * mod);
    self.blueStep = blueStepSize/(minStep * mod);
    
    self.currentStepSizes = [[NSMutableArray alloc] init];
    [self.currentStepSizes addObject:[NSNumber numberWithDouble:self.redStep]];
    [self.currentStepSizes addObject:[NSNumber numberWithDouble:self.greenStep]];
    [self.currentStepSizes addObject:[NSNumber numberWithDouble:self.blueStep]];
    
    // Counter to delay color transition
    self.delayTick = 0;
    
    // Initial color
    self.currentRed = [self.finalRedToBlue[0] doubleValue];
    self.currentGreen = [self.finalRedToBlue[1] doubleValue];
    self.currentBlue = [self.finalRedToBlue[2] doubleValue];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
        [self commonInit];
    }

    return self;
}

// XXX This is inefficient and altogether a little wacky
// XXX I like the fade from blue->red after the first iteration of accelleration
//       - Calculate what this is up front
// XXX I don't like the red->blue deceleration due to the pause in the middle
//       - Don't get rid of red so quickly and leave blue so much time
- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    // blue -> red
    if (self.colorState == 0) {
        double finalRed = [self.finalBlueToRed[0] doubleValue];
        double finalGreen = [self.finalBlueToRed[1] doubleValue];
        double finalBlue = [self.finalBlueToRed[2] doubleValue];
        
        if (self.currentRed < finalRed) {
            self.currentRed += [self.currentStepSizes[2] doubleValue];
            self.currentStepSizes[0] = [NSNumber numberWithDouble:[self.currentStepSizes[2] doubleValue]+self.redStep];
        }
        
        if (self.currentGreen > finalGreen) {
            self.currentGreen -= [self.currentStepSizes[1] doubleValue];
            self.currentStepSizes[1] = [NSNumber numberWithDouble:[self.currentStepSizes[1] doubleValue]+self.greenStep];
        }
        
        if (self.currentBlue > finalBlue) {
            self.currentBlue -= [self.currentStepSizes[0] doubleValue];
            self.currentStepSizes[2] = [NSNumber numberWithDouble:[self.currentStepSizes[0] doubleValue]+self.blueStep];
        }
        
        if (self.currentRed >= finalRed && self.currentGreen <= finalGreen && self.currentBlue <= finalBlue) {
            self.colorState = 1;
            self.currentStepSizes[0] = [NSNumber numberWithDouble:self.redStep];
            self.currentStepSizes[0] = [NSNumber numberWithDouble:self.greenStep];
            self.currentStepSizes[0] = [NSNumber numberWithDouble:self.blueStep];
        }
    }
    
    // red -> blue
    else if (self.colorState == 1) {
        double finalRed = [self.finalRedToBlue[0] doubleValue];
        double finalGreen = [self.finalRedToBlue[1] doubleValue];
        double finalBlue = [self.finalRedToBlue[2] doubleValue];
        
        if (self.currentRed > finalRed) {
            self.currentRed -= [self.currentStepSizes[0] doubleValue];
            self.currentStepSizes[0] = [NSNumber numberWithDouble:[self.currentStepSizes[0] doubleValue]+self.redStep];
        }
        
        if (self.currentGreen < finalGreen) {
            self.currentGreen += [self.currentStepSizes[1] doubleValue];
            self.currentStepSizes[1] = [NSNumber numberWithDouble:[self.currentStepSizes[1] doubleValue]+self.greenStep];
        }
        
        if (self.currentBlue < finalBlue) {
            self.currentBlue += ([self.currentStepSizes[2] doubleValue]);
            self.currentStepSizes[2] = [NSNumber numberWithDouble:[self.currentStepSizes[2] doubleValue]+self.blueStep];
        }
        
        if (self.currentRed <= finalRed && self.currentGreen >= finalGreen && self.currentBlue >= finalBlue) {
            self.delayTick += 1;
            if (self.delayTick == 400) {
                self.delayTick = 0;
                self.colorState = 0;
                self.currentStepSizes[0] = [NSNumber numberWithDouble:self.redStep];
                self.currentStepSizes[0] = [NSNumber numberWithDouble:self.greenStep];
                self.currentStepSizes[0] = [NSNumber numberWithDouble:self.blueStep];
            }
        }
    }
    
    [self drawBackground];
    [self drawBaracktocat];
    [self drawTimeLeft];

}

- (void)drawBaracktocat
{
    // Position the octocat image in the center of the view
    CGRect r = self.octoImageView.frame;
    r.origin.x = self.bounds.size.width / 2 - r.size.width / 2;
    r.origin.y = self.bounds.size.height / 2 - r.size.width / 2.2;
    self.octoImageView.frame = r;
}

- (void)drawTimeLeft
{
    // Font setup
    // Time left between E-Day and now
    // XXX Just get the seconds between the two dates
    // XXX Don't use dateWithNaturalLanguageString
    NSDate *now = [NSDate date];
    NSDate *eDay = [NSDate dateWithNaturalLanguageString:@"11/6/2012"];

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:now
                                                          toDate:eDay
                                                         options:0];

    // Time that has passed today
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                    fromDate:now];

    long secondsLeft = 60 - [todayComponents second];
    long minutesLeft = 60 - [todayComponents minute];
    long hoursLeft = 24 - [todayComponents hour];
    long daysLeft = [components day];

    NSString *timeLeft = [NSString stringWithFormat:@"%ld days, %ld hours, %ld minutes and %ld seconds.", daysLeft, hoursLeft, minutesLeft, secondsLeft];

    self.timeLeftLabel.stringValue = timeLeft;
    self.timeLeftLabel.font = [NSFont fontWithName:@"Helvetica Neue" size:self.bounds.size.height * 0.04];
    
    // Adjust the height of self.timeLeftLabel so that it's always a set distance from
    // the bottom of its parent view.
    NSSize s = [timeLeft sizeWithAttributes:@{NSFontAttributeName: self.timeLeftLabel.font}];
    CGRect r = self.timeLeftLabel.frame;
    r.size.height = s.height;
    self.timeLeftLabel.frame = r;
}

- (void)drawBackground
{
    float red = self.currentRed/255.0f;
    float green = self.currentGreen/255.0f;
    float blue = self.currentBlue/255.0f;
    float alpha = 1.0f;

    NSColor *color = [NSColor colorWithDeviceRed: red green: green blue: blue alpha: alpha];

    [color set];
    NSRectFill(self.backgroundRect);
}

- (void)animateOneFrame
{
    self.needsDisplay = YES;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
