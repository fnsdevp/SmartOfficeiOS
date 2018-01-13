//
//  EmployeeMeetingsDetailsViewController.h
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeMeetingsDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UILabel *lblAgenda;
- (IBAction)btnMenuDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingType;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTiming;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthYear;

@property NSDictionary *meetingDetailsDictionary;

@end
