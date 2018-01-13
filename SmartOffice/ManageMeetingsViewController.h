//
//  ManageMeetingsViewController.h
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "CustomTabBarController.h"

@interface ManageMeetingsViewController : ViewController<MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,RescheduleViewDelegate>
{
    BOOL isRequest;
    int cellHeight;
    
    BOOL isSearch;
    UIView *pickerVw;
    
    NSString *locationForMap;
    
    Database *db;
    CustomTabBarController *tabbar;
    
    NSString *locationName;
    NSString *date;
    
    NSArray *idArr;
    NSArray *PassArr;
    
    NSString *savedEventId;
    UILabel *noMeetingLabel;
    UIDatePicker *datepicker;
}
- (IBAction)btnDrawerMenuDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMeetings;
- (IBAction)btnAllDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAllOutlet;
- (IBAction)btnPendingDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPendingOutlet;
- (IBAction)btnConfirmedMeetingsDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirmedMeetingsOutlet;
- (IBAction)searchTextFieldTextDidChange:(id)sender;

- (IBAction)btnCancelDidTap:(id)sender;

- (IBAction)btnAdvancedSearchDidTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet UITextField *txtFieldSearch;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollTopVw;

@property (weak, nonatomic) IBOutlet UISegmentedControl * segmentedControl;

@end
