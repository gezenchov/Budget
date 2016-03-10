//
//  PTGExpenseCell.h
//  Budget
//
//  Created by Petar Gezenchov on 20/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTGExpenseCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;

@end
