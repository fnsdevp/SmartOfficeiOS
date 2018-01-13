//
//  ManageMeetingsTableViewCell.h
//  SmartOffice
//
//  Created by FNSPL on 13/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

@interface ManageMeetingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnCalender;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnMail_Message;
@property (weak, nonatomic) IBOutlet UIImageView *imgMail_Message;
@property (weak, nonatomic) IBOutlet UIButton *btnStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenDirections;
@property (weak, nonatomic) IBOutlet UIImageView *imgDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblDay;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthYear;
@property (weak, nonatomic) IBOutlet UILabel *lblOTP;
@property (weak, nonatomic) IBOutlet UILabel *lblCancelled;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmed;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *communicationOptions;

@end
