//
//  ViewController.m
//  Budget
//
//  Created by Petar Gezenchov on 07/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGAddExpenseViewController.h"
#import "PTGAddExpenseFormTableViewController.h"

@interface PTGAddExpenseViewController () <AddExpenseFormProtocol>

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) PTGAddExpenseFormTableViewController *formVC;

@end

@implementation PTGAddExpenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.formVC updateDateTextFieldWithValue:self.datePicker.date];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"AddExpenseSegue"]) {
        self.formVC = (PTGAddExpenseFormTableViewController *) [segue destinationViewController];
        self.formVC.delegate = self;
    }
}

- (void)didSelectDatePickerField:(BOOL)selected {
    self.datePicker.hidden = !selected;
}

- (void)addRecord {
    NSLog(@"%@", self.datePicker.date);
}

- (IBAction)addButtonPressed:(id)sender {
    [self addRecord];
}

- (IBAction)datePickerValueChanged:(id)sender {
    [self.formVC updateDateTextFieldWithValue:self.datePicker.date];
}

@end