//
//  HomeViewController.m
//  SmartOffice
//
//  Created by FNSPL on 04/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeOptionsCollectionViewCell.h"
#import "UpcomingMeetingsCollectionViewCell.h"
#import "DrawerView.h"
#import "RightSideDrawerViewController.h"
#import "MessagesViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>

#define MAX_HUE 65535

#define IPADDRESS "192.168.1.10/userlogin"

@interface HomeViewController (){
    NSArray *options;
    DrawerView *profSlide;
    UIView *view;
    MessagesViewController *inbox;
    NSArray *meetingsArr;
    NSString *userId;
    float timerforApi;
}

@end


@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"Schedule",@"title",@"MEETING",@"subtitle",@"schedule_icon.png",@"image", nil];
    NSDictionary *dict1 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Order",@"title",@"FOOD",@"subtitle",@"food.png",@"image", nil];
    NSDictionary *dict2 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Inbox",@"title",@"MESSAGES",@"subtitle",@"inbox.png",@"image", nil];
    NSDictionary *dict3 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Manage",@"title",@"MEETING",@"subtitle",@"calendar.png",@"image", nil];
    
    options = @[dict,dict1,dict2,dict3];
    
    arrPointNames = [[NSMutableArray alloc] initWithObjects:@"director room",@"j p lahiri room",@"conference room",@"toilet",@"pantry",@"reception",@"entry",@"developer bay",@"developer entry",@"coridor", nil];
    
    arrPointx = [[NSMutableArray alloc] initWithObjects:@"17.73",@"17.62",@"23.79",@"21.99",@"20.89",@"12.88",@"8.04",@"17.44",@"17.61",@"17.70", nil];
    
    arrPointy = [[NSMutableArray alloc] initWithObjects:@"7.30",@"14.72",@"21.19",@"29.94",@"41.98",@"37.05",@"39.58",@"22.26",@"27.74",@"34.70", nil];
    
    [self.collectionViewOptions registerNib:[UINib nibWithNibName:@"HomeOptionsCollectionViewCell" bundle:[NSBundle mainBundle]]
                         forCellWithReuseIdentifier:@"HomeOptionsCollectionViewCell"];

    [self.collectionViewUpcoming registerNib:[UINib nibWithNibName:@"UpcomingMeetingsCollectionViewCell" bundle:[NSBundle mainBundle]]
                 forCellWithReuseIdentifier:@"UpcomingMeetingsCollectionViewCell"];
    
    [lightState setHue:[NSNumber numberWithInt:MAX_HUE]];

    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    [NavigineCore defaultCore].userHash = @"0F17-DAE1-4D0A-1778";
    [NavigineCore defaultCore].delegate = self;
    
    [[NavigineCore defaultCore] downloadLocationByName:@"Future Netwings"
                                           forceReload:NO
                                          processBlock:^(NSInteger loadProcess) {
                                              NSLog(@"%zd",loadProcess);
                                          } successBlock:^(NSDictionary *userInfo) {
                                              [self setupNavigine];
                                          } failBlock:^(NSError *error) {
                                              NSLog(@"%@",error);
                                          }];

    
    //[self getRegKey];
    
    
    BOOL isDeviceinfoUpdated = [Userdefaults boolForKey:@"isDeviceinfoUpdated"];
    
    
    if (isDeviceinfoUpdated==0) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"In case you are unable to receive notification from EZAPP app, kindly follow the path More - > Profile Management - > Update Device Information, to enable the service." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OKAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        
        [alert addAction:OKAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self getDeviceUpdation];
    
    _PopupView.hidden = YES;
    
    _PopupView.layer.cornerRadius = 5.0;
    
    _btnOpenMap.layer.cornerRadius = 5.0;
    _btnOpenMap.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnOpenMap.layer.borderWidth = 2.0;
    
    _lblTimer.text = @"05.00";
    
    _midView.layer.cornerRadius = 5.0;
    
     running = FALSE;
    
    ctrlVC = [[CtrlViewController alloc] init];
    
    //[self performSelector:@selector(getLatestLatLong) withObject:nil afterDelay:2.0];

}


-(void)viewWillAppear:(BOOL)animated{
    
    db = [Database sharedDB];
    
    isLocalFire = NO;
    timerforApi = 0.0;
    
    if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        UserId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    }
    
    [self getUpcomingMeetings];
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, view.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    NSString *blueText = @"E";
    NSString *whiteText = @"ZAPP";
    NSString *text = [NSString stringWithFormat:@"%@ %@",
                      blueText,
                      whiteText];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: label.font
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    
    UIColor *blueColor = [UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1.0];
    NSRange blueTextRange = [text rangeOfString:blueText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    
    [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor}
                            range:blueTextRange];
    
    UIColor *whiteColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    NSRange whiteTextRange = [text rangeOfString:whiteText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    [attributedText setAttributes:@{NSForegroundColorAttributeName:whiteColor}
                            range:whiteTextRange];
    label.attributedText = attributedText;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    [view addSubview:label];
    
    [self.navigationController.navigationBar addSubview:view];
    
    //[self getTimeCheckforUpcomingMeeting];
    
    
    AFNetworkReachabilityManager *network = [AFNetworkReachabilityManager sharedManager];
    
    
    BOOL isMacUpdated = [Userdefaults boolForKey:@"isMacUpdated"];
    
    
    if (isMacUpdated==0) {
        
        if ([network isReachableViaWiFi])
        {
            [self getMacAddressByipAddress];
        }
    }
    
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
//    [reachability startNotifier];
//    
//    NetworkStatus status = [reachability currentReachabilityStatus];
//    
//    if (status == ReachableViaWiFi)
//    {
//        //WiFi
//        
//        CFArrayRef myArray = CNCopySupportedInterfaces();
//        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
//        //    NSLog(@"SSID: %@",CFDictionaryGetValue(myDict, kCNNetworkInfoKeySSID));
//        NSString *networkName = CFDictionaryGetValue(myDict, kCNNetworkInfoKeySSID);
//        
//        if ([networkName isEqualToString:@"FNSPL"])
//        {
//            locationApi = [NSTimer scheduledTimerWithTimeInterval:180.0f target:self selector:@selector(getLatestLatLong) userInfo:nil repeats:YES];
//        }
//        else if ([networkName isEqualToString:@"GUEST"])
//        {
//            locationApi = [NSTimer scheduledTimerWithTimeInterval:180.0f target:self selector:@selector(getLatestLatLong) userInfo:nil repeats:YES];
//        }
//        else
//        {
//            [locationApi invalidate];
//        }
//    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(navigationTick:)
                                   userInfo:nil
                                    repeats:YES];
    
    
    /*timerforApi = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                  target:self
                                                selector:@selector(apiforCMX)
                                               userInfo:nil
                                                repeats:YES];
    
    [timerforApi fire];*/
    
    unreadMsgCount = 0;
    
   // [self getAllMessages];
    
    [self detectBluetooth];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self drawPath];
    _zoneArray = nil;
    [self getZone];
}

    
-(void)viewWillDisappear:(BOOL)animated{
    
    [view removeFromSuperview];
    
    [SVProgressHUD dismiss];
}


-(void)getLatestLatLong
{
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
    
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:Lastlatitude longitude:Lastlongitude];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
//    NSString *Lat = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
//    
//    NSString *Long = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    
//    NSString *Lat2 = [NSString stringWithFormat:@"%f",Lastlatitude];
//    
//    NSString *Long2 = [NSString stringWithFormat:@"%f",Lastlongitude];
    
    if (distance<1.0) {
        
        if (count==0) {
            
            [self startLocalNotificationForHelp];
            
            count = 1;
        }
    }
}


- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}


- (void)centralManagerDidUpdateState:(CBCentralManager*)aManager
{
    if( aManager.state == CBManagerStatePoweredOn )
    {
        
    }
    else if( aManager.state == CBManagerStatePoweredOff )
    {
        BOOL isBluetoothAlerton = [Userdefaults boolForKey:@"isBluetoothAlerton"];
        
        if (isBluetoothAlerton==0) {
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
//                                                            message:@"Bluetooth is currently powered off. Please turn on to experience navigation & other features in app."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"ok" otherButtonTitles: nil];
//            
//            [Userdefaults setBool:YES forKey:@"isBluetoothAlerton"];
//            
//            [Userdefaults synchronize];
//            
//            [alert show];
            
        }
    }
}


-(void)apiforCMX
{
    BOOL isMacUpdated = [Userdefaults boolForKey:@"isMacUpdated"];
    
    BOOL uniqueFired = [Userdefaults boolForKey:@"uniqueFired"];
    
    BOOL isConferenceArea = [Userdefaults boolForKey:@"isConferenceArea"];
    
    // BOOL restrictedZone = [Userdefaults boolForKey:@"restrictedZone"];
    
    NSString *macaddress = [Userdefaults objectForKey:@"macAddress"];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    
   // [self performSelectorInBackground:@selector(BackgroundMethod) withObject:nil];
    
    if (macaddress!=nil) {
        
        if (isMacUpdated==0) {
            
            [self performSelectorInBackground:@selector(getDeviceTokenWithMacId:) withObject:macaddress];
            
           // [self getDeviceTokenWithMacId:macaddress];
        }
        
        if (uniqueFired==0) {
            
            
            [self performSelectorInBackground:@selector(getUniqueMacId:) withObject:macaddress];
            
           // [self getUniqueMacId:macaddress];
        }
    }
    
    if (isConferenceArea) {
        
        [self performSelectorInBackground:@selector(getMacAddressByipAddress2) withObject:nil];
    }
    
   // [self getMacAddressByipAddress2];

}


-(IBAction)startLocalNotification {
    
    NSString *str1 = @"Welcome to Future Netwings Solutions Private Limited.";
    
    _lblSpeeach.text = str1;
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:str1];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    
    [synth speakUtterance:utterance];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = str1;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    isLocalFire = NO;
    
    [Userdefaults setBool:true forKey:@"welComeFired"];
    
    [Userdefaults synchronize];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


//-(IBAction)startLocalNotificationRestrictedZone {
//    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    //notification.fireDate = [NSDate date];
//    notification.alertBody = @"This is a restricted zone.";
//    notification.timeZone = [NSTimeZone localTimeZone];
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.applicationIconBadgeNumber = 1;
//    
//    isLocalFire = NO;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    
//}


-(IBAction)startLocalNotificationforUnique {
    
    NSString *str1 = @"Welcome for first time visit Future Netwings Solutions Private Limited.";
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //notification.fireDate = [NSDate date];
    notification.alertBody = str1;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [Userdefaults setBool:true forKey:@"uniqueFired"];
    
    [Userdefaults synchronize];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


-(IBAction)startLocalNotificationForHelp{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //notification.fireDate = [NSDate date];
    notification.alertBody = @"Do you need any help?";
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


//-(void)getRestrictedZone:(NSString *)macaddress{
//    
//    //NSLog(@"MAC address: %@",[self getGatewayIP]);
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",@"text/plain"]];
//    
//    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
//    
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    
//    securityPolicy.allowInvalidCertificates = YES;
//    manager.securityPolicy = securityPolicy;
//    
//    NSString *hostUrl = [NSString stringWithFormat:@"%@api/location/v1/compliance/clientcompliance/floor/%@",CMX_URL_LOCAL,macaddress];
//    
//    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        
//        NSLog(@"JSON: %@", responseObject);
//        
//        [SVProgressHUD dismiss];
//        
//        //[self startLocalNotificationRestrictedZone];
//        
//        [Userdefaults setBool:true forKey:@"restrictedZone"];
//        
//        [Userdefaults synchronize];
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        
//        NSLog(@"Error: %@", error);
//        
//        [SVProgressHUD dismiss];
//        
//    }];
//    
//}


-(void)getDeviceInZone
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *hostUrl = [NSString stringWithFormat:@"%@/api/location/v1/clients/count/byzone/detail?zoneId=116",CMX_URL_LOCAL];
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *arr = responseObject;
        
        if ([arr count]>0) {
            
            NSDictionary *dict = [arr objectAtIndex:0];
            
            NSString *macaddress = [dict valueForKey:@"macAddress"];
            
            NSLog(@"macaddress: %@", macaddress);
            
            NSString *mac = [Userdefaults objectForKey:@"macAddress"];
            
//            if ([macaddress isEqualToString:mac]) {
//                
//                [self startLocalNotification];
//            }
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
        
    }];
}

-(void)getMacAddressByipAddress2
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
    
    NSString *hostUrl = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_LOCAL,CurrentIPAddress];
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *arr = responseObject;
        
        if ([arr count]>0) {
            
            NSDictionary *dict = [arr objectAtIndex:0];
            
            NSString *macaddress = [dict valueForKey:@"macAddress"];
            
            NSLog(@"macaddress: %@", macaddress);
            
            [Userdefaults setObject:macaddress forKey:@"macAddress"];
            
            [Userdefaults synchronize];
            
            [self getDeviceByMacAddress:macaddress];
            
        }
        else
        {
            [self getMacAddressByipAddress2];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [self getMacAddressByipAddress2];
        
        [SVProgressHUD dismiss];
        
    }];
    
}

-(void)getUniqueMacId:(NSString *)macaddress
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    
    NSString *hierarchy = @"fnspl/fnspl office/fnspl office";
    
    NSString *hostUrl = [NSString stringWithFormat:@"%@api/location/v1/history/uniqueclientsbyhierarchy?hierarchy=%@&date=%@&floorid=109&zoneid=116&distance=10",CMX_URL_LOCAL,hierarchy,theDate];
    
    NSString *urlString =  [hostUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSArray *macArr = [dict valueForKey:@"macaddresses"];
        
        //NSLog(@"macArr: %@", macArr);
        
        if ([macArr containsObject:macaddress]) {
            
            NSLog(@"unique");
            
            [self startLocalNotificationforUnique];
            
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
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
    
    NSString *hostUrl = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_LOCAL,CurrentIPAddress];
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
            
            [self getDeviceTokenWithMacId:macaddress];
            
        }
        else
        {
            [self getMacAddressByipAddress];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [self getMacAddressByipAddress];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getDeviceTokenWithMacId:(NSString *)macID{
    
    NSString *deviceToken = [Userdefaults objectForKey:@"deviceToken"];
    
    NSDictionary *params = @{@"userid":userId,@"devicetoken":deviceToken,@"macid":macID};
    
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
            
            [Userdefaults setBool:true forKey:@"isMacUpdated"];
            
            [Userdefaults synchronize];
            
            
            [SVProgressHUD dismiss];
        }
        else
        {
            [Userdefaults setBool:false forKey:@"isMacUpdated"];
            
            [Userdefaults synchronize];
            
            
            [SVProgressHUD dismiss];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getDeviceByMacAddress:(NSString *)macaddress{
    
    //NSLog(@"MAC address: %@",[self getGatewayIP]);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *hostUrl = [NSString stringWithFormat:@"%@api/location/v1/clients/count/byzone/detail?zoneId=112",CMX_URL_LOCAL];
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        [SVProgressHUD dismiss];
        
        NSDictionary *dict = responseObject;
        
        NSArray *arr = [dict objectForKey:@"MacAddress"];
        
        if ([arr containsObject:macaddress]) {
            
//            if (State!=YES) {
//                
//                [self lightOnAndOff:YES];
//                
//                State = YES;
//            }
//            
//            if ([Userdefaults boolForKey:@"speechConference"]==0) {
//                
//                AVSpeechUtterance *conference = [AVSpeechUtterance
//                                                 speechUtteranceWithString:@"You have entered into the conference room. While you be sitted, please order refreshment from our pantryman."];
//                
//                AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
//                
//                [synth speakUtterance:conference];
//                
//                [Userdefaults setBool:true forKey:@"speechConference"];
//                
//                [Userdefaults synchronize];
//            }
        }
        else
        {
//            if (State!=NO) {
//                
//                [self lightOnAndOff:NO];
//                
//                State = NO;
//            }
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
        
    }];
    
}

    
-(IBAction)btnOpenMap:(id)sender
{
    [self OpenMap];
}


-(IBAction)btnCloseAction:(id)sender
{
    UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to close this view?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        _PopupView.hidden = YES;
        
        [self dismissViewControllerAnimated:YES completion: nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion: nil];
        
    }];
    
    [AlertController addAction:OKAction];
    [AlertController addAction:cancelAction];
    
    [self presentViewController: AlertController animated:YES completion:nil];

}


-(IBAction)btnOpenDoorAction:(id)sender
{
    [self operateDoor];
}


-(void)showTimer
{
    _PopupView.hidden = NO;
    _lblTimer.hidden = NO;
    _btnOpenDoor.hidden = YES;
    _btnOpenMap.hidden = YES;
    
    stopTimer = nil;
    
    secondsLeft = 05;
    
    [self performSelector:@selector(startPressed:) withObject:nil afterDelay:0.0];
    
    [self operateDoor];
    
}
    
    
-(IBAction)startPressed:(id)sender{
    
    running = TRUE;
    
    millisecond = 10;
    
    second = secondsLeft;
    
    if (stopTimer == nil) {
        
        stopTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     target:self
                                                   selector:@selector(updateTimer)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    
}
    
    
-(void)updateTimer{
    
    if ((millisecond == 0) && (second == 0))
    {
        [stopTimer invalidate];
        
        stopTimer = nil;
        
        _lblTimer.hidden = YES;
        _btnOpenDoor.hidden = NO;
        _btnOpenMap.hidden = NO;
        
    }
    else if ((second>0)||(millisecond>0)) {
        
        if (millisecond == 0)
        {
            millisecond = 10;
            
            second --;
        }
        else if (millisecond == 10)
        {
            second --;
        }
        
        millisecond--;
        
    }
    
    _lblTimer.text = [NSString stringWithFormat:@"%02.0f:%02.0f", second,millisecond];
    
}
    

-(void) setupNavigine{
    
    [[NavigineCore defaultCore] startNavigine];
    [[NavigineCore defaultCore] startPushManager];
    [[NavigineCore defaultCore] startVenueManager];
    
    NCLocation *location = [NavigineCore defaultCore].location;
    NCSublocation *sublocation = [location subLocationAtIndex:0];
    
}

-(void)getDeviceUpdation
{
    [self startStandardUpdates];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.activityType = kCLLocationAccuracyNearestTenMeters;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 1; // meters
    
    [self.locationManager startUpdatingLocation];
    
    if(IS_OS_8_OR_LATER) {
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    count = 0;
    
    CLLocation *mostRecentLocation = locations.lastObject;
    
    Lastlatitude = mostRecentLocation.coordinate.latitude;
    
    Lastlongitude = mostRecentLocation.coordinate.longitude;
    
    NSLog(@"Current location: %@ %@", @(mostRecentLocation.coordinate.latitude), @(mostRecentLocation.coordinate.longitude));
    
}


- (void) navigationTick: (NSTimer *)timer
{
    timerforApi += 0.1;
    if (timerforApi >= 300.0) {
        
        timerforApi = 0.0;
        [self performSelector:@selector(apiforCMX)];
        
    } else {
        
        NavigationResults res = [[NavigineCore defaultCore] getNavigationResults];
        
        if (res.ErrorCode == 0){
            
            //NSLog(@"RESULT: %lf %lf",res.X,res.Y);
            NSDictionary* dic = [self didEnterZoneWithPoint:CGPointMake(res.kX, res.kY)];
            
            if ([[dic allKeys] containsObject:@"name"]) {
                
                //            NSLog(@"zone detected:%@",dic);
                
                NSString* zoneName = [dic objectForKey:@"name"];
                
                if (!_currentZoneName) {
                    
                    _currentZoneName = zoneName;
                    
                    [self enterZoneWithZoneName:_currentZoneName];
                    
                } else {
                    
                    if (![zoneName isEqualToString:_currentZoneName]) {
                        
                        [self exitZoneWithZoneName:_currentZoneName];
                        _currentZoneName = zoneName;
                        [self enterZoneWithZoneName:_currentZoneName];
                        
                    } else {
                        
                    }
                }
                
                
            } else {
                
                if (_currentZoneName) {
                    
                    [self exitZoneWithZoneName:_currentZoneName];
                    _currentZoneName = nil;
                    
                } else {
                    
                }
                
            }
            
        }
        else{
            
            NSLog(@"Error code:%zd",res.ErrorCode);
        }
    }
    
}



- (NSDictionary *)didEnterZoneWithPoint:(CGPoint)currentPoint {
    
    NSDictionary* zone = nil;
    
    if (_zoneArray) {
        
        for (NSInteger i = 0; i < [_zoneArray count]; i++) {
            
            NSDictionary* dicZone = [_zoneArray objectAtIndex:i];
            
            NSArray* coordinates = [dicZone objectForKey:@"coordinates"];
            
            if ([coordinates count]>0) {
                
                UIBezierPath* path = [[UIBezierPath alloc]init];
                
                for (NSInteger j=0; j < [coordinates count]; j++) {
                    
                    NSDictionary* dicCoordinate = [coordinates objectAtIndex:j];
                    
                    if ([[dicCoordinate allKeys] containsObject:@"kx"]) {
                        
                        float xPoint = [[dicCoordinate objectForKey:@"kx"] floatValue];
                        float yPoint = [[dicCoordinate objectForKey:@"ky"] floatValue];
                        
                        CGPoint point = CGPointMake(xPoint, yPoint);
                        
                        if (j == 0) {
                            
                            [path moveToPoint:point];
                            
                        } else {
                            
                            [path addLineToPoint:point];
                        }
                    }
                }
                
                [path closePath];
                
                if ([path containsPoint:currentPoint]) {
                    
                    zone = [NSDictionary dictionaryWithDictionary:dicZone];
                    
                    break;
                    
                } else {
                    
                    zone = nil;
                    
                }
            }
        }
        
    } else {
        
    }
    
    return zone;
}


-(void)enterZoneWithZoneName:(NSString *)zoneName {
    
    if (zoneName) {
        
        if ([zoneName isEqualToString:@"conference area"]) {
            
            [self lightOnAndOff:YES];
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults setBool:YES forKey:@"isConferenceArea"];
            
            [Userdefaults synchronize];
            
            if ([Userdefaults boolForKey:@"speechConference"]==0) {
                
                AVSpeechUtterance *conference = [AVSpeechUtterance
                                                 speechUtteranceWithString:@"You have entered into the conference room. While you be sitted, please order refreshment from our pantryman."];
                
                AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
                
                [synth speakUtterance:conference];
                
                [Userdefaults setBool:true forKey:@"speechConference"];
                
                [Userdefaults synchronize];
            }
            
        }
        else if ([zoneName isEqualToString:@"PreEntry"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults setBool:YES forKey:@"isPreEntry"];
            
            //[Userdefaults setBool:false forKey:@"restrictedZone"];
            
            [Userdefaults synchronize];

        }
        else if ([zoneName isEqualToString:@"entry area"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            BOOL welComeFired = [Userdefaults boolForKey:@"welComeFired"];
            
            if (welComeFired==0) {
                
                [self getDeviceInZone];
                
                if (isLocalFire==0) {
                    
                    isLocalFire = YES;
                    
                    [self startLocalNotification];
                }
            }
            
            [self showTimer];
            
            [self performSelector:@selector(operateDoor) withObject:nil afterDelay:2.0];
            
        
            if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
                
                NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
                
                NSString *userType = [userDict objectForKey:@"usertype"];
                
                if ([userType isEqualToString:@"Guest"]) {
                    
                    if ([meetingsArr count]>0) {
                        
                        [self checkGuestHaveMeeting:meetingsArr];
                        
                    }
                    else
                    {
                        [self performSelector:@selector(checkGuestHaveMeeting:) withObject:meetingsArr afterDelay:0.2];
                    }
                    
                }

            }
            
        }
        else if ([zoneName isEqualToString:@"developer bay"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            [self lightOnAndOff:NO];
        }
        
    }
    
}


-(void)exitZoneWithZoneName:(NSString *)zoneName {
    
    if (zoneName) {
        
        if ([zoneName isEqualToString:@"conference area"]) {
            
            [self lightOnAndOff:NO];
            
            [Userdefaults setBool:false forKey:@"speechConference"];
            
            [Userdefaults setBool:YES forKey:@"isConferenceArea"];
            
            [Userdefaults synchronize];
            
        }
        else if ([zoneName isEqualToString:@"entry area"])
        {
            [Userdefaults setBool:NO forKey:@"isPreEntry"];
            
            [Userdefaults setBool:NO forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            isLocalFire = NO;
        }
    }
}


-(void)getZone{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"https://api.navigine.com/zone_segment/getAll?userHash=0F17-DAE1-4D0A-1778&sublocationId=3247"];
    
    [manager GET:host_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        _zoneArray = [NSArray arrayWithArray:[dict objectForKey:@"zoneSegments"]];
        
        NSLog(@"zoneArray: %@", _zoneArray);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        
    }];
    
}

    
-(void)OpenMap
{
    UIAlertController *AlertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to open the map?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BeaconFlow" bundle:[NSBundle mainBundle]];
        
        IndoorMapViewController *indoorMap = [storyboard instantiateViewControllerWithIdentifier:@"IndoorMapViewController"];
        
        [self.navigationController pushViewController:indoorMap animated:YES];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion: nil];
        
    }];
    
    [AlertController addAction:OKAction];
    [AlertController addAction:cancelAction];
    
    [self presentViewController: AlertController animated:YES completion:nil];
    
}


-(void)operateDoor{
    
    [SVProgressHUD showWithStatus:@"Please Wait..."];
    
    NSDictionary *params = @{@"userid":userId,@"doorstatus":@"0",@"firefrom":@"app"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"http://eegrab.com/smartoffice/door_status.php"];
    
    [manager POST:host_url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *msg = [responseDict objectForKey:@"status"];
        
        if ([msg isEqualToString:@"success"]) {
            
            if ([Userdefaults boolForKey:@"isPreEntry"]==NO) {
                
                [stopTimer invalidate];
                
                _lblTimer.hidden = YES;
                _btnOpenDoor.hidden = NO;
                _btnOpenMap.hidden = NO;
                
            }
            
        }
        
        [SVProgressHUD dismiss];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [self performSelector:@selector(operateDoor) withObject:nil afterDelay:2.0];
        
        [SVProgressHUD dismiss];
        
    }];
    
}

    
-(void)lightOnAndOff:(BOOL)status
{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        // PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setOnBool:status];
        
        [lightState setHue:[NSNumber numberWithInt:33410]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            
//            // create a new style
//            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
//            
//            // this is just one of many style options
//            style.messageColor = [UIColor whiteColor];
//            
//            if (status) {
//                
//                toastMsg = @"Light is on.";
//            }
//            else
//            {
//                toastMsg = @"Light is off.";
//            }
//            
//            // present the toast with the new style
//            [self.view.window makeToast:toastMsg
//                        duration:2.0
//                        position:CSToastPositionCenter
//                           style:style];
//            
//            // or perhaps you want to use this style for all toasts going forward?
//            // just set the shared style and there's no need to provide the style again
//            [CSToastManager setSharedStyle:style];
//            
//            // toggle "tap to dismiss" functionality
//            [CSToastManager setTapToDismissEnabled:YES];
            
            if (errors != nil) {
                
               // NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
               // NSLog(@"Response: %@",message);
                
            }
            
        }];
    }
}

-(void)checkGuestHaveMeeting:(NSArray *)arrMeetings
{
    for (id object in arrMeetings) {
        
        NSDictionary *dict = object;
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"])
        {
            
            NSString *date = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
            
            NSString *dateString = [NSString stringWithFormat:@"%@",date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm a"];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateString];
            
            NSString *currentdate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterFullStyle];
            
            NSDate *cDate = [dateFormatter dateFromString:currentdate];
            
            NSString *givendate = [NSDateFormatter localizedStringFromDate:dateFromString
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterFullStyle];
            
            NSDate *gDate = [dateFormatter dateFromString:givendate];
            
            NSCalendar *c = [NSCalendar currentCalendar];
            
            NSDateComponents *components = [c components:kCFCalendarUnitSecond fromDate:cDate toDate:gDate options:0];
            
            NSInteger diff = components.minute;
            
            if (diff<=(30*60)) {
                
                NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
                
                NSString *userName = [NSString stringWithFormat:@"%@ %@",[userDict objectForKey:@"fname"],[userDict objectForKey:@"lname"]];
                
                [self sendPushEmployee:[dict objectForKey:@"id"] withBody:[NSString stringWithFormat:@"%@ has arrived",userName]];
                
            }
            
        }
        
    }
    
}


//[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connect to WiFi", @"No bridge found alert title")
//                           message:NSLocalizedString(@"Choose FNSPL and type Plz@ccess as password.", @"No bridge found alert message")
//                          delegate:self
//                 cancelButtonTitle:nil
//                 otherButtonTitles:NSLocalizedString(@"Retry", @"No bridge found alert retry button"),NSLocalizedString(@"Cancel", @"No bridge found alert cancel button"), nil];


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(collectionView == _collectionViewOptions){
        
        return [options count];
        
    }else{
        
        return [meetingsArr count];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
        return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == _collectionViewOptions){
        
    static NSString *identifier = @"HomeOptionsCollectionViewCell";
    
    HomeOptionsCollectionViewCell *cell = (HomeOptionsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dict = [options objectAtIndex:indexPath.row];
        
    cell.lblTitle.text = [dict objectForKey:@"title"];
        
    cell.lblSubtiltle.text = [dict objectForKey:@"subtitle"];
        
    cell.transView.layer.cornerRadius = 5.0;
        
    cell.imgView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
        
    if([cell.lblTitle.text isEqualToString:@"Inbox"]){
        
        
//        if (unreadMsgCount==0) {
        
            cell.alertBackVw.hidden = YES;
            cell.alertlbl.hidden = YES;
//        }
//        else
//        {
//            cell.alertBackVw.layer.cornerRadius = cell.alertBackVw.frame.size.width/2;
//            cell.alertlbl.text = [NSString stringWithFormat:@"%d",unreadMsgCount];
//        }
        
    }else if([cell.lblTitle.text isEqualToString:@"Manage"]){
        
        cell.alertBackVw.hidden = YES;
        cell.alertlbl.hidden = YES;
        cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, cell.imgView.frame.origin.y+10, cell.imgView.frame.size.width-30, cell.imgView.frame.size.height-30);

    }else if([cell.lblTitle.text isEqualToString:@"Order"]){
        
        cell.alertBackVw.hidden = YES;
        cell.alertlbl.hidden = YES;
        cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, 0, cell.imgView.frame.size.width+30, cell.imgView.frame.size.height+30);
        
    }else if([cell.lblTitle.text isEqualToString:@"Schedule"]){
        
        cell.alertBackVw.hidden = YES;
        cell.alertlbl.hidden = YES;
        cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, cell.imgView.frame.origin.y, cell.imgView.frame.size.width, cell.imgView.frame.size.height);
        
    }
    
      return cell;
        
    }else{
        
        static NSString *identifier = @"UpcomingMeetingsCollectionViewCell";
        
        UpcomingMeetingsCollectionViewCell *cell = (UpcomingMeetingsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        NSDictionary *dict = [meetingsArr objectAtIndex:indexPath.row];
        
        NSDictionary *dictUserDetails = [dict objectForKey:@"userdetails"];
        
        if ([[dictUserDetails allKeys] containsObject:@"department"])
        {
            if (![self isEmptyString:[dict objectForKey:@"department"]]) {
                
                cell.lblDepartment.text = [dictUserDetails objectForKey:@"department"];
            }
            
            cell.lblMeetingWith.text =@"";
            cell.lblPhone.text = @"";
            
        }
        else
        {
            NSDictionary *guest = [dict objectForKey:@"guest"];
            
            if (![self isEmptyString:[guest objectForKey:@"contact"]]) {
                
                cell.lblMeetingWith.text = [guest objectForKey:@"contact"];
            }
            
            if (![self isEmptyString:[guest objectForKey:@"company"]]) {
                
                cell.lblDepartment.text = [guest objectForKey:@"company"];
            }
            
            if (![self isEmptyString:[guest objectForKey:@"phone"]]) {
                
                cell.lblPhone.text = [guest objectForKey:@"phone"];
            } 
        }
        
        cell.lblDateTime.text = [NSString stringWithFormat:@"%@,%@",[dict objectForKey:@"fdate"],[NSString stringWithFormat:@"%@ - %@",[dict objectForKey:@"fromtime"],[dict objectForKey:@"totime"]]];
        
        
        cell.VwMeeting.layer.cornerRadius = 5.0;
        
        
      return cell;

    }
}


-(BOOL)isEmptyString:(NSString *)string;
{
    // Note that [string length] == 0 can be false when [string isEqualToString:@""] is true, because these are Unicode strings.
    
    if (((NSNull *) string == [NSNull null]) || (string == nil) ) {
        return YES;
    }
    string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _collectionViewUpcoming.frame.size.width;
    float currentPage = _collectionViewUpcoming.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f))
    {
        _pageControl.currentPage = currentPage + 1;
    }
    else
    {
        _pageControl.currentPage = currentPage;
    }
    
    NSLog(@"Page Number : %ld", (long)_pageControl.currentPage);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == _collectionViewOptions){
        
       return CGSizeMake((self.view.frame.size.width/2.25),110);
        
    }else{
        
       return CGSizeMake((self.collectionViewUpcoming.frame.size.width/2-1.5),110);

    }
}

- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView == _collectionViewOptions) {
        return 10.0f;
    }
    
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if(collectionView == _collectionViewOptions){
        
        return UIEdgeInsetsMake(10, 10,10,10);

    }
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == _collectionViewOptions){
        
    _collectionViewOptions.frame = CGRectMake(_collectionViewOptions.frame.origin.x, _collectionViewOptions.frame.origin.y, _collectionViewOptions.frame.size.width, _collectionViewOptions.contentSize.height);
        
    _midView.frame = CGRectMake(_midView.frame.origin.x, _collectionViewOptions.frame.size.height+5, _midView.frame.size.width, _midView.frame.size.height);
        
    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, _midView.frame.origin.y+_midView.frame.size.height + 8, _bottomView.frame.size.width, _bottomView.frame.size.height+5);
        
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _bottomView.frame.origin.y+_bottomView.frame.size.height+60);
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Messages" bundle:[NSBundle mainBundle]];

    if (collectionView == _collectionViewOptions) {
        
        switch (indexPath.row) {
            case 0:
                self.tabBarController.selectedIndex = 2;
                
                break;
            case 1:
                
                [self OrderFood];
                break;
            case 2:
                
                inbox = [storyboard instantiateViewControllerWithIdentifier:@"inbox"];
                [self.navigationController pushViewController:inbox animated:YES];
                break;
            case 3:
                
                self.tabBarController.selectedIndex = 1;
                
                break;
                
            default:
                break;
        }

    }
    else{
        
        self.tabBarController.selectedIndex = 1;
        
    }
    
    
}

-(void)OrderFood
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PantryManagement" bundle:[NSBundle mainBundle]];
    
    PantryViewController *pantryVC = [storyboard instantiateViewControllerWithIdentifier:@"PantryViewController"];
    
    [self.navigationController pushViewController:pantryVC animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnDrawerMenuDidTap:(id)sender {
    //[self performSegueWithIdentifier:@"segueToDrawer" sender:self];
    
    //[self presentViewController:vc animated:YES completion:nil];
    //[self rotateView:_scrollView AtAngle:90];
//    profSlide = [[DrawerView alloc] init];
//    profSlide.frame = self.view.bounds;
//    profSlide.backgroundColor = [UIColor clearColor];
//   // profSlide.delegate = self;
//    [self.view addSubview:profSlide];
    
    [[NSNotificationCenter defaultCenter]
         postNotificationName:@"OpenDrawer"
         object:self];
    
}

-(void)CtrlViewController:(CtrlViewController *)obj didTapOnMap:(BOOL)isClicked
{
    [obj dismissViewControllerAnimated:YES completion:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BeaconFlow" bundle:[NSBundle mainBundle]];
    
    IndoorMapViewController *indoorMap = [storyboard instantiateViewControllerWithIdentifier:@"IndoorMapViewController"];
    
    [self.navigationController pushViewController:indoorMap animated:YES];
}


//-(void)rotateView:(UIView *)rotatingView AtAngle:(CGFloat)angle{
//    CGFloat radians = angle/180.0 *M_PI;
//    //let radians = angle / 180.0 * CGFloat(M_PI)
//    CGAffineTransform *trans;
//    CGAffineTransform rotation = CGAffineTransformRotate(*trans, radians);
//    self.transform = rotation;
//}

-(void)getRegKey{
    
    [SVProgressHUD show];
    
    NSString *deviceToken = [Userdefaults objectForKey:@"deviceToken"];
    
    NSDictionary *params = @{@"userid":userId,@"reg":deviceToken,@"type":@"Ios"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_regkey.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            meetingsArr = [responseDict objectForKey:@"apointments"];
            
            [_collectionViewUpcoming reloadData];
            
            self.pageControl.numberOfPages = [meetingsArr count]/2;
            
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
        
        [self performSelector:@selector(getRegKey:) withObject:userId afterDelay:0.0];
        
        [SVProgressHUD dismiss];
        
    }];
    
}

-(void)getTimeCheckforUpcomingMeeting{
    
    //if([self notEmptyChecking] == NO){return;}
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@checkTime.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        NSString *success = [responseDict objectForKey:@"status"];
        
        [SVProgressHUD dismiss];
        
        if ([success isEqualToString:@"success"]) {
        
            meetingsArr = [responseDict objectForKey:@"apointments"];
            
            if ([meetingsArr count]>0) {
                
                for (id object in meetingsArr) {
                    
                    NSDictionary *dict = object;
                    
                    if ([[dict objectForKey:@"status"] isEqualToString:@"confirm"]) {
                        
                        [self checkDayofMeeting:meetingsArr];
                        
                        [self checkHourofMeeting:meetingsArr];
                    }
                    
                }
            }
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


-(void)getUpcomingMeetings{
    
    //if([self notEmptyChecking] == NO){return;}
    
    if ([userId length]>0) {
        
        [SVProgressHUD show];
        
        NSDictionary *params = @{@"userid":userId};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        NSString *host_url = [NSString stringWithFormat:@"%@upcoming_appointments.php",BASE_URL];
        
        [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *responseDict = responseObject;
            NSString *success = [responseDict objectForKey:@"status"];
            
            if ([success isEqualToString:@"success"]) {
                
                [SVProgressHUD dismiss];
                
                meetingsArr = [responseDict objectForKey:@"apointments"];
                
                //NSLog(@"meetingsArr: %@", meetingsArr);
                
                [self CheckandSetNotification:meetingsArr];
                
                [self checkDayofMeeting:meetingsArr];
                
                [self checkHourofMeeting:meetingsArr];
                
                //[self checkGuestHaveMeeting:meetingsArr];
                
                [_collectionViewUpcoming reloadData];
                
                self.pageControl.numberOfPages = [meetingsArr count]/2;
                
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


-(void)checkDayofMeeting:(NSArray *)arrMeetings
{
    for (id object in arrMeetings) {
        
        NSDictionary *dict = object;
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"])
        {
            NSString *date = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
            
            NSString *dateString = [NSString stringWithFormat:@"%@",date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd-yyyy"];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateString];
            
            NSString *currentdate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterFullStyle];
            
            NSString *givendate = [NSDateFormatter localizedStringFromDate:dateFromString
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterFullStyle];
            
            
            if ([currentdate isEqualToString:givendate]) {
                
                [self DayOfMeeting];
                
            }
            
         }
        
      }
        
}


-(void)checkHourofMeeting:(NSArray *)arrMeetings
{
    for (id object in arrMeetings) {
        
        NSDictionary *dict = object;
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"])
        {
            NSString *date = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
            
            NSString *dateString = [NSString stringWithFormat:@"%@",date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm a"];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateString];
            
            NSString *currentdate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterFullStyle];
            
            NSDate *cDate = [dateFormatter dateFromString:currentdate];
            
            NSString *givendate = [NSDateFormatter localizedStringFromDate:dateFromString
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterFullStyle];
            
            NSDate *gDate = [dateFormatter dateFromString:givendate];
            
            NSCalendar *c = [NSCalendar currentCalendar];
            
            NSDateComponents *components = [c components:kCFCalendarUnitSecond fromDate:cDate toDate:gDate options:0];
            
            NSInteger diff = components.minute;
            
            if (diff<=(30*60)) {
                
                [self DayOfMeeting];
                
            }
            
        }
        
    }
    
}


-(void)CheckandSetNotification:(NSArray *)arrMeetings
{
    for (id object in arrMeetings) {
        
        NSDictionary *dict = object;
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"])
        {
            NSString *date = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
            
            NSString *time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"time"]];
            
            NSString *dateString = [NSString stringWithFormat:@"%@ %@",date,time];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm"];
            
            NSDate *dateFromString = [[NSDate alloc] init];
            dateFromString = [dateFormatter dateFromString:dateString];
            
            NSDate *currentDate = [NSDate date];

            NSTimeInterval secondsBetween = [currentDate timeIntervalSinceDate:dateFromString];
            
            int minutes = secondsBetween / 60;
            
            if(minutes <= 30)
            {
                [Userdefaults setBool:YES forKey:@"isConfirmFound"];
                
                [Userdefaults synchronize];
            }
            
        }
    }
}


-(void)ShowNotificationsOfMeetings:(NSDate *)date withMessage:(NSString *)msgStr
{
    //NSLog(@"startLocalNotification");
    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = date;
//    notification.alertBody = msgStr;
//    notification.timeZone = [NSTimeZone localTimeZone];
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.applicationIconBadgeNumber = 10;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


-(void)sendPushEmployee:(NSString *)appid withBody:(NSString *)body{
    
    // [SVProgressHUD show];
    
    NSDictionary *params;
    
    params = @{@"userid":userId,@"appid":appid,@"body":body};
    
    NSLog(@"params :%@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@customepush_employee.php",BASE_URL];
    
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            //  [SVProgressHUD dismiss];
            
            
            
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
        
        [SVProgressHUD dismiss];
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}


-(void)sendPushGuest:(NSString *)appid withBody:(NSString *)body{
    
    // [SVProgressHUD show];
    
    NSDictionary *params;
    
    params = @{@"userid":userId,@"appid":appid,@"body":body};
    
    NSLog(@"params :%@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@customepush_guest.php",BASE_URL];
    
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            //  [SVProgressHUD dismiss];
            
            
            
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
        
        [SVProgressHUD dismiss];
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
}


-(void)DayOfMeeting{
    
    NSDictionary *params;
    
    params = @{@"userid":userId};
    
    NSLog(@"params :%@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@checkTime.php",BASE_URL];
    
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            NSLog(@"success");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self DayOfMeeting];
        
    }];
    
}


-(void)getAllMessages
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@all_messages.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSString *success = [dict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            NSArray *inboxArr = [dict objectForKey:@"inbox"];
            NSArray *outboxArr = [dict objectForKey:@"outbox"];
            
            if (([inboxArr count]==0) && ([outboxArr count]==0)) {
                
                unreadMsgCount = 0;
                
            } else {
                
                if ([inboxArr count]>0) {
                    
                    for (NSDictionary *dict in inboxArr) {
                        
                        NSString *status = [dict objectForKey:@"status"];
                        
                        if([status isEqualToString:@"unread"])
                        {
                            unreadMsgCount++;
                        }
                    }
                    
                    
                }
                
                if ([outboxArr count]>0) {
                    
                    for (NSDictionary *dict in outboxArr) {
                        
                        NSString *status = [dict objectForKey:@"status"];
                        
                        if([status isEqualToString:@"unread"])
                        {
                            unreadMsgCount++;
                        }
                    }
                    
                    
                }
            }
    
            [self.collectionViewOptions reloadData];
            
        }else{
            
            [SVProgressHUD dismiss];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Problem to get messages, please check your internet connection & restart the app."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
    }];
}


@end
