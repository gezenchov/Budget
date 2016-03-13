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
#import "PTGExpensesSectionCell.h"
#import "Expense.h"
#import "Type.h"

#import <CoreData/CoreData.h>

typedef enum : NSUInteger {
    ExpensesCellSection,
    ExpensesCellTotal,
} ExpensesCell;


@interface PTGExpensesTableViewController () <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PTGExpensesTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeFetchedResultsController];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self performSegueWithIdentifier:@"AddExpenseSegue" sender:nil];
}

#pragma mark - Private methods

- (void)initializeFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expense"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"dayTitle" ascending:YES];
    
    
    NSSortDescriptor *dateSort1 = [NSSortDescriptor sortDescriptorWithKey:@"amount" ascending:YES];
    
    [request setSortDescriptors:@[dateSort, dateSort1]];
    
    NSManagedObjectContext *moc = [PTGApplicationManager sharedManager].coreDataManager.masterManagedObjectContext; //Retrieve the main queue NSManagedObjectContext
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:@"dayTitle" cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 40.0f;
    }
    
    return 50.0f;
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return indexPath.row != 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [[PTGApplicationManager sharedManager].coreDataManager.masterManagedObjectContext deleteObject:[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]]];
        
        [[PTGApplicationManager sharedManager].coreDataManager save];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects] + ExpensesCellTotal;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == ExpensesCellSection) {
        static NSString *emailTableIdentifier = @"ExpensesSectionCell";
        
        PTGExpensesSectionCell *cell = (PTGExpensesSectionCell *)[tableView dequeueReusableCellWithIdentifier:emailTableIdentifier];
        
        if (cell == nil) {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ExpensesSectionCell" owner:self options:nil];
            
            cell = [nibArray objectAtIndex:0];
        }
        
        
        Expense *expense = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSArray *expensesInSection = [[self fetchedResultsController].sections[indexPath.section] objects];
        
        
        [cell setupWithDate:expense.dayTitle total:[expensesInSection valueForKeyPath:@"@sum.amount"]];
        
        return cell;
    }
    else {
        static NSString *emailTableIdentifier = @"ExpenseCell";
        
        PTGExpenseCell *cell = (PTGExpenseCell *)[tableView dequeueReusableCellWithIdentifier:emailTableIdentifier];
        
        if (cell == nil) {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ExpenseCell" owner:self options:nil];
            
            cell = [nibArray objectAtIndex:0];
        }
        
        NSIndexPath *offsetIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        Expense *expense = [[self fetchedResultsController] objectAtIndexPath:offsetIndexPath];
        
        [cell setupWithExpense:expense];
        
        return cell;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSInteger section = indexPath ? indexPath.section : newIndexPath.section;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
//            if (indexPath.row == ExpensesCellSection) {
                [[self tableView] cellForRowAtIndexPath:indexPath];
//                tet
////                [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            }
//            else {
////                [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            }
            
        }
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

#pragma mark - Action methods

- (IBAction)addButtonPressed:(id)sender {
    NSLog(@"Add");
    
    [self performSegueWithIdentifier:@"AddExpenseSegue" sender:nil];
}

@end
