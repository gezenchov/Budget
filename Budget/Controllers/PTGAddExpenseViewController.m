//
//  PTGAddExpenseViewController.m
//  Budget
//
//  Created by Petar Gezenchov on 07/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGAddExpenseViewController.h"
#import "PTGAddExpenseFormTableViewController.h"
#import "Expense.h"
#import "Type.h"


@interface PTGAddExpenseViewController () <AddExpenseFormProtocol>

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) PTGAddExpenseFormTableViewController *formVC;

@end

@implementation PTGAddExpenseViewController

#pragma mark - View Life Cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateDateTextFieldWithDate:self.datePicker.date];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"AddExpenseSegue"]) {
        self.formVC = (PTGAddExpenseFormTableViewController *) [segue destinationViewController];
        self.formVC.delegate = self;
    }
}


#pragma mark - AddExpenseFormProtocol methods

- (void)didSelectDatePickerField:(BOOL)selected {
    self.datePicker.hidden = !selected;
}

- (void)doneEnteringData {
    [self addRecord];
}

#pragma mark - Private methods

- (void)updateDateTextFieldWithDate:(NSDate*)date {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd LLLL yyyy"];
    NSString *formattedDate = [df stringFromDate:date];
    
    self.formVC.dateTextField.text = formattedDate;
}

- (void)addRecord {
    NSLog(@"%@", self.datePicker.date);
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                    fromDate:self.datePicker.date];
    [components setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *startDate = [[NSCalendar currentCalendar]
                         dateFromComponents:components];
    
    Type *type = [Type createTypeWithTitle:self.formVC.typeTextField.text];
    [Expense createExpenseWithAmount:@(self.formVC.amountTextField.text.doubleValue) description:self.formVC.descriptionTextField.text type:type date:startDate];
    
    [self close];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction methods

- (IBAction)addButtonPressed:(id)sender {
    [self addRecord];
    [self close];
}

- (IBAction)datePickerValueChanged:(id)sender {
    [self updateDateTextFieldWithDate:self.datePicker.date];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self close];
}

@end