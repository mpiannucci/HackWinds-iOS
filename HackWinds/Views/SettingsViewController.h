//
//  SettingsViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 2/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface SettingsViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (void) loadSettings;

- (IBAction)acceptSettingsClick:(id)sender;
- (IBAction)leaveTipClicked:(id)sender;
- (IBAction)contactDevClicked:(id)sender;
- (IBAction)showDisclaimerClicked:(id)sender;
- (IBAction)rateAppClicked:(id)sender;
- (IBAction)showDetailedForecastInfoChanged:(id)sender;

- (void) fetchInAppPurchaseProducts;
- (BOOL) canMakePurchases;
- (void) purchaseProduct:(SKProduct*)product;

@end
