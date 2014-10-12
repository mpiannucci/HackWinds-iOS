//
//  BuoyViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 10/9/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//
// Block Island ID: Station 44097
// Montauk ID: Station 44017
//
#define NDBCBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define BIurl [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44097.spec"]
#define montaukUrl [NSURL URLWithString:@"http://www.ndbc.noaa.gov/data/realtime2/44017.spec"]

#import "BuoyViewController.h"
#import "Buoy.h"

@interface BuoyViewController ()
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHolder;
@property (weak, nonatomic) IBOutlet UITableView *buoyTable;

@end

@implementation BuoyViewController
{
    NSMutableArray *buoyDatas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return so there will always be 20 rows
    return 20;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Get the interface items
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buoyItem"];
    
    // Return the cell view
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
