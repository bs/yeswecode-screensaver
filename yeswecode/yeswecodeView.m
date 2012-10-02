//
//  yeswecodeView.m
//  yeswecode
//
//  Created by Britt Selvitelle on 9/29/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//

#import "yeswecodeView.h"

@implementation yeswecodeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    stepSizes = [[[NSMutableArray alloc] init] retain];
    finalBlueToRed = [[[NSMutableArray alloc] init] retain];
    finalRedToBlue = [[[NSMutableArray alloc] init] retain];
   
    // colorState - Indicates if we're fading the background from red to blue or visa-versa
    // 0 - blue to red
    // 1 - red to blue
    colorState = 0;
    tick = 0;
    
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        
        // Load the octacat
        NSBundle* saverBundle = [NSBundle bundleForClass:[self class]];
        NSString* octaPath = [saverBundle pathForImageResource:@"baracktocat.jpg"];
        octaImage = [[NSImage alloc] initWithContentsOfFile:octaPath];
        
        
        [finalBlueToRed addObject:[NSNumber numberWithDouble:238.0]]; // 238.0
        [finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];
        [finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];
        
        [finalRedToBlue addObject:[NSNumber numberWithDouble:100.0]];
        [finalRedToBlue addObject:[NSNumber numberWithDouble:150.0]];
        [finalRedToBlue addObject:[NSNumber numberWithDouble:160.0]];

        
        // Calculate the step size to converge on
        // 238
        redStepSize = fmax([finalRedToBlue[0] doubleValue], [finalBlueToRed[0] doubleValue]) - fmin([finalRedToBlue[0] doubleValue], [finalBlueToRed[0] doubleValue]);
        
        // 47
        greenStepSize = fmax([finalRedToBlue[1] doubleValue], [finalBlueToRed[1] doubleValue]) - fmin([finalRedToBlue[1] doubleValue], [finalBlueToRed[1] doubleValue]);

        // 80
        blueStepSize = fmax([finalRedToBlue[2] doubleValue], [finalBlueToRed[2] doubleValue]) - fmin([finalRedToBlue[2] doubleValue], [finalBlueToRed[2] doubleValue]);

        // 238
        step = fmin(fmin(redStepSize, greenStepSize), blueStepSize);
        double mod = 400;
        redStep = redStepSize/(step*mod);
        greenStep = greenStepSize/(step*mod);
        blueStep = blueStepSize/(step*mod);
        
        //stepSizes = @[@1.0, @(greenStepSize/step), @(blueStepSize/step)];
        [stepSizes addObject:[NSNumber numberWithDouble:redStep]];
        [stepSizes addObject:[NSNumber numberWithDouble:greenStep]];
        [stepSizes addObject:[NSNumber numberWithDouble:blueStep]];
        
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
    [self drawBackground];
    [self drawBaracktocat];
}

- (void)drawBaracktocat
{
    NSSize viewSize  = [self bounds].size;
    NSSize imageSize = NSMakeSize(600, 600);
    
    NSPoint viewCenter;
    viewCenter.x = viewSize.width  * 0.50;
    viewCenter.y = viewSize.height * 0.50;
    
    NSPoint imageOrigin = viewCenter;
    imageOrigin.x -= imageSize.width  * 0.50;
    imageOrigin.y -= imageSize.height * 0.40;
    NSRect destRect;
    destRect.origin = imageOrigin;
    destRect.size = imageSize;
    
    // Draw the Baracktocat
    [octaImage drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)drawBackground {
    float red = currentRed/255.0f;
    float green = currentGreen/255.0f;
    float blue = currentBlue/255.0f;
    float alpha = 1.0f;
    
    NSColor *color = [NSColor colorWithDeviceRed: red green: green blue: blue alpha: alpha];
    
    [color set];
    NSRectFill([self bounds]);
}

- (void)animateOneFrame
{
    // blue -> red
    if (colorState == 0) {
        double finalRed = [finalBlueToRed[0] doubleValue];
        double finalGreen = [finalBlueToRed[1] doubleValue];
        double finalBlue = [finalBlueToRed[2] doubleValue];
        
        if (currentRed < finalRed) {
            currentRed += [stepSizes[2] doubleValue];
            stepSizes[0] = [NSNumber numberWithDouble:[stepSizes[2] doubleValue]+redStep];
        }
        
        if (currentGreen > finalGreen) {
            currentGreen -= [stepSizes[1] doubleValue];
            stepSizes[1] = [NSNumber numberWithDouble:[stepSizes[1] doubleValue]+greenStep];
        }
        
        if (currentBlue > finalBlue) {
            currentBlue -= [stepSizes[0] doubleValue];
            stepSizes[2] = [NSNumber numberWithDouble:[stepSizes[0] doubleValue]+blueStep];
        }
    
        if (currentRed >= finalRed && currentGreen <= finalGreen && currentBlue <= finalBlue) {
            colorState = 1;
            stepSizes[0] = [NSNumber numberWithDouble:redStep];
            stepSizes[0] = [NSNumber numberWithDouble:greenStep];
            stepSizes[0] = [NSNumber numberWithDouble:blueStep];
        }
    }

    // red -> blue
    else if (colorState == 1) {
        double finalRed = [finalRedToBlue[0] doubleValue];
        double finalGreen = [finalRedToBlue[1] doubleValue];
        double finalBlue = [finalRedToBlue[2] doubleValue];


        if (currentRed > finalRed) {
            currentRed -= [stepSizes[0] doubleValue];
            stepSizes[0] = [NSNumber numberWithDouble:[stepSizes[0] doubleValue]+redStep];
            
        }
        if (currentGreen < finalGreen) {
            currentGreen += [stepSizes[1] doubleValue];
            stepSizes[1] = [NSNumber numberWithDouble:[stepSizes[1] doubleValue]+greenStep];
            
        }
        if (currentBlue < finalBlue) {
            currentBlue += ([stepSizes[2] doubleValue]);
            stepSizes[2] = [NSNumber numberWithDouble:[stepSizes[2] doubleValue]+blueStep];
        }
        
        
        if (currentRed <= finalRed && currentGreen >= finalGreen && currentBlue >= finalBlue) {
            tick += 1;
            if (tick == 400) {
                tick = 0;
                colorState = 0;
                stepSizes[0] = [NSNumber numberWithDouble:redStep];
                stepSizes[0] = [NSNumber numberWithDouble:greenStep];
                stepSizes[0] = [NSNumber numberWithDouble:blueStep];
            }
        }
    }

    
   [self drawBackground];
    [self drawBaracktocat];
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
