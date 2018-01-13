//
//  FlexibleMeetingFormViewController.h
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ContactsTableController.h"
#import "WWCalendarTimeSelector-Swift.h"
#import "VeeContactPickerViewController.h"
#import "VenueSelectionView.h"
#import "departmentTableCell.h"
#import "MeetingFormCollectionViewCell.h"
#import "MeetingTimeCollectionViewCell.h"


@interface FlexibleMeetingFormViewController : ViewController<UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WWCalendarTimeSelectorProtocol,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,VeeContactPickerDelegate,VenueSelectionViewDelegate,ContactsTableControllerDelegate,MeetingTimeCollectionViewCellDelegate,MeetingFormCollectionViewCellDelegate>
{
    NSString *locationName;
    Database *db;
    NSDate *nextday;
    NSString *month;
    NSString *date;
    NSString *day;
    
    WWCalendarTimeSelector *dateSel;
    
    NSString *selectedDate;
    
    NSDate *initialDate;
    
    int btnTag;
    
    BOOL isSelectedDate;
    BOOL isSelectedTime;
    
    BOOL isCurrentWeek;
    
    int seletedTag1;
    int seletedTag2;
    
    NSArray *arrTiming;
    
    NSMutableArray *arrBooked;
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewDates;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewTimes;
- (IBAction)btnConfirmDidTap:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *confirmationView;
- (IBAction)btnConfirmedOkDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *confirmMeetingView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
- (IBAction)btnDrawerMenuDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldAgenda;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingDateTime;

@property (weak, nonatomic) IBOutlet UILabel *lblDay1;
@property (weak, nonatomic) IBOutlet UILabel *lblMonth1;
@property (weak, nonatomic) IBOutlet UILabel *lblYear1;

@property (weak, nonatomic) IBOutlet UILabel *lblDay2;
@property (weak, nonatomic) IBOutlet UILabel *lblMonth2;
@property (weak, nonatomic) IBOutlet UILabel *lblYear2;

@property (weak, nonatomic) IBOutlet UILabel *lblMeetingWith;
@property (weak, nonatomic) IBOutlet UITextField *txtDepartmentName;

@property (weak, nonatomic) IBOutlet UITableView *tblDepartments;

- (IBAction)btnAddContactDidTap:(id)sender;

@property NSArray *departmentsArr;
@property (weak, nonatomic) IBOutlet UILabel *lblMeetingVenue;
- (IBAction)btnSelectVenueDidTap:(id)sender;

@end
