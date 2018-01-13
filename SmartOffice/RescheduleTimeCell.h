//
//  RescheduleTimeCell.h
//  SmartOffice
//
//  Created by FNSPL on 10/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RescheduleTimeCellDelegate <NSObject>

@optional
- (void)cellTap:(id)sender;

@end

@interface RescheduleTimeCell : UICollectionViewCell

@property (weak, nonatomic) id<RescheduleTimeCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;

- (IBAction)actionBtnTime:(id)sender;


@end
