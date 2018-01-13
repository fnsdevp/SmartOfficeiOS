//
//  RescheduleTimeCell.m
//  SmartOffice
//
//  Created by FNSPL on 10/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "RescheduleTimeCell.h"

@implementation RescheduleTimeCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.btnTime.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnTime.layer.borderWidth = 2.0;
    
}

- (IBAction)actionBtnTime:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(cellTap:)]) {
        
        [self.delegate cellTap:self];
    }
    
}

@end
