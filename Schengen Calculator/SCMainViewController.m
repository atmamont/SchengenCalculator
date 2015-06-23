//
//  ViewController.m
//  Schengen Calculator
//
//  Created by Vit on 20.06.15.
//  Copyright (c) 2015 ELTIMA LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCMainViewController.h"
#import "SCTripsTableViewCell.h"
#import "SCTripViewController.h"
#import "UICountingLabel.h"

#define ANIMATION_DURATION  1.0f

@interface SCMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *entryDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *entryDateButton;
@property (weak, nonatomic) IBOutlet UICountingLabel *daysCounter;
@property (weak, nonatomic) IBOutlet UILabel *underCountLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *entryDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation SCMainViewController

BOOL    _isShowingDatePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Setup NavigationBar colors
    UIColor *barColor = [UIColor colorWithRed:0.039 green:0.29 blue:0.643 alpha:1];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = barColor;
        self.navigationController.navigationBar.translucent = NO;
    }else {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = barColor;
    }
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    // Setup borders around label and button for entry date
    [[self.entryDateLabel layer] setBorderWidth:1.0f];
    [[self.entryDateLabel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.entryDateButton layer] setBorderWidth:1.0f];
    [[self.entryDateButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    
    _isShowingDatePicker = NO;
    self.entryDatePicker.minimumDate = [NSDate date];
    [self.entryDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
       
    // add UIRefreshView
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tripsTableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self action:@selector(addNewTrip:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    [self loadTripsData];
    
    self.daysCounter.format = @"%d%";
    self.daysCounter.method = UILabelCountingMethodLinear;
    [self.daysCounter countFrom:90 to:90];
    [self updateDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tripsTableView reloadData];
    [self updateDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}
- (MainVisaCalc *)calc {
    if (!_calc) _calc = [[MainVisaCalc alloc] init];
    return _calc;
}

- (IBAction)dateButtonPress:(id)sender {
    
    if (!_isShowingDatePicker) {
        [UIView animateWithDuration:0.3f animations:^{
            [self.daysCounter setAlpha:0.0f];
            [self.underCountLabel setAlpha:0.0f];
            [self.infoLabel setAlpha:0.0f];
            [self.entryDatePicker setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [self.entryDatePicker setDate:[self.dateFormatter dateFromString:self.entryDateButton.titleLabel.text]];
            [self.entryDateButton setTitle:@"Set" forState: UIControlStateNormal];
            _isShowingDatePicker = YES;
        }];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            [self.daysCounter setAlpha:1.0f];
            [self.underCountLabel setAlpha:1.0f];
            [self.infoLabel setAlpha:1.0f];
            [self.entryDatePicker setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.entryDateButton setTitle:[self.dateFormatter stringFromDate:self.entryDatePicker.date] forState:UIControlStateNormal];
            _isShowingDatePicker = NO;
            self.calc.entryDate = self.entryDatePicker.date;
            [self updateDisplay];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SCTripsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tripCell"];
    if (cell == nil) cell = [[SCTripsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tripCell"];
    
    Trip *trip = [self.calc.trips objectAtIndex:indexPath.row];
    
    cell.dateInLabel.text = [self.dateFormatter stringFromDate:trip.startDate];
    cell.descriptionLabel.text = trip.name;
    if (trip.endDate != nil)
    {
        cell.dateOutLabel.text = [self.dateFormatter stringFromDate:trip.endDate];
        cell.daysCountLabel.text = [NSString stringWithFormat:@"%ld",[trip getTripDurationBetweenDates:trip.startDate and:trip.endDate]];
    }
    else
    {
        cell.dateOutLabel.text = @"In process";
        cell.daysCountLabel.text = [NSString stringWithFormat:@"%ld",[trip getTripDurationBetweenDates:trip.startDate and:[NSDate date]]];
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.calc.trips count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.calc.trips removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self saveTripsData];
        
        [self updateDisplay];
    }
}

- (void)addNewTrip:(UIRefreshControl *)controller {
    [self performSegueWithIdentifier:@"addTrip" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"addTrip" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SCTripViewController *nextScreen = [segue destinationViewController];
    nextScreen.mainViewController = self;
}

- (void)saveTripsData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.calc.trips.count == 0)
    {
        [userDefaults removeObjectForKey:@"Trips"];
    }
    else
    {
        NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:self.calc.trips.count];
        for (Trip *trip in self.calc.trips)
        {
            NSData *tripEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:trip];
            [archiveArray addObject:tripEncodedObject];
            
            [userDefaults setObject:archiveArray forKey:@"Trips"];
        }
    }
    [userDefaults synchronize];
}

- (void)loadTripsData
{
    NSArray *archiveArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Trips"];
    if (archiveArray != nil)
    {
        for (NSData *trip in archiveArray)
        {
            Trip  *unarchivedTrip = [NSKeyedUnarchiver unarchiveObjectWithData:trip];
            if (unarchivedTrip != nil) [self.calc addTrip:unarchivedTrip.startDate and:unarchivedTrip.endDate named:unarchivedTrip.name];
        }
    }
}

- (void)updateDisplay {
    [self.daysCounter countFromCurrentValueTo:self.calc.getTotalRemainingDays withDuration: ANIMATION_DURATION];
    
    if ([self.calc hasTripInProcess]) {
        NSDate *today = [NSDate date];
        self.infoLabel.text = [NSString stringWithFormat:@"latest possible departure date is %@", [self.dateFormatter stringFromDate:[today dateByAddingTimeInterval:60*60*24*self.calc.getTotalRemainingDays]]];
    } else {
        self.infoLabel.text = @"";
    }
}

@end
