//
//  yeswecodeView.m
//  yeswecode
//
//  Created by Britt Selvitelle on 9/29/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//

#import "yeswecodeView.h"

@implementation yeswecodeView

// XXX Move more bits to consts

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
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

        // Load the octacat
        NSBundle* saverBundle = [NSBundle bundleForClass:[self class]];
        NSString* octaPath = [saverBundle pathForImageResource:@"baracktocat.jpg"];
        self.octaImage = [[NSImage alloc] initWithContentsOfFile:octaPath];

        NSSize octoViewSize  = size;
        NSSize octoImageSize = NSMakeSize(600, 600);

        NSPoint octoViewCenter;
        octoViewCenter.x = octoViewSize.width  * 0.50;
        octoViewCenter.y = octoViewSize.height * 0.50;

        NSPoint octoImageOrigin = octoViewCenter;
        octoImageOrigin.x -= octoImageSize.width  * 0.50;
        octoImageOrigin.y -= octoImageSize.height * 0.38;

        r = self.octoRect;
        r.origin = octoImageOrigin;
        r.size = octoImageSize;
        self.octoRect = r;

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

    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)drawBaracktocat
{
    [self.octaImage drawInRect:self.octoRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)drawTimeLeft
{
    // Font setup
    // XXX I have no clue why things crash if I init this data up top =(
    // XXX Move a lot of these calculations out of here
    float fontRed = 254.0f/255.0f;
    float fontGreen = 229.0f/255.0f;
    float fontBlue = 161.0f/255.0f;
    float fontAlpha = 1.0f;
    double fontScale = 0.04;

    NSColor *textColor = [NSColor colorWithDeviceRed: fontRed green: fontGreen blue: fontBlue alpha: fontAlpha];
    int fontSize       = (self.backgroundRect.size.height * fontScale);

    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSFont fontWithName:@"Helvetica Neue" size:fontSize], NSFontAttributeName,
                      textColor, NSForegroundColorAttributeName,
                      nil];

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

    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:
                                          timeLeft attributes: textAttributes];

    NSSize attrSize = [attributedText size];
    int xOffset     = (self.backgroundRect.size.width / 2) - (attrSize.width / 2);
    int yOffset     = (self.backgroundRect.size.height - (self.backgroundRect.size.height * 0.9)) + (attrSize.height);

    [attributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
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

// XXX This is inefficient and altogether a little wacky
// XXX I like the fade from blue->red after the first iteration of accelleration
//       - Calculate what this is up front
// XXX I don't like the red->blue deceleration due to the pause in the middle
//       - Don't get rid of red so quickly and leave blue so much time
- (void)animateOneFrame
{
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
    return;
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
