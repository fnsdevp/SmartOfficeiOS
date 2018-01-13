//
//  MessagesTableViewCell.h
//  SmartOffice
//
//  Created by FNSPL on 11/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *nameVw;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *monthYrLabel;


@end
