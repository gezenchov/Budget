//
//  PTGExpensesTableViewController.m
//  Budget
//
//  Created by Petar Gezenchov on 19/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGExpensesTableViewController.h"
#import "PTGExpenseCell.h"

@interface PTGExpensesTableViewController () <UITableViewDataSource>

@end

@implementation PTGExpensesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSegueWithIdentifier:@"AddExpenseSegue" sender:nil];
}

- (IBAction)addButtonPressed:(id)sender {
    NSLog(@"Add");
    
    [self performSegueWithIdentifier:@"AddExpenseSegue" sender:nil];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0.0f;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.0f;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == AmountTextField) {
//        return (self.keyboardControls.activeField.tag == indexPath.row) ? kAmountActiveRowHegiht : kAmountInactiveRowHegiht;
//    }
//    else {
//        return (self.keyboardControls.activeField.tag == indexPath.row) ? kTextActiveRowHeignt : kTextInactiveRowHeignt;
//    }
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *emailTableIdentifier = @"ExpenseCell";
    
    PTGExpenseCell *cell = (PTGExpenseCell *)[tableView dequeueReusableCellWithIdentifier:emailTableIdentifier];
    
    if (cell == nil) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ExpenseCell" owner:self options:nil];
        
        cell = [nibArray objectAtIndex:0];
    }
    
    cell.amountLabel.text = @"1";
    cell.descriptionLabel.text = @"avtomivka";
    cell.typeLabel.text = @"lichni";
    
    return cell;
}

@end
