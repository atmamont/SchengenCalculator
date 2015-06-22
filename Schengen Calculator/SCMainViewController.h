//
//  ViewController.h
//  Schengen Calculator
//
//  Created by Vit on 20.06.15.
//  Copyright (c) 2015 ELTIMA LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainVisaCalc.h"

@interface SCMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tripsTableView;
@property (strong, nonatomic) MainVisaCalc *calc;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

- (void)saveTripsData;

@end

