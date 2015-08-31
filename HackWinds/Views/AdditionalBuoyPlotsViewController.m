//
//  AdditionalBuoyPlotsViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 8/31/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "AdditionalBuoyPlotsViewController.h"
#import "NavigationBarTitleWithSubtitleView.h"
#import "BuoyModel.h"
#import "AsyncImageView.h"

@interface AdditionalBuoyPlotsViewController()

@property (weak, nonatomic) IBOutlet AsyncImageView *spectralPlotImageView;
@property (strong, nonatomic) NavigationBarTitleWithSubtitleView *navigationBarTitle;

@end

@implementation AdditionalBuoyPlotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the buoy location
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.nucc.HackWinds"];
    [defaults synchronize];
    NSString *buoyLocation = [defaults objectForKey:@"BuoyLocation"];
    
    // Set up the custom nav bar with the buoy location
    self.navigationBarTitle = [[NavigationBarTitleWithSubtitleView alloc] init];
    [self.navigationItem setTitleView: self.navigationBarTitle];
    [self.navigationBarTitle setTitleText:@"Additional Plots"];
    [self.navigationBarTitle setDetailText:[NSString stringWithFormat:@"Location: %@", buoyLocation]];
    
    // Fill the plots.. for now there is only the spectral density
    NSURL *spectralPlotURL = [[BuoyModel sharedModel] getSpectraPlotURLForLocation:buoyLocation];
    [self.spectralPlotImageView setImageURL:spectralPlotURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
