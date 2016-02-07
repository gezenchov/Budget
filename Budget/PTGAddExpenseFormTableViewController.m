//
//  PTGAddExpenseTableViewController.m
//  Budget
//
//  Created by Petar Gezenchov on 07/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGAddExpenseFormTableViewController.h"
#import "BSKeyboardControls.h"

typedef enum : NSUInteger {
    AmountTextField,
    DescriptionTextField,
    TypeTextField,
    DateTextField
} TextFields;

@interface PTGAddExpenseFormTableViewController () <UITextFieldDelegate, BSKeyboardControlsDelegate>

@property (nonatomic, weak) IBOutlet UITextField *amountTextField;
@property (nonatomic, weak) IBOutlet UITextField *descriptionTextField;
@property (nonatomic, weak) IBOutlet UITextField *typeTextField;
@property (nonatomic, weak) IBOutlet UITextField *dateTextField;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end


@implementation PTGAddExpenseFormTableViewController

static CGFloat kAmountActiveRowHegiht = 150.0f;
static CGFloat kAmountInactiveRowHegiht = 100.0f;

static CGFloat kTextActiveRowHeignt = 100.0f;
static CGFloat kTextInactiveRowHeignt = 80.0f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *fields = @[ self.amountTextField, self.descriptionTextField, self.typeTextField, self.dateTextField];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    [self.amountTextField becomeFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == AmountTextField) {
        return (self.keyboardControls.activeField.tag == indexPath.row) ? kAmountActiveRowHegiht : kAmountInactiveRowHegiht;
    }
    else {
        return (self.keyboardControls.activeField.tag == indexPath.row) ? kTextActiveRowHeignt : kTextInactiveRowHeignt;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField.tag == AmountTextField ? [self isValidFloatString:[textField.text stringByReplacingCharactersInRange:range withString:string]] : YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == DateTextField) {
        [self.view endEditing:YES];
        [self.delegate didSelectDatePickerField:YES];
    }
    else {
        [self.delegate didSelectDatePickerField:NO];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    return YES;
}

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view = keyboardControls.activeField.superview.superview;
    [self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
    [self.delegate doneEnteringData];
}

- (BOOL)isValidFloatString:(NSString *)str
{
    const char *s = str.UTF8String;
    char *end;
    strtod(s, &end);
    return !end[0];
}


- (void)updateDateTextFieldWithValue:(NSDate*)date {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd LLLL yyyy"];
    NSString *formattedDate = [df stringFromDate:date];
    
    self.dateTextField.text = formattedDate;
}

@end
