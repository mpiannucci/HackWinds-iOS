//
//  WaveWatchChartViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 9/10/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define BASE_WW_CHART_URL @"http://polar.ncep.noaa.gov/waves/WEB/multi_1.latest_run/plots/US_eastcoast.%@.%@%03dh.png"
#define PAST_HOUR_PREFIX @"h"
#define FUTURE_HOUR_PREFIX @"f"
#define WW_WAVE_HEIGHT_CHART 0
#define WW_SWELL_HEIGHT_CHART 1
#define WW_SWELL_PERIOD_CHART 2
#define WW_WIND_CHART 3
#define WW_HOUR_STEP 3
#define WW_IMAGE_COUNT 56
#define WW_MAX_HOUR 165
#define WW_MIN_HOUR 0

#import "WaveWatchChartViewController.h"
#import "AsyncImageView.h"

@interface WaveWatchChartViewController()

@property (weak, nonatomic) IBOutlet UIImageView *chartImageView;
@property (weak, nonatomic) IBOutlet UIButton *chartPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *chartPauseButton;
@property (weak, nonatomic) IBOutlet UIProgressView *chartProgressBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chartTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *manualControlSwitch;
@property (weak, nonatomic) IBOutlet UIButton *nextChartImageButton;
@property (weak, nonatomic) IBOutlet UIButton *previousChartImageButton;
@property (weak, nonatomic) IBOutlet UITextField *currentDisplayedHourEdit;
@property (weak, nonatomic) IBOutlet UISlider *animationSpeedSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentHourUnitLabel;

// View specifics
@property (strong, nonatomic) NSMutableArray *animationImages;

-(void) hourEditDoneClicked:(id)sender;

@end

@implementation WaveWatchChartViewController {
    BOOL needsReload[3];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set up the keyboard and the text edit for directly typing in an hour to go to
    self.currentDisplayedHourEdit.delegate = self;
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(hourEditDoneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.currentDisplayedHourEdit.inputAccessoryView = keyboardDoneButtonView;
    
    // Load the settings
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    self.animationSpeedSlider.value = [[defaults objectForKey:@"ChartAnimationSpeed"] doubleValue];
    self.manualControlSwitch.on = [[defaults objectForKey:@"ManualChartControl"] boolValue];
    [self manualControlSwitchChanged:self.manualControlSwitch];
    
    // Initialize the aniimation image array
    self.animationImages = [[NSMutableArray alloc] init];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.chartPauseButton setHidden:YES];
    [self.chartPlayButton setHidden:YES];
    
    // Reset the reload flag
    for (int i = 0; i < 3; i++) {
        needsReload[i] = YES;
    }
    
    [self sendChartImageAnimationLoadForType:WW_WAVE_HEIGHT_CHART forIndex:0];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self];
    [self.chartImageView stopAnimating];
    
    [super viewWillDisappear:animated];
}

- (void)sendChartImageAnimationLoadForType:(int)chartType forIndex:(int)index {
    NSString *chartTimePrefix;
    if (index == 0) {
        chartTimePrefix = PAST_HOUR_PREFIX;
    } else {
        chartTimePrefix = FUTURE_HOUR_PREFIX;
    }
    
    // Get the correct prefix so we can craft the correct url
    NSString *chartTypePrefix = [self getChartURLPrefixForType:chartType];
    
    // Create the full url and send out the image load request
    NSURL *nextURL = [NSURL URLWithString:[NSString stringWithFormat:BASE_WW_CHART_URL, chartTypePrefix, chartTimePrefix, index * WW_HOUR_STEP]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:nextURL
                                               target:self
                                               action:@selector(imageLoadSuccess:)];
}

- (void) imageLoadSuccess:(id)sender {
    // Add the image to the array for animation
    [self.animationImages addObject:sender];
    
    if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex]) {
        // TODO: Set the correct percentages here, this was the one from the detailed forecast view
        [self.chartProgressBar setProgress:self.animationImages.count/12.0f animated:YES];
    }
    
    if ([self.animationImages count] < 2) {
        // If its the first image set it to the header as a holder
        [self.chartImageView setImage:sender];
    } else if ([self.animationImages count] == WW_IMAGE_COUNT) {
        // We have all of the images so animate!!!
        [self.chartImageView setAnimationImages:self.animationImages];
        [self.chartImageView setAnimationDuration:(self.animationSpeedSlider.maximumValue - self.animationSpeedSlider.value) * WW_IMAGE_COUNT];
        
        // Okay so this is really hacky... For some reasons the images are not loaded correctly on the first
        // pass through each of the views.
        if (needsReload[self.chartTypeSegmentControl.selectedSegmentIndex])  {
            self.animationImages = [[NSMutableArray alloc] init];
            needsReload[self.chartTypeSegmentControl.selectedSegmentIndex] = NO;
        } else {
            // Show the play button if manual control is off, Hide the stop button always
            [self.chartPauseButton setHidden:YES];
            [self.chartPlayButton setHidden:[self.manualControlSwitch isOn]];
            
            // Set the current hour to zero
            [self.currentDisplayedHourEdit setText:@"0"];
            
            // Hide the progress bar becasue its loaded
            [self.chartProgressBar setHidden:YES];
        }
    }
    if (self.animationImages.count < WW_IMAGE_COUNT) {
        // If the animation array isnt full, get the next image on the stack
        [self sendChartImageAnimationLoadForType:(int)[self.chartTypeSegmentControl selectedSegmentIndex]
                                        forIndex:(int)self.animationImages.count];
    }
}

- (NSString*) getChartURLPrefixForType:(int)chartType {
    switch (chartType) {
        case WW_WAVE_HEIGHT_CHART:
            return @"hs";
        case WW_SWELL_HEIGHT_CHART:
            return @"hs_sw1";
        case WW_SWELL_PERIOD_CHART:
            return @"tp_sw1";
        case WW_WIND_CHART:
            return @"u10";
        default:
            return @"";
    }
}

- (IBAction) chartPauseButtonClicked:(id)sender {
    [self.chartImageView stopAnimating];
    [self.chartPauseButton setHidden:YES];
    [self.chartPlayButton setHidden:NO];
}

- (IBAction) chartPlayButtonClicked:(id)sender {
    [self.chartImageView startAnimating];
    [self.chartPlayButton setHidden:YES];
    [self.chartPauseButton setHidden:NO];
}

- (IBAction) closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chartTypeValueChanged:(id)sender {
    [self.chartPlayButton setHidden:YES];
    [self.chartImageView stopAnimating];
    
    // Reset the progress bar
    [self.chartProgressBar setHidden:NO];
    [self.chartProgressBar setProgress:0.0f animated:YES];
    
    // Reset the animation images and start lolading the new ones
    self.animationImages = [[NSMutableArray alloc] init];
    [self sendChartImageAnimationLoadForType:(int)[sender selectedSegmentIndex] forIndex:0];
}

- (IBAction)manualControlSwitchChanged:(id)sender {
    if ([self.chartImageView isAnimating]) {
        [self.chartImageView stopAnimating];
    }
    
    // Save the state to the settings
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults setObject:[NSNumber numberWithBool:[sender isOn]] forKey:@"ManualChartControl"];
    [defaults synchronize];
    
    // Hide the play and pause buttons if necessary
    [self.chartPlayButton setHidden:[sender isOn]];
    [self.chartPauseButton setHidden:[sender isOn]];
    
    // Hide or show  the manual controls
    [self.nextChartImageButton setHidden:![sender isOn]];
    [self.previousChartImageButton setHidden:![sender isOn]];
    [self.currentDisplayedHourEdit setHidden:![sender isOn]];
    [self.currentHourUnitLabel setHidden:![sender isOn]];
}

- (IBAction)nextChartImageButtonClicked:(id)sender {
    int hour = [self.currentDisplayedHourEdit.text intValue];
    if (hour == WW_MAX_HOUR) {
        return;
    }
    
    // Increase the hour count, display the correct image for the time
    hour += WW_HOUR_STEP;
    self.currentDisplayedHourEdit.text = [NSString stringWithFormat:@"%d", hour];
    self.chartImageView.image = [self.animationImages objectAtIndex:hour/WW_HOUR_STEP];
}

- (IBAction)previousChartImageButtonClicked:(id)sender {
    int hour = [self.currentDisplayedHourEdit.text intValue];
    if (hour == WW_MIN_HOUR) {
        return;
    }
    
    // Decrease the hour count, display the correct image for the time
    hour -= WW_HOUR_STEP;
    self.currentDisplayedHourEdit.text = [NSString stringWithFormat:@"%d", hour];
    self.chartImageView.image = [self.animationImages objectAtIndex:hour/WW_HOUR_STEP];
}

- (IBAction)animationSpeedSliderValueChanged:(id)sender {
    // Save the new value
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    [defaults setObject:[NSNumber numberWithFloat:self.animationSpeedSlider.value] forKey:@"ChartAnimationSpeed"];
    [defaults synchronize];
    
    // Stop the animation
    BOOL wasAnimating = NO;
    if ([self.chartImageView isAnimating]) {
        [self.chartImageView stopAnimating];
        wasAnimating = YES;
    }
    
    // Set the new animation speed
    self.chartImageView.animationDuration = (self.animationSpeedSlider.maximumValue - self.animationSpeedSlider.value) * WW_IMAGE_COUNT;
    
    // Restart the animation if they were animating when it changed
    if (wasAnimating) {
        [self.chartImageView startAnimating];
    }

}

#pragma mark - TextEdit

- (IBAction)displayedHourEdited:(id)sender {
    // Round the hour to the nearest multiple of three to get a valid animating point
    double rawHour = [self.currentDisplayedHourEdit.text doubleValue];
    int hour = ceil(rawHour / WW_HOUR_STEP) * WW_HOUR_STEP;
    
    if (hour < WW_MIN_HOUR) {
        hour = WW_MIN_HOUR;
    } else if (hour >= WW_MAX_HOUR) {
        hour = WW_MAX_HOUR;
    }
    
    // Update the textedit and show the correct image
    self.currentDisplayedHourEdit.text = [NSString stringWithFormat:@"%d", hour];
    self.chartImageView.image = [self.animationImages objectAtIndex:hour/WW_HOUR_STEP];
    
    [self animateTextField: sender up: NO];
}

- (IBAction)displayedHourStartedEditing:(id)sender {
    [self animateTextField: sender up: YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movementDistance;
    if (self.view.frame.size.height < 660) {
        movementDistance = 255;
    } else {
        movementDistance = 195;
    }
    
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void) hourEditDoneClicked:(id)sender {
    [self.view endEditing:YES];
}

@end
