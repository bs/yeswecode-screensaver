//
//  yeswecodeView.h
//  yeswecode
//
//  Created by Britt Selvitelle on 9/29/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface yeswecodeView : ScreenSaverView {
    NSRect backgroundRect;
    NSRect octoRect;

    NSImage *octaImage;

    NSInteger colorState;
    NSMutableArray *finalRedToBlue;
    NSMutableArray *finalBlueToRed;

    float currentRed;
    float currentGreen;
    float currentBlue;
    
    NSMutableArray *currentStepSizes;
    double redStep;
    double greenStep;
    double blueStep;

    int delayTick;
}

@end
