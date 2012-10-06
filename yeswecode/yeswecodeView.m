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

        backgroundRect.origin.x = 0;
        backgroundRect.origin.y = 0;
        backgroundRect.size     = NSMakeSize(size.width, size.height);

        // colorState - Indicates if we're fading the background from red to blue or visa-versa
        // 0 - blue to red
        // 1 - red to blue
        colorState = 0;

        // Load the octacat
        NSBundle* saverBundle = [NSBundle bundleForClass:[self class]];
        NSString* octaPath = [saverBundle pathForImageResource:@"baracktocat.jpg"];
        octaImage = [[NSImage alloc] initWithContentsOfFile:octaPath];

        NSSize octoViewSize  = size;
        NSSize octoImageSize = NSMakeSize(600, 600);

        NSPoint octoViewCenter;
        octoViewCenter.x = octoViewSize.width  * 0.50;
        octoViewCenter.y = octoViewSize.height * 0.50;

        NSPoint octoImageOrigin = octoViewCenter;
        octoImageOrigin.x -= octoImageSize.width  * 0.50;
        octoImageOrigin.y -= octoImageSize.height * 0.38;

        octoRect.origin = octoImageOrigin;
        octoRect.size = octoImageSize;

        finalBlueToRed = [[NSMutableArray alloc] init];
        finalRedToBlue = [[NSMutableArray alloc] init];

        // Polar red value
        [finalBlueToRed addObject:[NSNumber numberWithDouble:238.0]];
        [finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];
        [finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];

        // Polar blue value
        [finalRedToBlue addObject:[NSNumber numberWithDouble:100.0]];
        [finalRedToBlue addObject:[NSNumber numberWithDouble:150.0]];
        [finalRedToBlue addObject:[NSNumber numberWithDouble:160.0]];

        // Calculate the step size to converge on
        double redStepSize = fmax([finalRedToBlue[0] doubleValue], [finalBlueToRed[0] doubleValue]) - fmin([finalRedToBlue[0] doubleValue], [finalBlueToRed[0] doubleValue]);

        double greenStepSize = fmax([finalRedToBlue[1] doubleValue], [finalBlueToRed[1] doubleValue]) - fmin([finalRedToBlue[1] doubleValue], [finalBlueToRed[1] doubleValue]);

        double blueStepSize = fmax([finalRedToBlue[2] doubleValue], [finalBlueToRed[2] doubleValue]) - fmin([finalRedToBlue[2] doubleValue], [finalBlueToRed[2] doubleValue]);

        double minStep = fmin(fmin(redStepSize, greenStepSize), blueStepSize);

        // Quick modification of the step sizes
        double mod = 400;

        redStep = redStepSize/(minStep * mod);
        greenStep = greenStepSize/(minStep * mod);
        blueStep = blueStepSize/(minStep * mod);

        currentStepSizes = [[NSMutableArray alloc] init];
        [currentStepSizes addObject:[NSNumber numberWithDouble:redStep]];
        [currentStepSizes addObject:[NSNumber numberWithDouble:greenStep]];
        [currentStepSizes addObject:[NSNumber numberWithDouble:blueStep]];

        // Counter to delay color transition
        delayTick = 0;

        // Initial color
        currentRed = [finalRedToBlue[0] doubleValue];
        currentGreen = [finalRedToBlue[1] doubleValue];
        currentBlue = [finalRedToBlue[2] doubleValue];
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
    [octaImage drawInRect:octoRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
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
    int fontSize       = (backgroundRect.size.height * fontScale);

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
    int xOffset     = (backgroundRect.size.width / 2) - (attrSize.width / 2);
    int yOffset     = (backgroundRect.size.height - (backgroundRect.size.height * 0.9)) + (attrSize.height);

    [attributedText drawAtPoint:NSMakePoint(xOffset, yOffset)];
}

- (void)drawBackground
{
    float red = currentRed/255.0f;
    float green = currentGreen/255.0f;
    float blue = currentBlue/255.0f;
    float alpha = 1.0f;

    NSColor *color = [NSColor colorWithDeviceRed: red green: green blue: blue alpha: alpha];

    [color set];
    NSRectFill(backgroundRect);
}

// XXX This is inefficient and altogether a little wacky
// XXX I like the fade from blue->red after the first iteration of accelleration
//       - Calculate what this is up front
// XXX I don't like the red->blue deceleration due to the pause in the middle
//       - Don't get rid of red so quickly and leave blue so much time
- (void)animateOneFrame
{
    // blue -> red
    if (colorState == 0) {
        double finalRed = [finalBlueToRed[0] doubleValue];
        double finalGreen = [finalBlueToRed[1] doubleValue];
        double finalBlue = [finalBlueToRed[2] doubleValue];

        if (currentRed < finalRed) {
            currentRed += [currentStepSizes[2] doubleValue];
            currentStepSizes[0] = [NSNumber numberWithDouble:[currentStepSizes[2] doubleValue]+redStep];
        }

        if (currentGreen > finalGreen) {
            currentGreen -= [currentStepSizes[1] doubleValue];
            currentStepSizes[1] = [NSNumber numberWithDouble:[currentStepSizes[1] doubleValue]+greenStep];
        }

        if (currentBlue > finalBlue) {
            currentBlue -= [currentStepSizes[0] doubleValue];
            currentStepSizes[2] = [NSNumber numberWithDouble:[currentStepSizes[0] doubleValue]+blueStep];
        }

        if (currentRed >= finalRed && currentGreen <= finalGreen && currentBlue <= finalBlue) {
            colorState = 1;
            currentStepSizes[0] = [NSNumber numberWithDouble:redStep];
            currentStepSizes[0] = [NSNumber numberWithDouble:greenStep];
            currentStepSizes[0] = [NSNumber numberWithDouble:blueStep];
        }
    }

    // red -> blue
    else if (colorState == 1) {
        double finalRed = [finalRedToBlue[0] doubleValue];
        double finalGreen = [finalRedToBlue[1] doubleValue];
        double finalBlue = [finalRedToBlue[2] doubleValue];

        if (currentRed > finalRed) {
            currentRed -= [currentStepSizes[0] doubleValue];
            currentStepSizes[0] = [NSNumber numberWithDouble:[currentStepSizes[0] doubleValue]+redStep];
        }

        if (currentGreen < finalGreen) {
            currentGreen += [currentStepSizes[1] doubleValue];
            currentStepSizes[1] = [NSNumber numberWithDouble:[currentStepSizes[1] doubleValue]+greenStep];
        }

        if (currentBlue < finalBlue) {
            currentBlue += ([currentStepSizes[2] doubleValue]);
            currentStepSizes[2] = [NSNumber numberWithDouble:[currentStepSizes[2] doubleValue]+blueStep];
        }

        if (currentRed <= finalRed && currentGreen >= finalGreen && currentBlue >= finalBlue) {
            delayTick += 1;
            if (delayTick == 400) {
                delayTick = 0;
                colorState = 0;
                currentStepSizes[0] = [NSNumber numberWithDouble:redStep];
                currentStepSizes[0] = [NSNumber numberWithDouble:greenStep];
                currentStepSizes[0] = [NSNumber numberWithDouble:blueStep];
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
