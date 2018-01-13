//
//  SignUpViewController.m
//  SmartOffice
//
//  Created by FNSPL on 18/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "SignUpViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "Constants.h"

@interface SignUpViewController (){
    
    bool isEmployee;
    NSString *userType;
    UIBarButtonItem *previousButton,*flexBarButton,*nextButton,*doneButton;
    UIToolbar *keyboardDoneButtonView;
    CGFloat keyboardHeight;
    UITextField *activeTextField;
    CGFloat doneKeyboardHeight;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _txtFieldDepartment.hidden = YES;
    _btnSignUpOutlet.frame = CGRectMake(_btnSignUpOutlet.frame.origin.x, _txtFieldDepartment.frame.origin.y+20, _btnSignUpOutlet.frame.size.width, _btnSignUpOutlet.frame.size.height);
    
   // [self setViewCalculations];
    
    _txtFieldUsername.textColor=[UIColor whiteColor];
    _txtFieldUsername.enableMaterialPlaceHolder = YES;
    _txtFieldUsername.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldUsername.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldUsername.tintColor=[UIColor whiteColor];
    _txtFieldUsername.placeholder=@"Username";
    
    _txtFieldPassword.textColor=[UIColor whiteColor];
    _txtFieldPassword.enableMaterialPlaceHolder = YES;
    _txtFieldPassword.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldPassword.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldUsername.tintColor=[UIColor whiteColor];
    _txtFieldPassword.placeholder=@"Password";
    
    _txtFieldFirstName.textColor=[UIColor whiteColor];
    _txtFieldFirstName.enableMaterialPlaceHolder = YES;
    _txtFieldFirstName.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldFirstName.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldFirstName.tintColor=[UIColor whiteColor];
    _txtFieldFirstName.placeholder=@"First Name";
    
    _txtFieldLastName.textColor=[UIColor whiteColor];
    _txtFieldLastName.enableMaterialPlaceHolder = YES;
    _txtFieldLastName.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldLastName.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldLastName.tintColor=[UIColor whiteColor];
    _txtFieldLastName.placeholder=@"Last Name";

    
    _txtFieldEmail.textColor=[UIColor whiteColor];
    _txtFieldEmail.enableMaterialPlaceHolder = YES;
    _txtFieldEmail.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldEmail.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldEmail.tintColor=[UIColor whiteColor];
    _txtFieldEmail.placeholder=@"Email";
    
    _txtFieldPhone.textColor=[UIColor whiteColor];
    _txtFieldPhone.enableMaterialPlaceHolder = YES;
    _txtFieldPhone.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldPhone.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldPhone.tintColor=[UIColor whiteColor];
    _txtFieldPhone.placeholder=@"Phone";
    
    _txtFieldDepartment.textColor=[UIColor whiteColor];
    _txtFieldDepartment.enableMaterialPlaceHolder = YES;
    _txtFieldDepartment.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldDepartment.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldDepartment.tintColor=[UIColor whiteColor];
    _txtFieldDepartment.placeholder=@"Department";
    
    _txtFieldDesignation.textColor=[UIColor whiteColor];
    _txtFieldDesignation.enableMaterialPlaceHolder = YES;
    _txtFieldDesignation.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldDesignation.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldDesignation.tintColor=[UIColor whiteColor];
    _txtFieldDesignation.placeholder=@"Designation";
    
    
    _txtFieldCompany.textColor=[UIColor whiteColor];
    _txtFieldCompany.enableMaterialPlaceHolder = YES;
    _txtFieldCompany.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    _txtFieldCompany.lineColor=[UIColor colorWithRed:48/255.0 green:138/255.0 blue:210/255.0 alpha:1.000];
    _txtFieldCompany.tintColor=[UIColor whiteColor];
    _txtFieldCompany.placeholder=@"Company";
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [arrDepartMents count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"dropCell";
    
    departmentTableCell *cell = (departmentTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"departmentTableCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [arrDepartMents objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _txtFieldDepartment.text = [arrDepartMents objectAtIndex:indexPath.row];
    
    [self dismissViewControllerAnimated:YES completion: nil];
}

-(void)showDepartments
{
    arrDepartMents = [[NSMutableArray alloc] initWithObjects:@"Management",@"Marketing",@"HR & Admin",@"Finance",@"Support",@"IT", nil];
    
    UIViewController *controller = [[UIViewController alloc]init];
    
    CGRect rect;
    
    rect = CGRectMake(0, 0, 272, 250);
    
    [controller setPreferredContentSize:rect.size];
    
    _tblDepartments  = [[UITableView alloc]initWithFrame:rect];
    _tblDepartments.delegate = self;
    _tblDepartments.dataSource = self;
    _tblDepartments.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"management_bg.png"]];
    
    _tblDepartments.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tblDepartments setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tblDepartments setTag:10];
    _tblDepartments.allowsMultipleSelection = YES;
    
    [controller.view addSubview:_tblDepartments];
    
    [controller.view bringSubviewToFront:_tblDepartments];
    
    [controller.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"management_bg.png"]]];
    
    [controller.view setUserInteractionEnabled:YES];
    
    [_tblDepartments setUserInteractionEnabled:YES];
    [_tblDepartments setAllowsSelection:YES];
    
    alertController = [UIAlertController alertControllerWithTitle:@"Departments" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController setValue:controller forKey:@"contentViewController"];
    
    //  [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"management_bg.png"]]];
    
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    
    tapPress.delaysTouchesBegan = NO;
    tapPress.cancelsTouchesInView = NO;
    
    [alertController.view.superview addGestureRecognizer:tapPress];
    
    [self presentViewController: alertController
                       animated: YES
                     completion:^{
                         alertController.view.superview.userInteractionEnabled = YES;
                         [alertController.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapPress:)]];
                     }];
}

- (void)tapPress:(UITapGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (IBAction)btnDepartMents:(id)sender {
    
    [self showDepartments];
}


- (IBAction)userTypeChanged:(id)sender {
    switch (_userSelectionSegControl.selectedSegmentIndex) {
            
        case 0:
            
            isEmployee = NO;
            _txtFieldDepartment.hidden = YES;
            _txtFieldCompany.hidden = NO;
            
//            _btnSignUpOutlet.frame = CGRectMake(_btnSignUpOutlet.frame.origin.x, _txtFieldDepartment.frame.origin.y+20, _btnSignUpOutlet.frame.size.width, _btnSignUpOutlet.frame.size.height);
            
            //[self setViewCalculations];
            
            break;
            
        case 1:
            
            isEmployee = YES;
            _txtFieldDepartment.hidden = NO;
            _txtFieldCompany.hidden = YES;
            
//            _btnSignUpOutlet.frame = CGRectMake(_btnSignUpOutlet.frame.origin.x, _txtFieldDepartment.frame.origin.y+_txtFieldDepartment.frame.size.height+20, _btnSignUpOutlet.frame.size.width, _btnSignUpOutlet.frame.size.height);
            
           // [self setViewCalculations];
            
            break;
            
        default:
            break;
    }
}



-(void)signUpUser{
    
    if([self notEmptyChecking] == NO){return;}
    if([self validityChecking] == NO){return;}

    [SVProgressHUD show];
    
    //    NSDictionary *params = @{   @"cur_lat" : [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude],
    //                                @"cur_long":[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude],
    //                                @"user_name" : _txtFieldUsername.text,
    //                                @"password" : _txtFieldPassword.text
    //                                };
    //
    //    if (_checkBox.isSelected) {
    //        userType = @"Employee";
    //    }else{
    //        userType = @"Guest";
    //    }
    if(isEmployee){
        userType = @"Employee";
    }else{
        userType = @"Guest";
    }
//    username
//    password
//    deviceID
//    type
//    usertype
//    fname
//    lname
//    designation
//    department
//    email
//    phone
    NSString *desig = _txtFieldDesignation.text;
    NSString *dept = _txtFieldDepartment.text;
    NSString *comp = _txtFieldCompany.text;

    if(!isEmployee){
        
       dept = @"";
    }
    else
    {
       comp = @"";
    }
    
    NSDictionary *params = @{@"username":_txtFieldUsername.text,@"password":_txtFieldPassword.text,@"deviceId":[[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"],@"type":@"Ios",@"usertype":userType,@"fname":_txtFieldFirstName.text,@"lname":_txtFieldLastName.text,@"email":_txtFieldEmail.text,@"phone":_txtFieldPhone.text,@"designation":desig,@"department":dept,@"company":comp};
    
    NSLog(@"params : %@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@register.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            [Userdefaults setBool:true forKey:@"isDeviceinfoUpdated"];
            
            [Userdefaults synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            
            NSString *msg = [responseDict objectForKey:@"message"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            [SVProgressHUD dismiss];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}

-(BOOL)notEmptyChecking{
    
    if(_txtFieldUsername.text.length<1){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [SVProgressHUD dismiss];
        [_txtFieldUsername becomeFirstResponder];
        return NO;
    }else if(_txtFieldPassword.text.length<1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [SVProgressHUD dismiss];
        [_txtFieldPassword becomeFirstResponder];
        
        return NO;
        
        
    }
    
    if(_txtFieldFirstName.text.length<1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"First name cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [SVProgressHUD dismiss];
        [_txtFieldFirstName becomeFirstResponder];
        return NO;
    }else if(_txtFieldLastName.text.length<1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Last name cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [SVProgressHUD dismiss];
        [_txtFieldLastName becomeFirstResponder];
        
        return NO;
        
        
    }
    if(_txtFieldEmail.text.length<1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [SVProgressHUD dismiss];
        [_txtFieldEmail becomeFirstResponder];
        return NO;
    }else if(_txtFieldPhone.text.length<1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        // [SVProgressHUD dismiss];
        [_txtFieldPhone becomeFirstResponder];
        
        return NO;
        
        
    }

    if(isEmployee){
        if(_txtFieldDepartment.text.length<1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Department cannot be empty."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            // [SVProgressHUD dismiss];
            [_txtFieldDepartment becomeFirstResponder];
            return NO;
        }else if(_txtFieldDesignation.text.length<1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Designation cannot be empty."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            // [SVProgressHUD dismiss];
            [_txtFieldDesignation becomeFirstResponder];
            
            return NO;
            
            
        }

    }
    
    return YES;
}

-(BOOL) NSStringIsValidEmail:(NSString *)emailString{
    
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

-(BOOL) validityChecking{
    
    BOOL validEmail = [self NSStringIsValidEmail:_txtFieldEmail.text];
    
    if(validEmail == NO){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please provide a valid email address."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        [_txtFieldEmail becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}


-(void)displayToastWithMessage:(NSString *)toastMessage
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        UILabel *toastView = [[UILabel alloc] init];
        toastView.text = toastMessage;
        toastView.font = [UIFont systemFontOfSize:14];
        toastView.textColor = [UIColor blackColor];
        toastView.backgroundColor = [UIColor whiteColor];
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width/2.0, 150.0);
        toastView.layer.cornerRadius = 10;
        toastView.lineBreakMode = NSLineBreakByWordWrapping;
        toastView.numberOfLines = 5;
        toastView.layer.masksToBounds = YES;
        toastView.center = keyWindow.center;
        
        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 5.0f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             
                             toastView.alpha = 0.0;
                             
                         }
                         completion: ^(BOOL finished) {
                             
                             [toastView removeFromSuperview];
                         }
         ];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    //[self setViewCalculations];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PreviousButton"]
                                                      style:UIBarButtonItemStyleDone target:self
                                                     action:@selector(previousClicked:)];
    
    nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NextButton"]
                                                  style:UIBarButtonItemStyleDone target:self
                                                 action:@selector(nextClicked:)];
    
    
    
    flexBarButton = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                     target:nil action:nil];
    
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                  style:UIBarButtonItemStyleDone target:self
                                                 action:@selector(doneClicked:)];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:previousButton,nextButton,flexBarButton,doneButton, nil]];
    
    textField.inputAccessoryView = keyboardDoneButtonView;
    textField.inputAccessoryView = keyboardDoneButtonView;
    doneKeyboardHeight = keyboardDoneButtonView.frame.size.height;
    
    if (textField==_txtFieldEmail) {
        
        [self displayToastWithMessage:@"Please use future netwings official email id for sign up..."];
    }
    

    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.btnSignUpOutlet.frame.origin.y+self.btnSignUpOutlet.frame.size.height+300);
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(textField == _txtFieldUsername){
        
        [self checkCreds];
        
    }else if (textField == _txtFieldEmail){
        
        if(![self NSStringIsValidEmail:_txtFieldEmail.text]){
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter a valid email."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            [SVProgressHUD dismiss];

        }else{
            
            [self checkCreds];
        }
        
    }else if (textField == _txtFieldPhone){
        
        [self checkCreds];
    }
}

- (IBAction)btnLoginDidTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSignUpDidTap:(id)sender {
    [self signUpUser];
}

-(void)checkCreds{
    
    if(_txtFieldUsername.text.length>1 || _txtFieldEmail.text.length>1 || _txtFieldPhone.text.length>1){
    [SVProgressHUD show];
    NSDictionary *params = @{@"username":_txtFieldUsername.text,@"email":_txtFieldEmail.text,@"phone":_txtFieldPhone.text};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *host_url = [NSString stringWithFormat:@"%@checking.php",BASE_URL];
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        bool success = [[responseDict objectForKey:@"error"] boolValue];
        
        if (success) {
            [SVProgressHUD dismiss];
            //[self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString *msg = [responseDict objectForKey:@"message"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            [SVProgressHUD dismiss];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [SVProgressHUD dismiss];
    }];
    }
}

@end
