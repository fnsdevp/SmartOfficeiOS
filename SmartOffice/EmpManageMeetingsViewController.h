//
//  EmpManageMeetingsViewController.h
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmpManageMeetingsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

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
@property (weak, nonatomic) IBOutlet UITextField *txtFieldSearch;

@end
