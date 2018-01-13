//
//  EmployeeManageMeetingsTableViewCell.h
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeManageMeetingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *pendingView;
@property (weak, nonatomic) IBOutlet UIView *confirm_cancel_View;


@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnMail_Message;

@property (weak, nonatomic) IBOutlet UILabel *lblDay;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthYear;
@property (weak, nonatomic) IBOutlet UILabel *lblCancelled;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirmDidTap;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelPendingDidTap;
@property (weak, nonatomic) IBOutlet UIButton *btnRescheduleDidTap;

@end
