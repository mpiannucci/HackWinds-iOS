//
//  FirstViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import "FirstViewController.h"
#import "AsyncImageView.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet AsyncImageView *holderImageButton;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Load the imageview
    NSURL *url = [NSURL URLWithString:@"http://www.warmwinds.com/wp-content/uploads/surf-cam-stills/image00001.jpg"];
    [_holderImageButton setImageURL:url];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
