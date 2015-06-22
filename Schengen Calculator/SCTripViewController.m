//
//  SCTripViewController.m
//  Schengen Calculator
//
//  Created by Vit on 22.06.15.
//  Copyright (c) 2015 ELTIMA LLC. All rights reserved.
//

#import "SCTripViewController.h"

@interface SCTripViewController ()

@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *entryDateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *departureDateCell;
@property (weak, nonatomic) IBOutlet UISwitch *tripSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *entryDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *departureDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *entryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *departureDateLabel;
@property (strong, nonatomic) IBOutlet UITableView *tripDetailsTableView;
@property (weak, nonatomic) IBOutlet UILabel *departureDateTitleLabel;

@end

@implementation SCTripViewController

BOOL _entryDatePickerIsShown, _departureDatePickerIsShown;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _entryDatePickerIsShown = NO;
    _departureDatePickerIsShown = NO;
    
    if (!self.mainViewController.refreshControl.refreshing) {
        self.navigationItem.title = @"Edit trip";
        NSIndexPath *path = [self.mainViewController.tripsTableView indexPathForSelectedRow];
        Trip *selectedTrip = [self.mainViewController.calc.trips objectAtIndex:path.row];
        
        self.descriptionTextField.text = selectedTrip.name;
        self.entryDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:selectedTrip.startDate];
        if (selectedTrip.endDate != nil) {
            self.departureDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:selectedTrip.endDate];
        }
        else {
            // trip in process
            self.tripSwitch.on = YES;
            self.departureDateLabel.text = @"";
            self.departureDateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.departureDateCell.userInteractionEnabled = NO;
        }
    } else {
        // creating new trip
        self.navigationItem.title = @"Add trip";
        self.entryDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:self.entryDatePicker.date];
        self.departureDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:self.departureDatePicker.date];
        self.tripSwitch.on = NO;
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;  // this prevents the gesture recognizers to 'block' touches
    
    self.descriptionTextField.delegate = self;
}

- (void)hideKeyboard {
    [self.descriptionTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonClick:(id)sender {
    if (self.mainViewController.refreshControl.refreshing)
        [self.mainViewController.refreshControl endRefreshing];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)doneButtonClick:(id)sender {
    if (!self.mainViewController.refreshControl.refreshing) {
        // edit current trip
        NSIndexPath *path = [self.mainViewController.tripsTableView indexPathForSelectedRow];
        Trip *selectedTrip = [self.mainViewController.calc.trips objectAtIndex:path.row];
        
        selectedTrip.startDate = [self.mainViewController.dateFormatter dateFromString:self.entryDateLabel.text];
        if (!self.tripSwitch.isOn)
            selectedTrip.endDate = [self.mainViewController.dateFormatter dateFromString:self.departureDateLabel.text];
        else selectedTrip.endDate = nil;
        selectedTrip.name = self.descriptionTextField.text;
    } else {    // create and add new trip
        NSDate *departureDate = self.tripSwitch.isOn ? nil : [self.mainViewController.dateFormatter dateFromString:self.departureDateLabel.text];
        [self.mainViewController.calc addTrip:[self.mainViewController.dateFormatter dateFromString:self.entryDateLabel.text] and:departureDate named:self.descriptionTextField.text];
        [self.mainViewController.refreshControl endRefreshing];
    }
    
    [self.mainViewController saveTripsData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // This is the index path of the date picker cell in the static table
    if (indexPath.section == 1 && indexPath.row == 1 && !_entryDatePickerIsShown) return 0;
    if (indexPath.section == 1 && indexPath.row == 4 && !_departureDatePickerIsShown) return 0;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView beginUpdates];
    if (cell == self.entryDateCell) {
        if (_departureDatePickerIsShown) _departureDatePickerIsShown = NO;
        _entryDatePickerIsShown = !_entryDatePickerIsShown;
        if (!self.tripSwitch.isOn) self.entryDatePicker.maximumDate = self.departureDatePicker.date;
    }
    if (cell == self.departureDateCell) {
        if (_entryDatePickerIsShown) _entryDatePickerIsShown = NO;
        _departureDatePickerIsShown = !_departureDatePickerIsShown;
        self.departureDatePicker.minimumDate = self.entryDatePicker.date;
    }
    [self.tableView endUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)entryDateChanged:(id)sender {
    self.entryDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:self.entryDatePicker.date];
    self.departureDatePicker.minimumDate = self.entryDatePicker.date;
}

- (IBAction)departureDateChanged:(id)sender {
    self.departureDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:self.departureDatePicker.date];
    self.entryDatePicker.maximumDate = self.departureDatePicker.date;
}

- (IBAction)switchClick:(id)sender {
    [self.tripDetailsTableView beginUpdates];
    if (self.tripSwitch.isOn) {
        _departureDatePickerIsShown = NO;
        self.departureDateLabel.text = @"";
        self.departureDateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.departureDateCell.userInteractionEnabled = NO;
        self.departureDateTitleLabel.textColor = [UIColor lightGrayColor];
        self.entryDatePicker.maximumDate = nil;
    } else {
        _entryDatePickerIsShown = NO;
        _departureDatePickerIsShown = YES;
        self.departureDateLabel.text = [self.mainViewController.dateFormatter stringFromDate:self.departureDatePicker.date];
        self.departureDateCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.departureDateCell.userInteractionEnabled = YES;
        self.departureDateTitleLabel.textColor = [UIColor blackColor];
        self.departureDatePicker.minimumDate = self.entryDatePicker.date;
    }
    [self.tripDetailsTableView endUpdates];
}

// limit the input length of description textfield
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 20) ? NO : YES;
}

@end
