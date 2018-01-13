//
//  MeetingFormViewController.h
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//


#import "ContactsTableController.h"
#import "VeeContactPickerViewController.h"
#import "VenueSelectionView.h"
#import "WWCalendarTimeSelector-Swift.h"
#import "departmentTableCell.h"
#import "MeetingFormCollectionViewCell.h"
#import "MeetingTimeCollectionViewCell.h"


@interface MeetingFormViewController : ViewController<UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WWCalendarTimeSelectorProtocol,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,VeeContactPickerDelegate,VenueSelectionViewDelegate,ContactsTableControllerDelegate,MeetingTimeCollectionViewCellDelegate,MeetingFormCollectionViewCellDelegate>
{
    NSString *locationName;
    Database *db;
    NSDate *nextday;
    NSString *month;
    NSString *date;
    NSString *day;
    
    int btnTag;
    
    WWCalendarTimeSelector *dateSel;
    
    BOOL isSelectedDate;
    BOOL isSelectedTime;
    
    NSString *selectedDate;
    
    NSDate *initialDate;
    
    int seletedTag;
    
    BOOL isCurrentWeek;
    
    BOOL indexZeroDisable;
    
    NSArray *arrTiming;
    
    NSMutableArray *arrBooked;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewDates;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewTimes;
@property (strong, nonatomic) IBOutlet UIView *confirmationView;
- (IBAction)btnConfirmDidTap:(id)sender;
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

- (IBAction)btnAddContactDidTap:(id)sender;

@property NSArray *departmentsArr;


@end
