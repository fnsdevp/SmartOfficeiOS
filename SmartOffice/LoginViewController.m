//
//  LoginViewController.m
//  SmartOffice
//
//  Created by FNSPL on 17/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "HomeViewController.h"
#import "EmpHomeViewController.h"

#define kOFFSET_FOR_KEYBOARD 80.0

@interface LoginViewController (){
    NSString *userType;
    bool isEmployee;
    HomeViewController *home;
    EmpHomeViewController *empHome;
}

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    userType = @"User";
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
    _txtFieldPassword.tintColor=[UIColor whiteColor];
    _txtFieldPassword.placeholder=@"Password";
    
    
    self.checkBox.animateDuration = 0.5;
    self.checkBox.lineWidth = 6;
    
    [self getMacAddressByipAddress];
    
    isEmployee = NO;
    
    if(isEmployee){
        
        userType = @"employee";
        
    }else{
        
        userType = @"Guest";
        
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    db = [Database sharedDB];
    
    NSArray *arrUser = [db getUser];
    
    if ([arrUser count]>0) {
        
        [db deleteAllUsers];
    }
    
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBG:)];
    
    tapPress.delaysTouchesBegan = NO;
    tapPress.cancelsTouchesInView = NO;
    
    [self.view.superview addGestureRecognizer:tapPress];
 
}

- (void)tapBG:(UITapGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


#pragma mark - text field delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField isEqual:_txtFieldUsername])
    {
        [_scrollView setContentOffset:CGPointMake(0, (20+_txtFieldUsername.frame.size.height))];
        
       // _scrollView.frame = CGRectMake(0, 0, SCREENWIDTH, 20);
    }
    else if([textField isEqual:_txtFieldPassword])
    {
        [_scrollView setContentOffset:CGPointMake(0, (40+_txtFieldPassword.frame.size.height))];
        
       // _scrollView.frame = CGRectMake(0, 0, SCREENWIDTH, (40+_txtFieldPassword.frame.size.height));
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _scrollView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    
    if (textField == _txtFieldUsername) {
        
        [_txtFieldUsername resignFirstResponder];
        [_txtFieldPassword becomeFirstResponder];
        
    } else if (textField == _txtFieldPassword) {
        
        [_txtFieldPassword resignFirstResponder];
    }
    
    return YES;
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

- (IBAction)btnForgotPasswordDidTap:(id)sender
{
    forgotPassVC = [[ForgotPassViewController alloc] init];
    
    forgotPassVC.delegate = self;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self presentViewController:forgotPassVC animated:NO completion:nil];
}

-(void)ForgotPassViewController:(ForgotPassViewController *)obj didremove:(BOOL)isRemove
{
    [obj dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)btnLoginDidTap:(id)sender {
    
    [self loginUser];
}

- (IBAction)btnCheckBoxDidTap:(id)sender {
    
    isEmployee = !isEmployee;
    
    if(isEmployee){
        
        userType = @"employee";
        
    }else{
        
        userType = @"Guest";
        
    }
}

- (IBAction)btnSignUpDidTap:(id)sender {
    
}

-(void)loginUser{
    
    if([self notEmptyChecking] == NO){return;}
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"username":_txtFieldUsername.text,@"password":_txtFieldPassword.text,@"deviceId":[Userdefaults objectForKey:@"device_id"],@"type":@"Ios",@"usertype":userType};
    
    NSLog(@"params : %@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@login.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
     
            NSDictionary *userDict = [[responseDict objectForKey:@"profile"] objectAtIndex:0];
            NSDictionary *modiDict = [userDict mutableCopy];

            NSString *lName = [userDict objectForKey:@"lname"];
            
            if ([lName isKindOfClass:[NSNull class]]) {
                
                lName = @"";
                [modiDict setValue:lName forKey:@"lname"];
                
            }
            
            userType = [modiDict objectForKey:@"usertype"];
            
            [Userdefaults setObject:modiDict forKey:@"ProfInfo"];
            [Userdefaults setObject:@"YES" forKey:@"isLoggedIn"];
            [Userdefaults setObject:userType forKey:@"userType"];
            [Userdefaults synchronize];
            
            NSNumber *userid = [modiDict objectForKey:@"id"];
            
            NSDictionary *dict = [Userdefaults objectForKey:@"ProfInfo"];
            
            NSString *userID = [NSString stringWithFormat:@"%d",(int)[[dict objectForKey:@"id"] integerValue]];
            
            NSString *macID = [Userdefaults objectForKey:@"macAddress"];
            
            NSString *deviceToken = [Userdefaults objectForKey:@"deviceToken"];
            
            if ([deviceToken length]>0) {
                
                [self getRegKey:userID];
            }
            
            //[self getDeviceTokenWithMacId:macID userid:userID];
            
            [db insertInUserTableWithUsername:self.txtFieldUsername.text andPassword:self.txtFieldPassword.text andUserid:[NSString stringWithFormat:@"%@",[userid stringValue]] andUsertype:[modiDict objectForKey:@"usertype"] andStatus:[modiDict objectForKey:@"status"] andDepartment:[modiDict objectForKey:@"department"] andDesignation:[modiDict objectForKey:@"designation"] andEmail:[modiDict objectForKey:@"email"] andFname:[modiDict objectForKey:@"fname"] anLname:[modiDict objectForKey:@"lname"]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            
            home = [storyboard instantiateInitialViewController];
            
            [self.navigationController pushViewController:home animated:YES];

            
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


-(void)getMacAddressByipAddress
{
    NSString *CurrentIPAddress = [NSString stringWithFormat:@"%@",[SystemSharedServices currentIPAddress]];
    
    NSLog(@"Current IP Address: %@",[SystemSharedServices currentIPAddress]);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    host_url = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_LOCAL,CurrentIPAddress];
    
    //    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
    //
    //        host_url = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_LOCAL,CurrentIPAddress];
    //
    //    } else {
    //
    //        host_url = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_GLOBAL,CurrentIPAddress];
    //    }
    
    [manager GET:host_url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        [SVProgressHUD dismiss];
        
        NSArray *arr = responseObject;
        
        if ([arr count]>0) {
            
            NSDictionary *dict = [arr objectAtIndex:0];
            
            NSString *macaddress = [dict valueForKey:@"macAddress"];
            
            NSLog(@"macaddress: %@", macaddress);
            
            [Userdefaults setObject:macaddress forKey:@"macAddress"];
            
            [Userdefaults synchronize];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
        
    }];
    
}

-(void)getDeviceTokenWithMacId:(NSString *)macID userid:(NSString *)userID{
    
    [SVProgressHUD show];
    
    NSString *deviceToken = [Userdefaults objectForKey:@"deviceToken"];
    
    NSDictionary *params = @{@"userid":userID,@"devicetoken":deviceToken,@"macid":macID};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *url = [NSString stringWithFormat:@"http://eegrab.com/smartoffice/updatedevice.php"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSLog(@"dict: %@", dict);
        
        NSString *statusStr = [dict objectForKey:@"status"];
        
        if ([statusStr isEqualToString:@"success"]) {
            
            [Userdefaults setBool:true forKey:@"isDeviceinfoUpdated"];
            
            [Userdefaults synchronize];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        
    }];
    
}

    
-(void)getRegKey:(NSString *)userID{
    
    [SVProgressHUD show];
    
    NSString *deviceToken = [Userdefaults objectForKey:@"deviceToken"];
    
    NSDictionary *params = @{@"userid":userID,@"reg":deviceToken,@"type":@"Ios"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *hostUrl = [NSString stringWithFormat:@"%@get_regkey.php",BASE_URL];
    
    [manager POST:hostUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
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
        
        [self performSelector:@selector(getRegKey:) withObject:userID afterDelay:0.0];
       
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
    
    return YES;
}

@end
