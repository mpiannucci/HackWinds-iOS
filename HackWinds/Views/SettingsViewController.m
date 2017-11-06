//
//  SettingsViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 2/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "SettingsViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showDetailedForecastSwitch;

@property (strong, nonatomic) NSArray *inAppProducts;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inAppProducts = [[NSArray alloc] init];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self fetchInAppPurchaseProducts];
    [self loadSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadSettings {
    // Get the settings object
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    
    // Update the switch to match if detailed forecast info is enabled
    [self.showDetailedForecastSwitch setOn:[defaults boolForKey:@"ShowDetailedForecastInfo"]];
    
}

- (IBAction)acceptSettingsClick:(id)sender {
    // For now just make it go away
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)leaveTipClicked:(id)sender {
    if (self.inAppProducts.count < 1) {
        return;
    }
    
    UIAlertController *tipJarAlertController = [UIAlertController alertControllerWithTitle:@"Tip Jar"
                                                                                   message:@"If you enjoy HackWinds please consider leaving a tip to help support continuing development. This will go a long way to cover things like server costs and development hardware costs that are currently just covered out of my own pocket. Every little bit helps! Thank you!!"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [tipJarAlertController addAction:cancelAction];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    for (SKProduct *product in self.inAppProducts) {
        if (![product.productIdentifier containsString:@"tip"]) {
            continue;
        }
        
        NSString *tipTitle = [NSString stringWithFormat:@"%@: %@", product.localizedTitle, [numberFormatter stringFromNumber:product.price]];
        UIAlertAction *tipAction = [UIAlertAction actionWithTitle:tipTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self purchaseProduct:product];
            [tipJarAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [tipJarAlertController addAction:tipAction];
    }
    [self presentViewController:tipJarAlertController animated:YES completion:nil];
}

- (IBAction)contactDevClicked:(id)sender {
    // Open the compose view using the mailto url
    NSString *recipients = @"mailto:rhodysurf13@gmail.com?subject=HackWinds for iOS";
    NSString *email = [NSString stringWithFormat:@"%@", recipients];
    email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)showDisclaimerClicked:(id)sender {
    // Construct and show the disclaimer alert
    NSString* disclaimer = @"I do not own nor claim to own either the wave camera images or the tide information displayed in this app. This app is simply an interface to make checking the waves easier for surfers when using a phone. I am speifically operating within the user licensing for the Wunderground and WarmWinds API's.";
    UIAlertController *disclaimerController = [UIAlertController alertControllerWithTitle:@"Disclaimer"
                                                                                  message:disclaimer
                                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
    [disclaimerController addAction:doneAction];
    [self presentViewController:disclaimerController animated:YES completion:nil];
}

- (IBAction)rateAppClicked:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id945847570"]];
}

- (IBAction)showDetailedForecastInfoChanged:(id)sender {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults setBool:[sender isOn] forKey:@"ShowDetailedForecastInfo"];
    [defaults synchronize];
}

- (void) fetchInAppPurchaseProducts {
    NSSet *productIds = [NSSet setWithObjects:@"small_user_tip", @"medium_user_tip", @"large_user_tip", nil];
    SKProductsRequest *inAppPurchaseRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    inAppPurchaseRequest.delegate = self;
    [inAppPurchaseRequest start];
}

- (BOOL) canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

- (void) purchaseProduct:(SKProduct*)product {
    if (![self canMakePurchases]) {
        return;
    } else if (product == nil) {
        return;
    }
    
    SKPayment* payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductDelegate

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing in-app purchase...");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Successfully purchased in-app purchase!");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Purchase successfully restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Failed to make in-app purchase");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.inAppProducts = response.products;
}

@end
