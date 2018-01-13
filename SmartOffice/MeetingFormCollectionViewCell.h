//
//  MeetingFormCollectionViewCell.h
//  SmartOffice
//
//  Created by FNSPL on 20/07/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeetingFormCollectionViewCellDelegate <NSObject>

@optional
- (void)dateCellTap:(id)sender;

@end

@interface MeetingFormCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblday;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMonth;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
@property (weak, nonatomic) IBOutlet UIView *backVW;

@property (weak, nonatomic) id<MeetingFormCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnDate;

- (IBAction)actionBtnDate:(id)sender;

@end
