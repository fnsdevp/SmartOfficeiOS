//
//  ProfileViewController.m
//  SmartOffice
//
//  Created by FNSPL on 09/05/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    
    [self.longPressGesture setMinimumPressDuration:1.5];
    
    [self.imgRing addGestureRecognizer:self.longPressGesture];
    
    if ([Userdefaults boolForKey:@"dateNotification"]==NO) {
        
        [self.dateNotifSwitch setOn:false animated:YES];
        
        [Userdefaults setBool:NO forKey:@"dateNotification"];
        
        [Userdefaults synchronize];
    }
    else
    {
        [self.dateNotifSwitch setOn:true animated:YES];
        
        [Userdefaults setBool:YES forKey:@"dateNotification"];
        
        [Userdefaults synchronize];
    }
    
    [self setProfilePic];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    navView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [navView addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, navView.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    // NSString *blueText = @"Schedule";
    NSString *whiteText = @"Profile";
    NSString *text = [NSString stringWithFormat:@"%@",
                      whiteText];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: label.font
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    UIColor *whiteColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    NSRange whiteTextRange = [text rangeOfString:whiteText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    [attributedText setAttributes:@{NSForegroundColorAttributeName:whiteColor}
                            range:whiteTextRange];
    label.attributedText = attributedText;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    
    [navView addSubview:label];
    
    [self.navigationController.navigationBar addSubview:navView];
    
    [self setProfileDetails];
    
    _innerScrollVw.contentSize = CGSizeMake(SCREENWIDTH, (_dateNotifVw.frame.origin.y+_dateNotifVw.frame.size.height+100));
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [navView removeFromSuperview];
    
}
    
-(IBAction)setNotification:(id)sender
{
    if ([Userdefaults boolForKey:@"dateNotification"]==YES)
    {
        [self.dateNotifSwitch setOn:false animated:YES];
        
        [Userdefaults setBool:NO forKey:@"dateNotification"];
        
        [Userdefaults synchronize];
    }
    else
    {
        [self.dateNotifSwitch setOn:true animated:YES];
        
        [Userdefaults setBool:YES forKey:@"dateNotification"];
        
        [Userdefaults synchronize];
    }
}


-(void)setProfileDetails
{
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    _userTypelbl.text = [NSString stringWithFormat:@"User: %@",[userDict objectForKey:@"usertype"]];
    
    _fnamelbl.text = [NSString stringWithFormat:@"First Name: %@",[userDict objectForKey:@"fname"]];
    
    _lnamelbl.text = [NSString stringWithFormat:@"Last Name: %@",[userDict objectForKey:@"lname"]];
    
    _designationlbl.text = [NSString stringWithFormat:@"Designation: %@",[userDict objectForKey:@"designation"]];
    
    _departmentlbl.text = [NSString stringWithFormat:@"Department: %@",[userDict objectForKey:@"department"]];
    
    _companylbl.text = [NSString stringWithFormat:@"Company: %@",[userDict objectForKey:@"company"]];
    
    _emaillbl.text = [NSString stringWithFormat:@"Email: %@",[userDict objectForKey:@"email"]];
    
    _phonelbl.text = [NSString stringWithFormat:@"Phone: %@",[userDict objectForKey:@"phone"]];
    
}


- (void)gestureHandler:(UILongPressGestureRecognizer *)sender {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Do you really want to delete the profile picture." message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"YES"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self removeImage];
                                 
                             }];
    
    UIAlertAction *cancel = [UIAlertAction
                                   actionWithTitle:@"NO"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)removeImage {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"profilePic.png"]];
    
    [fileManager removeItemAtPath: fullPath error:NULL];
    
    [self setProfilePic];
    
    NSLog(@"image removed");
}


- (IBAction)changePasswordBtnAction:(id)sender {
    
    newPassVC = [[ChangePasswordViewController alloc] init];
    
    newPassVC.delegate = self;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self presentViewController:newPassVC animated:NO completion:nil];
    
}


- (IBAction)profPicBtnAction:(id)sender {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Set Profile picture." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camera = [UIAlertAction
                                actionWithTitle:@"Take Photo"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                   [self takePicture];
                                    
                                }];
    
    UIAlertAction* photoGallery = [UIAlertAction
                               actionWithTitle:@"Choose Photo"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self choosePicture];
                                   
                               }];
    
    UIAlertAction* cancel = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    
    [alert addAction:camera];
    [alert addAction:photoGallery];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(void)choosePicture
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}


-(void)takePicture
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.profPicImg.image = chosenImage;
    
    self.profPicImg.layer.cornerRadius = self.profPicImg.frame.size.width/2;
    self.profPicImg.clipsToBounds = YES;
    
    NSData *pngData = UIImagePNGRepresentation(chosenImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"profilePic.png"]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)setProfilePic
{
    NSArray *docpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [docpaths objectAtIndex:0];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"profilePic.png"];
    
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
    UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
    
    if (thumbNail==nil) {
        
        self.profPicImg.image = [UIImage imageNamed:@"profilePic"];
    }
    else
    {
        self.profPicImg.image = thumbNail;
        
        self.profPicImg.layer.cornerRadius = self.profPicImg.frame.size.width/2;
        self.profPicImg.clipsToBounds = YES;
    }
    
}


-(void)ChangePasswordViewController:(ChangePasswordViewController *)obj didremove:(BOOL)isRemove
{
    [obj dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)updateDeviceInfoBtn:(id)sender
{
   // [self getMacAddressByipAddress];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    [self getRegKey:userId];
}


-(void)getRegKey:(NSString *)userID{
    
    [SVProgressHUD showWithStatus:@"Updating..."];
    
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
            
            
            [Userdefaults setBool:true forKey:@"isDeviceinfoUpdated"];
            
            [Userdefaults synchronize];
            
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Device information updated successfully." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *OKAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           
                                       }];
            
            
            [alert addAction:OKAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            [SVProgressHUD dismiss];
            
        }else{
            
            NSString *msg = [responseDict objectForKey:@"message"];
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *OKAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           
                                       }];
            
            
            [alert addAction:OKAction];
            
            [self presentViewController:alert animated:YES completion:nil];

            [SVProgressHUD dismiss];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [self performSelector:@selector(getRegKey:) withObject:userID afterDelay:0.0];
        
        [SVProgressHUD dismiss];
    }];
    
}


-(void)getMacAddressByipAddress
{
   // [SVProgressHUD showWithStatus:@"Updating..."];
    
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
        
        NSArray *arr = responseObject;
        
        if ([arr count]>0) {
            
            NSDictionary *dict = [arr objectAtIndex:0];
            
            NSString *macaddress = [dict valueForKey:@"macAddress"];
            
            NSLog(@"macaddress: %@", macaddress);
            
            [Userdefaults setObject:macaddress forKey:@"macAddress"];
            
            [Userdefaults synchronize];
            
            //NSString *deviceToken = [Userdefaults objectForKey:@"deviceToken"];
            
            NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
            
            userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
            
            [self getDeviceTokenWithMacId:macaddress userid:userId];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to update device information, pleae try again." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OKAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        
        [alert addAction:OKAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getDeviceTokenWithMacId:(NSString *)macID userid:(NSString *)userID{
    
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
            
//            [Userdefaults setBool:true forKey:@"isDeviceinfoUpdated"];
//            
//            [Userdefaults synchronize];
            
//            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Device information updated successfully." preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *OKAction = [UIAlertAction
//                                       actionWithTitle:@"OK"
//                                       style:UIAlertActionStyleDefault
//                                       handler:^(UIAlertAction * action)
//                                       {
//                                           [self dismissViewControllerAnimated:YES completion:nil];
//                                           
//                                       }];
//            
//            
//            [alert addAction:OKAction];
//            
//            [self presentViewController:alert animated:YES completion:nil];
            
            
            [SVProgressHUD dismiss];
        }
        else
        {
            [Userdefaults setBool:false forKey:@"isDeviceinfoUpdated"];
            
            [Userdefaults synchronize];
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device information updatation failure, please try again." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *OKAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           
                                       }];
            
            
            [alert addAction:OKAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            
            [SVProgressHUD dismiss];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to update device information, pleae try again." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OKAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        
        [alert addAction:OKAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        [SVProgressHUD dismiss];
        
    }];
    
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

@end
