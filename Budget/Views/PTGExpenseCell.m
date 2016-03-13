//
//  PTGExpenseCell.m
//  Budget
//
//  Created by Petar Gezenchov on 20/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGExpenseCell.h"
#import "Expense.h"
#import "Type.h"

@implementation PTGExpenseCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupWithExpense:(Expense*)expense {
    self.amountLabel.text = expense.amount.stringValue;
    self.descriptionLabel.text = expense.descriptionText;
    self.typeLabel.text = expense.type.title;
}

@end
