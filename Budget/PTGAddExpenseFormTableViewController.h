//
//  PTGAddExpenseTableViewController.h
//  Budget
//
//  Created by Petar Gezenchov on 07/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddExpenseFormProtocol <NSObject>

- (void)didSelectDatePickerField:(BOOL)selected;
- (void)doneEnteringData;

@end

@interface PTGAddExpenseFormTableViewController : UITableViewController

@property (nonatomic, weak) id<AddExpenseFormProtocol> delegate;

- (void)updateDateTextFieldWithValue:(NSDate*)date;

@end
