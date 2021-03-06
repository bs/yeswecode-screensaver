//
//  yeswecodeView.m
//  yeswecode
//
//  Created by Britt Selvitelle on 9/29/12.
//  Copyright (c) 2012 Britt Selvitelle. All rights reserved.
//

#import "yeswecodeView.h"

@implementation yeswecodeView

int const TIME_BETWEEN_EDAY_STRING_CHANGE = 200;
int const TIME_BETWEEN_FETCHING_NEW_EDAY_STRINGS = 10000;

- (void)commonInit {
  [self setAnimationTimeInterval:1/30.0];

  // colorState - Indicates if we're fading the background from red to blue or visa-versa
  // 0 - blue to red
  // 1 - red to blue
  self.colorState = 0;

  // Load the octocat into an NSImageView
  NSBundle *saverBundle = [NSBundle bundleForClass:[self class]];
  NSString *octaPath = [saverBundle pathForImageResource:[self determineImageToRender]];
  NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 600, 600)];
  imageView.image = [[NSImage alloc] initWithContentsOfFile:octaPath];
  [self addSubview:imageView];
  self.octoImageView = imageView;

  // Create a label to hold the "time remaining" string
  NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, 100)];

  // Allow the label to grow/shrink with the parent view
  label.autoresizingMask = NSViewWidthSizable;

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
  [self.finalBlueToRed addObject:[NSNumber numberWithDouble:205.0]];
  [self.finalBlueToRed addObject:[NSNumber numberWithDouble:0.0]];
  [self.finalBlueToRed addObject:[NSNumber numberWithDouble:26.0]];

  // Polar blue value
  [self.finalRedToBlue addObject:[NSNumber numberWithDouble:93.0]];
  [self.finalRedToBlue addObject:[NSNumber numberWithDouble:131.0]];
  [self.finalRedToBlue addObject:[NSNumber numberWithDouble:141.0]];

  // Calculate the step size to converge on
  double redStepSize = fmax([self.finalRedToBlue[0] doubleValue], [self.finalBlueToRed[0] doubleValue]) - fmin([self.finalRedToBlue[0] doubleValue], [self.finalBlueToRed[0] doubleValue]);
  double greenStepSize = fmax([self.finalRedToBlue[1] doubleValue], [self.finalBlueToRed[1] doubleValue]) - fmin([self.finalRedToBlue[1] doubleValue], [self.finalBlueToRed[1] doubleValue]);
  double blueStepSize = fmax([self.finalRedToBlue[2] doubleValue], [self.finalBlueToRed[2] doubleValue]) - fmin([self.finalRedToBlue[2] doubleValue], [self.finalBlueToRed[2] doubleValue]);
  double minStep = fmin(fmin(redStepSize, greenStepSize), blueStepSize);

  // Quick modification of the step sizes
  double mod = 1;

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

  self.changeEdayStringTick = 0;
  [self fetchEdayStrings];
  self.currentEdayString = [self getRandomEdayString];
}

- (NSString *)determineImageToRender {
  NSString *didWeWin;
  NSString *imageToRender;

  @try {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.openkeyval.org/yeswecode_screensaver_did_win"]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    didWeWin = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"[DIDHEWIN] Got a response: %@", didWeWin);
  }

  @catch (NSException *exception) {
    // Got an exception from the HTTP request.
    NSLog(@"[DIDHEWIN] Caught %@: %@", [exception name], [exception reason]);
  }

  @finally {
    if ([didWeWin isEqualToString:@"no"]) {
      imageToRender = @"picard.jpg";
    }
    else if ([didWeWin isEqualToString:@"yes"]) {
      imageToRender = @"obama_unicorn_rainbows.jpg";
    }
    else {
      imageToRender = @"baracktocat.jpg";
    }
  }

  return imageToRender;
}

- (NSString *)getRandomEdayString {
  unsigned long size = [self.edayStrings count];
  return self.edayStrings[arc4random() % size];
}

- (void)fetchEdayStrings {
  @try {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://yeswecode.webscript.io/get_eday_strings"]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    __autoreleasing NSError* error = nil;
    self.edayStrings = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSLog(@"Fetched %li strings", [self.edayStrings count]);
  }

  @catch (NSException *exception) {
    // Got an exception from the HTTP request.
    NSLog(@"[EDAYSTRING] Caught %@: %@", [exception name], [exception reason]);
  }

  @finally {
    if ([self.edayStrings count] == 0) {
      self.edayStrings = [NSArray arrayWithObject:@"#OFATECH"];
    }
  }  
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }

  return self;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  self = [super initWithFrame:frame isPreview:isPreview];

  if (self) {
    [self commonInit];
  }

  return self;
}

- (void)drawRect:(NSRect)rect {
  [super drawRect:rect];

  [self drawBackground];
  [self drawBaracktocat];
  [self drawTimeLeft];

  // blue -> red
  if (self.colorState == 0) {
    while (self.delayTick < 400) {
      self.delayTick += 1;
      return;
    }

    double finalRed = [self.finalBlueToRed[0] doubleValue];
    double finalGreen = [self.finalBlueToRed[1] doubleValue];
    double finalBlue = [self.finalBlueToRed[2] doubleValue];

    if (self.currentRed < finalRed) {
      self.currentRed += [self.currentStepSizes[0] doubleValue];
    }

    if (self.currentGreen > finalGreen) {
      self.currentGreen -= [self.currentStepSizes[1] doubleValue];
    }

    if (self.currentBlue > finalBlue) {
      self.currentBlue -= [self.currentStepSizes[2] doubleValue];
    }

    if (self.currentRed >= finalRed && self.currentGreen <= finalGreen && self.currentBlue <= finalBlue) {
      self.delayTick = 0;
      self.colorState = 1;
    }
  }

  // red -> blue
  else if (self.colorState == 1) {
    while (self.delayTick < 400) {
      self.delayTick += 1;
      return;
    }

    double finalRed = [self.finalRedToBlue[0] doubleValue];
    double finalGreen = [self.finalRedToBlue[1] doubleValue];
    double finalBlue = [self.finalRedToBlue[2] doubleValue];

    if (self.currentRed > finalRed) {
      self.currentRed -= [self.currentStepSizes[0] doubleValue];
    }

    if (self.currentGreen < finalGreen) {
      self.currentGreen += [self.currentStepSizes[1] doubleValue];
    }

    if (self.currentBlue < finalBlue) {
      self.currentBlue += ([self.currentStepSizes[2] doubleValue]);
    }

    if (self.currentRed <= finalRed && self.currentGreen >= finalGreen && self.currentBlue >= finalBlue) {
      self.delayTick = 0;
      self.colorState = 0;
    }
  }
}

- (void)drawBaracktocat {
  // Position the octocat image in the center-ish of the view
  CGRect r = self.octoImageView.frame;
  r.origin.x = self.bounds.size.width / 2 - r.size.width / 2;
  r.origin.y = self.bounds.size.height / 2 - r.size.height / 2.4;
  self.octoImageView.frame = r;
}


// Luckily we can just use a really dumb pluralization method here
- (NSString *)pluralize: (NSString *)word number: (long)number {
  NSString *s = [NSString stringWithFormat:@"%@%@", word, (number == 1 ? @"" : @"s")];
  return s;
}

- (void)drawTimeLeft {
  // Font setup
  // Time left between E-Day and now
  // XXX Just get the seconds between the two dates
  // XXX Don't use dateWithNaturalLanguageString
  NSDate *now = [NSDate date];
  NSDate *eDay = [NSDate dateWithNaturalLanguageString:@"2012-11-07T00:00:00-05:00"];
  
  NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  unsigned int unitFlags = NSDayCalendarUnit    |
                           NSHourCalendarUnit   |
                           NSMinuteCalendarUnit |
                           NSSecondCalendarUnit;

  NSDateComponents *components = [gregorianCalendar components:unitFlags
                                                    fromDate:now
                                                    toDate:eDay
                                                    options:0];
  NSString *timeLeft;

  if ([components day] <= 0) {
    self.changeEdayStringTick += 1;
    float edayStringChangeMod = self.changeEdayStringTick % TIME_BETWEEN_EDAY_STRING_CHANGE;
    float fetchNewStringsMod = self.changeEdayStringTick % TIME_BETWEEN_FETCHING_NEW_EDAY_STRINGS;

    if (edayStringChangeMod == 0) {
      self.currentEdayString = [self getRandomEdayString];
    }

    if (fetchNewStringsMod == 0) {
      [self fetchEdayStrings];
    }

    timeLeft = self.currentEdayString;
  }

  else {
    timeLeft = [NSString stringWithFormat:@"%ld %@, %ld %@, %ld %@ and %ld %@", [components day], [self pluralize:@"day" number:[components day]], [components hour], [self pluralize:@"hour" number:[components hour]], [components minute], [self pluralize:@"minute" number:[components minute]], [components second], [self pluralize:@"second" number:[components second]]];
  }

  self.timeLeftLabel.stringValue = timeLeft;
  self.timeLeftLabel.font = [NSFont fontWithName:@"Helvetica Neue" size:self.bounds.size.height * 0.04];

  // Adjust the height of self.timeLeftLabel according to the height of its parent view
  // Position it just below the OctoCat
  NSSize s = [timeLeft sizeWithAttributes:@{NSFontAttributeName: self.timeLeftLabel.font}];
  CGRect r = self.timeLeftLabel.frame;
  r.size.height = s.height;
  r.origin.y = self.octoImageView.frame.origin.y - 60;
  self.timeLeftLabel.frame = r;
}

- (void)drawBackground {
  float red = self.currentRed/255.0f;
  float green = self.currentGreen/255.0f;
  float blue = self.currentBlue/255.0f;
  float alpha = 1.0f;

  NSColor *color = [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: alpha];

  [color set];
  NSRectFill(self.bounds);
}

- (void)animateOneFrame {
  self.needsDisplay = YES;
}

- (BOOL)hasConfigureSheet {
  return NO;
}

- (NSWindow*)configureSheet {
  return nil;
}

@end
