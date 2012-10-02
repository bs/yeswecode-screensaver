//
//  yeswecodeView.h
//  yeswecode
//
//  Created by Britt Selvitelle on 9/29/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface yeswecodeView : ScreenSaverView {
    NSImage *octaImage;
    float currentRed;
    float currentGreen;
    float currentBlue;
    
    NSInteger colorState;
    int tick;
    
    double step;
    double redStep;
    double greenStep;
    double blueStep;
    double redStepSize;
    double greenStepSize;
    double blueStepSize;
    NSMutableArray *finalRedToBlue;
    NSMutableArray *finalBlueToRed;
    NSMutableArray *stepSizes;
}

- (void)drawBackground: (NSInteger)changeRed;
- (void)drawBaraktocat;


@end
