//
//  PTGExpensesTableViewController.m
//  Budget
//
//  Created by Petar Gezenchov on 19/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGExpensesTableViewController.h"
#import "PTGApplicationManager.h"
#import "PTGExpenseCell.h"

#import <CoreData/CoreData.h>


@interface PTGExpensesTableViewController () <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PTGExpensesTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSegueWithIdentifier:@"AddExpenseSegue" sender:nil];
}

#pragma mark - Private methods

- (void)initializeFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    
    NSSortDescriptor *lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    
    [request setSortDescriptors:@[lastNameSort]];
    
    NSManagedObjectContext *moc = [PTGApplicationManager sharedManager].coreDataManager.masterManagedObjectContext; //Retrieve the main queue NSManagedObjectContext
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
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


#pragma mark - Action methods

- (IBAction)addButtonPressed:(id)sender {
    NSLog(@"Add");
    
    [self performSegueWithIdentifier:@"AddExpenseSegue" sender:nil];
}

@end
