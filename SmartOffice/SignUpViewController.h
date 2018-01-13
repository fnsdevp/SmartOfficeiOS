//
//  SignUpViewController.h
//  SmartOffice
//
//  Created by FNSPL on 18/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMaterialTextfield.h"
#import "Constants.h"
#import "SystemServices.h"
#import "ViewController.h"
#import "departmentTableCell.h"

#define SystemSharedServices [SystemServices sharedServices]

@interface SignUpViewController : ViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIAlertController *alertController;
    NSMutableArray *arrDepartMents;
    NSString *host_url;
}
@property (weak, nonatomic) IBOutlet UIButton *btnSignUpOutlet;

- (IBAction)userTypeChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnDepartments;
@property (strong, nonatomic) UITableView *tblDepartments;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *employeeDetailsView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userSelectionSegControl;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldUsername;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldPassword;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldFirstName;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldLastName;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldEmail;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldPhone;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldDepartment;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldDesignation;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldCompany;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnSignUpTop;

- (IBAction)btnLoginDidTap:(id)sender;
- (IBAction)btnCheckBoxDidTap:(id)sender;
- (IBAction)btnSignUpDidTap:(id)sender;

@end
