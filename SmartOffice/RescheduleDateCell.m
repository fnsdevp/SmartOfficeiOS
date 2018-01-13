//
//  RescheduleDateCell.m
//  SmartOffice
//
//  Created by FNSPL on 16/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "RescheduleDateCell.h"

@implementation RescheduleDateCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self prepareForReuse];
}
    
- (void)prepareForReuse {
    
    self.lblday.text = nil;
    self.lblDate.text = nil;
    self.lblMonth.text = nil;
    self.imgBg.image = nil;
    
    [super prepareForReuse];
}
    
- (IBAction)actionBtnDate:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(dateCellTap:)]) {
        
        [self.delegate dateCellTap:self];
    }
    
}

@end
