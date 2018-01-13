//
//  LoginViewController.h
//  SmartOffice
//
//  Created by FNSPL on 17/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMaterialTextfield.h"
#import "ForgotPassViewController.h"
#import "ZFCheckbox.h"
#import "Constants.h"
#import "SystemServices.h"
#import "Database.h"
#import "ViewController.h"
#import "departmentTableCell.h"

#define SystemSharedServices [SystemServices sharedServices]

@interface LoginViewController : ViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,ForgotPassViewControllerDelegate>
{
    UIAlertController *alertController;
    BOOL isUserName;
    int totalHeight;
    NSString *host_url;
    NSMutableArray *arrDepartMents;
    Database *db;
    
    ForgotPassViewController *forgotPassVC;
}
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldUsername;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *txtFieldPassword;
@property (weak, nonatomic) IBOutlet ZFCheckbox *checkBox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginOutlet;

@property (weak, nonatomic) IBOutlet UIButton *btnForgotPasswordOutlet;

- (IBAction)btnForgotPasswordDidTap:(id)sender;
- (IBAction)btnLoginDidTap:(id)sender;
- (IBAction)btnCheckBoxDidTap:(id)sender;
- (IBAction)btnSignUpDidTap:(id)sender;

@end
