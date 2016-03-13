//
//  PTGExpensesSectionCell.m
//  Budget
//
//  Created by Petar Gezenchov on 13/03/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGExpensesSectionCell.h"

@implementation PTGExpensesSectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithDate:(NSString*)date total:(NSNumber*)total {
    self.dateLabel.text = date;
    self.totalLabel.text = total.stringValue;
}

@end