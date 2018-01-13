//
//  ManageMeetingsDetailsViewController.h
//  SmartOffice
//
//  Created by FNSPL on 23/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "CustomTabBarController.h"
#import "CommentTableCell.h"
#import "RescheduleView.h"
#import "WWCalendarTimeSelector-Swift.h"
#import <GoogleMaps/GoogleMaps.h>

#define FEET_TO_METERS 0.3048

@class CustomTabBarController;

@interface ManageMeetingsDetailsViewController : ViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,RescheduleViewDelegate,WWCalendarTimeSelectorProtocol>
{
    UIView *pickerVw;
    
    CGFloat x;

    NSString *locationName;
    NSString *date;
    
    CGFloat Height,Width;
    
    NSString *fromTime;
    NSString *toTime;
    NSString *DuraTion;
    NSString *fDateSel;
    NSString *appointmentID;
    
    WWCalendarTimeSelector *dateSel;
    
    NSString *selectedDate;
    
    NSDate *initialDate;
    
    NSString *fdate;
    NSString *sdate;
    
    NSString *sDateSel;
    
    int seletedTag;
    
    BOOL isSelectedDate;
    BOOL isSelectedTime;
    
    BOOL isAddressFetch;
    
    BOOL isConfirmBtn;
    BOOL isCancelBtn;
    BOOL isEndBtn;
    BOOL isResceduleBtn;
    BOOL isCallBtn;
    BOOL isMapBtn;
    BOOL isNavigationBtn;
    
    //NSString *strAddress;
    
    RescheduleView *objReschedule;
    
    Database *db;
    
    
    NSString *savedEventId;
    
    CLLocation *cLoc;
    
    NSString *SourceAddress;
    
    NSString *DestinationAddress;
    
    CustomTabBarController *tabbar;
    
    NSMutableArray *commentsArray;
    
    UIDatePicker *datepicker;
}

@property (weak, nonatomic) IBOutlet UIView *statusVw;
@property (weak, nonatomic) IBOutlet UIView *etaVw;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (weak, nonatomic) IBOutlet UILabel *lblAgenda;
- (IBAction)btnMenuDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingType;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTiming;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthYear;
@property (weak, nonatomic) IBOutlet UILabel *lbldistance;
@property (weak, nonatomic) IBOutlet UILabel *lblduration;
@property NSDictionary *meetingDetailsDictionary;

@property (weak, nonatomic) IBOutlet UIImageView *calenderImage;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveToCalenderOutlet;

@property (nonatomic, assign) BOOL isRequest;
@property (atomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIImageView *confirmedImage;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirmedMeetingOutlet;
    @property (weak, nonatomic) IBOutlet UIImageView *endImage;
@property (weak, nonatomic) IBOutlet UIButton *btnEndMeetingOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *cancelImage;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelMeetingOutlet;

@property (weak, nonatomic) IBOutlet UITextField *txtPost;
@property (weak, nonatomic) IBOutlet UIButton *btnPostCommentOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;

@end
