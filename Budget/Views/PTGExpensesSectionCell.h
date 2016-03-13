//
//  PTGExpensesSectionCell.h
//  Budget
//
//  Created by Petar Gezenchov on 13/03/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTGExpensesSectionCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalLabel;

- (void)setupWithDate:(NSString*)date total:(NSNumber*)total;

@end
