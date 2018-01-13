//
//  AppDelegate.m
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LGSideMenuController.h"
#import "RightSideDrawerViewController.h"
#import "MessagesViewController.h"
#import "LoginViewController.h"
#import "PHLoadingViewController.h"

@import GoogleMaps;
@import UserNotifications;

@interface AppDelegate (){
    RightSideDrawerViewController *drawer;
    MessagesViewController *inbox;
    LoginViewController *login;
    UIButton *button;
}

@property (nonatomic, strong) PHLoadingViewController *loadingView;
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@property (nonatomic, strong) UIAlertView *noConnectionAlert;
@property (nonatomic, strong) UIAlertView *noBridgeFoundAlert;
@property (nonatomic, strong) UIAlertView *authenticationFailedAlert;

@property (nonatomic, strong) PHBridgePushLinkViewController *pushLinkViewController;
@property (nonatomic, strong) PHBridgeSelectionViewController *bridgeSelectionViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    
    [self.window.rootViewController.view addGestureRecognizer:swipeleft];
    
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    
    [drawer.view addGestureRecognizer:swiperight];
    
    
    db = [Database sharedDB];
    
    [db createdb];
    
    NSString *strPath = [db getDBPath];
    
    NSLog(@"%@",strPath);
    
    [self startStandardUpdates];
    
    [GMSServices provideAPIKey:API_KEY];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOpenDrawerNotification:)
                                                 name:@"OpenDrawer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveExitDrawerNotification:)
                                                 name:@"ExitDrawer"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveClickedDrawerOptionNotification:)
                                                 name:@"ClickedDrawerOption"
                                               object:nil];
    
    
    
    if ([Userdefaults objectForKey:@"dateNotificationValue"]==nil) {
        
        [Userdefaults setObject:@"YES" forKey:@"dateNotificationValue"];
        
        [Userdefaults setBool:YES forKey:@"dateNotification"];
        
        [Userdefaults synchronize];
    }
    
    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
    
    [dt setDateFormat:@"yyyy-MM-dd"];
    
    NSString *RecordedDateStr = [Userdefaults objectForKey:@"DateRecorded"];
    
    NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
    
    NSDate *RecordedDate = [dt dateFromString:[NSString stringWithFormat:@"%@",RecordedDateStr]];
    
    NSComparisonResult compare = [currentDate compare:RecordedDate];
    
    if (compare==NSOrderedAscending){
        
        [Userdefaults removeObjectForKey:@"DateRecorded"];
    }
    
    [Userdefaults setBool:NO forKey:@"isLocationRequired"];
    
    [Userdefaults setBool:NO forKey:@"isBluetoothAlerton"];
    
    [Userdefaults setBool:NO forKey:@"isMapOpen"];
    
    [Userdefaults setBool:NO forKey:@"isAlertShown"];
    
    [Userdefaults setBool:NO forKey:@"isPreEntry"];
    
    [Userdefaults setBool:NO forKey:@"isETAFiredOnce"];
    
    [Userdefaults setBool:NO forKey:@"ETAFiredOnceForDetails"];
    
    [Userdefaults setBool:NO forKey:@"ETALoopFiredOnceForDetails"];
    
    [Userdefaults setBool:NO forKey:@"inRange"];
    
    
    [Userdefaults synchronize];
    
    
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [[NSUserDefaults standardUserDefaults] setObject:uniqueIdentifier forKey:@"device_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    [application setApplicationIconBadgeNumber:0];
    
    [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    [self registerForRemoteNotifications:application];
    
    [Fabric with:@[[Crashlytics class]]];
    
    
    if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
        
        userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
        
        [self getUpcomingMeetings];
    }
    
    
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:YES];
    
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    
    [self enableLocalHeartbeat];


    return YES;
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
    self.locationManager.distanceFilter = 10; // meters
    
    [self.locationManager startUpdatingLocation];
    
    if(IS_OS_8_OR_LATER) {
        
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    
}


-(void)IsMeetingToday:(CLLocation *)location
{
    if ([meetingsArr count]>0) {
        
        for (id object in meetingsArr) {
            
            NSDictionary *dict = object;
            
            NSString *status = [dict objectForKey:@"status"];
            
            if([status isEqualToString:@"confirm"])
            {
                NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                
                [dt setDateFormat:@"yyyy-MM-dd"];
                
                NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                
                NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
                
                NSComparisonResult compare = [currentDate compare:fromDate];
                
                if (compare==NSOrderedSame) {
                    
                    BOOL isReachedOffice = [Userdefaults boolForKey:[NSString stringWithFormat:@"isReachedOfficeForAppId:%@",[dict objectForKey:@"id"]]];
                    
                    if (isReachedOffice==0) {
                    
                        [self checkETA:_locationManager.location];
                        
                        [self reverseGeoCode:_locationManager.location];
                        
                    }
                }
            }
            
        }
        
    }
}


-(void)reverseGeoCode:(CLLocation *)location
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *hostUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", location.coordinate.latitude, location.coordinate.longitude];;
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSArray *arrResults = [dict objectForKey:@"results"];
        
        if ([arrResults count]>0) {
            
            NSDictionary *address_components = [arrResults objectAtIndex:0];
            
            NSString *strAddress1 = [address_components objectForKey:@"formatted_address"];
            
            NSString *strAddress2 = [strAddress1 stringByReplacingOccurrencesOfString:@", " withString:@","];
            
            NSString *strAddress3 = [strAddress2 stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            //NSLog(@"strAddress: %@", strAddress3);
            
            strAddress = strAddress3;
            
            [self showETA];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
}


-(void)showETA
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *hostUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=future+netwings&key=%@",strAddress,API_KEY];
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSArray *rows = [dict objectForKey:@"rows"];
        
        if ([rows count]>0) {
            
            NSDictionary *elements = [rows objectAtIndex:0];
            
            NSArray *details = [elements objectForKey:@"elements"];
            
            NSDictionary *ETAinfo = [details objectAtIndex:0];
            
            NSDictionary *distanceDic = [ETAinfo objectForKey:@"distance"];
            
            NSDictionary *durationDic = [ETAinfo objectForKey:@"duration"];
            
            distance = [distanceDic objectForKey:@"text"];
            
            duration = [durationDic objectForKey:@"text"];
            
            NSArray *arrUnit = [distance componentsSeparatedByString:@" "];
            
            [self checkETA:_locationManager.location];
            
            if ([meetingsArr count]>0) {
                
                for (id object in meetingsArr) {
                    
                    NSDictionary *dict1 = object;
                    
                    NSString *status = [dict1 objectForKey:@"status"];
                    
                    if([status isEqualToString:@"confirm"])
                    {
                        BOOL isReachedOffice = [Userdefaults boolForKey:[NSString stringWithFormat:@"isReachedOfficeForAppId:%@",[dict objectForKey:@"id"]]];
                        
                        if (isReachedOffice==0) {
                            
                            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                            
                            [dt setDateFormat:@"yyyy-MM-dd"];
                            
                            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                            
                            [dt setLocale:locale];
                            
                            NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                            
                            NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
                            
                            NSComparisonResult compare = [currentDate compare:fromDate];
                            
                            if (compare==NSOrderedSame) {
                                
                                //NSString *Fdate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
                                
                                NSString *time = [NSString stringWithFormat:@"%@",[dict1 objectForKey:@"fromtime"]];
                                
                                //NSString *dateString = [NSString stringWithFormat:@"%@ %@",Fdate,time];
                                
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                
                                [dateFormatter setDateFormat:@"hh:mm a"];
                                
                                NSDate *date = [dateFormatter dateFromString:time];
                                
                                [dateFormatter setDateFormat:@"HH:mm"];
                                
                                NSString *dateString = [dateFormatter stringFromDate:date];
                                
                                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                                
                                [dateFormatter setLocale:locale];
                                
                                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                                
                                NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                                
                                NSDate *currentTime= [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                                
                                
                                NSTimeInterval secondsBetween = [dateFromString timeIntervalSinceDate:currentTime];
                                
                                int minutes = secondsBetween / 60;
                                
                                if((minutes<=120)&&(minutes>0))
                                {
                                    if ([arrUnit containsObject:@"m"]||[arrUnit containsObject:@"km"])
                                    {
                                        NSString *strDetails = [NSString stringWithFormat:@"You are about %@ from FNSPL, estimated time of arrival %@",distance,duration];
                                        
                                        [self checkAndSendNotificationforPushType:@"time of arrival" withDetails:dict1 AndNotificationText:strDetails];
                                    }
                                    else
                                    {
                                        int meter = (int)[[arrUnit objectAtIndex:0] integerValue];
                                        
                                        NSString *strDetails = [NSString stringWithFormat:@"You are about %f from FNSPL, estimated time of arrival %@",(meter *FEET_TO_METERS),duration];
                                        
                                        [self checkAndSendNotificationforPushType:@"time of arrival" withDetails:dict1 AndNotificationText:strDetails];
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
            //NSLog(@"distance: %@", distance);
            // NSLog(@"duration: %@", duration);
            
            [Userdefaults setBool:NO forKey:@"isETALoopFiredOnce"];
            [Userdefaults synchronize];
            
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [Userdefaults setBool:NO forKey:@"isETALoopFiredOnce"];
        [Userdefaults synchronize];
        
    }];
    
    // https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=Washington,DC&destinations=New+York+City,NY&key=YOUR_API_KEY
    
}


-(void)checkETA:(CLLocation *)loc
{
    NSArray *arrDuration = [duration componentsSeparatedByString:@" "];
    
    if ([meetingsArr count]>0) {
        
        for (id object in meetingsArr) {
            
            NSDictionary *dict = object;
            
            NSString *status = [dict objectForKey:@"status"];
            
            if([status isEqualToString:@"confirm"])
            {
                NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                
                [dt setDateFormat:@"yyyy-MM-dd"];
                
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                
                [dt setLocale:locale];
                
                NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                
                NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
                
                NSComparisonResult compare = [currentDate compare:fromDate];
                
                if (compare==NSOrderedSame) {
                    
                    //NSString *Fdate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
                    
                    NSString *time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromtime"]];
                    
                    //NSString *dateString = [NSString stringWithFormat:@"%@ %@",Fdate,time];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    
                    [dateFormatter setDateFormat:@"hh:mm a"];
                    
                    NSDate *date = [dateFormatter dateFromString:time];
                    
                    [dateFormatter setDateFormat:@"HH:mm"];
                    
                    NSString *dateString = [dateFormatter stringFromDate:date];
                    
                    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                    
                    [dateFormatter setLocale:locale];
                    
                    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                    
                    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                    
                    NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                    
                    
                    NSTimeInterval secondsBetween = [dateFromString timeIntervalSinceDate:currentDate];
                    
                    int minutes = secondsBetween / 60;
                    
                    if (arrDuration == nil) {
                        
                        [self reverseGeoCode:_locationManager.location];
                        
                    }
                    else
                    {
                        int durationMin = (int)[[arrDuration objectAtIndex:0] integerValue];
                        
                        NSDictionary *dict1 = [dict objectForKey:@"guest"];
                        
                        if(minutes < durationMin)
                        {
                            int div = (durationMin - minutes);
                            
                            if ((div<=30) && (div>0))
                            {
                                NSString *strDetails = [NSString stringWithFormat:@"You are late for your meeting with %@, please reschedule the meeting.",[dict1 objectForKey:@"contact"]];
                                
                                [self checkAndSendNotificationforPushType:@"late" withDetails:dict AndNotificationText:strDetails];
                                
                                NSString *strID = [NSString stringWithFormat:@"%@",[[dict1 objectForKey:@"guest"] objectForKey:@"id"]];
                                
                                [self sendPushEmployee:strID withBody:[NSString stringWithFormat:@"%@ is late for the upcoming meeting with you. Please reschedule the meeting.",[dict1 objectForKey:@"employee_name"]]];
                                
                            }
                            
                        }
                        else if (minutes > durationMin)
                        {
                            int div = (minutes - durationMin);
                            
                            if ((div<=5) && (div>0)) {
                                
                                NSString *strDetails = [NSString stringWithFormat:@"You should step out now or you will be getting late for your meeting with %@.",[dict1 objectForKey:@"contact"]];
                                
                                [self checkAndSendNotificationforPushType:@"step out" withDetails:dict AndNotificationText:strDetails];
                            }
                            else if ((div<=15) && (div>5)) {
                                
                                NSString *strDetails = [NSString stringWithFormat:@"You have to start planning to go to Future Netwings or you will be getting late for your meeting with %@.",[dict1 objectForKey:@"contact"]];
                                
                                [self checkAndSendNotificationforPushType:@"planning" withDetails:dict AndNotificationText:strDetails];
                            }
                            
                            
                        }
                        else if (minutes == durationMin)
                        {
                            NSString *strDetails = [NSString stringWithFormat:@"You should step out now or you will be getting late for your meeting with %@.",[dict1 objectForKey:@"contact"]];
                            
                            [self checkAndSendNotificationforPushType:@"step out" withDetails:dict AndNotificationText:strDetails];
                        }
                        
                    }
                    
                }
                
            }
        }
    }
}


-(IBAction)startLocalNotification:(NSString *)str {
    
    NSString *str1 = str;
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:str1];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    
    [synth speakUtterance:utterance];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.alertBody = str1;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}


-(void)sendLat:(NSString *)latitude andlong:(NSString *)longitude{
    
    //[SVProgressHUD show];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"] integerValue]];
    
    NSDictionary *params = @{@"userid":userId,@"lat":latitude,@"lng":longitude};
    
    NSLog(@"params :%@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_distance.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *strDistance = [responseDict objectForKey:@"distance"];
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            //[SVProgressHUD dismiss];
            
            if((NSString *)[NSNull null] != strDistance)
            {
                if ([strDistance floatValue]<=2.0) {
                    
                    [Userdefaults setBool:NO forKey:@"isConfirmFound"];
                    
                    [Userdefaults synchronize];
                }
            }
            
        }else{
            
            NSString *msg = [responseDict objectForKey:@"message"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
            //[SVProgressHUD dismiss];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        //[SVProgressHUD dismiss];
        
    }];
    
}


-(void)checkAndSendNotificationforPushType:(NSString *)pushtype withDetails:(NSDictionary *)Dict AndNotificationText:(NSString *)strDetails
{
    NSString *strId = [NSString stringWithFormat:@"%@",[Dict objectForKey:@"id"]];
    
    NSMutableArray *arrETA = [db getETAbyAppointmentId:strId andPushtype:pushtype];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if ([arrETA count]>0) {
        
        NSString *isSendStr = [[arrETA objectAtIndex:0] objectForKey:@"isSend"];
        
        if ([isSendStr isEqualToString:@"YES"]) {
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [dateFormatter setLocale:locale];
            
            NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
            
            NSDate *fromDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",[[arrETA objectAtIndex:0] objectForKey:@"date"]]];
            
            NSComparisonResult compare = [currentDate compare:fromDate];
            
            if (compare==NSOrderedSame){
                
                NSString *time = [NSString stringWithFormat:@"%@",[[arrETA objectAtIndex:0] objectForKey:@"time"]];
                
                //NSString *dateString = [NSString stringWithFormat:@"%@ %@",Fdate,time];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setDateFormat:@"HH:mm"];
                
                NSDate *date = [dateFormatter dateFromString:time];
                
                NSString *dateString = [dateFormatter stringFromDate:date];
                
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                
                [dateFormatter setLocale:locale];
                
                [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                
                NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                
                NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                
                
                NSTimeInterval secondsBetween = [dateFromString timeIntervalSinceDate:currentDate];
                
                int minutes = secondsBetween / 60;
                
                if (minutes > 0)
                {
                    minutes = minutes;
                }
                else if (minutes < 0)
                {
                    minutes = (0 - minutes);
                }
                
                if ([pushtype isEqualToString:@"late"]) {
                    
                    if (minutes>=15) {
                        
                        [self startLocalNotification:strDetails];
                        
                        [self sendPushLogforAppid:[Dict objectForKey:@"id"] andFromid:userId andToid:[Dict objectForKey:@"employee_id"] andPushType:pushtype];
                        
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        
                        NSString *cDateStr = [dateFormatter stringFromDate:[NSDate date]];
                        
                        [dateFormatter setDateFormat:@"HH:mm"];
                        
                        NSString *cTimeStr = [dateFormatter stringFromDate:[NSDate date]];
                        
                        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                        
                        f.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSString *strId = [NSString stringWithFormat:@"%@",[Dict objectForKey:@"id"]];
                        
                        //NSNumber *myNumber = [f numberFromString:strId];
                        
                        if ([arrETA count]>0) {
                            
                            [db UpdateETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];
                        }
                        else
                        {
                            [db insertInETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];
                        }
                        
                    }
                }
                else
                {
                    if (minutes>=5) {
                        
                        [self startLocalNotification:strDetails];
                        
                        [self sendPushLogforAppid:[Dict objectForKey:@"id"] andFromid:userId andToid:[Dict objectForKey:@"employee_id"] andPushType:pushtype];
                        
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        
                        NSString *cDateStr = [dateFormatter stringFromDate:[NSDate date]];
                        
                        [dateFormatter setDateFormat:@"HH:mm"];
                        
                        NSString *cTimeStr = [dateFormatter stringFromDate:[NSDate date]];
                        
                        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                        
                        f.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSString *strId = [NSString stringWithFormat:@"%@",[Dict objectForKey:@"id"]];
                        
                        //NSNumber *myNumber = [f numberFromString:strId];
                        
                        if ([arrETA count]>0) {
                            
                            [db UpdateETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];
                        }
                        else
                        {
                            [db insertInETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];
                        }
                        
                    }
                }
            }
            
        }
        else
        {
            
            [self startLocalNotification:strDetails];
            
            [self sendPushLogforAppid:[Dict objectForKey:@"id"] andFromid:userId andToid:[Dict objectForKey:@"employee_id"] andPushType:pushtype];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSString *cDateStr = [dateFormatter stringFromDate:[NSDate date]];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            
            NSString *cTimeStr = [dateFormatter stringFromDate:[NSDate date]];
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            
            f.numberStyle = NSNumberFormatterDecimalStyle;
            
            NSString *strId = [NSString stringWithFormat:@"%@",[Dict objectForKey:@"id"]];
            
            //NSNumber *myNumber = [f numberFromString:strId];
            
            if ([arrETA count]>0) {
                
                [db UpdateETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];
            }
            else
            {
                [db insertInETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];
            }
            
        }
        
    }
    else
    {
        [self startLocalNotification:strDetails];
        
        [self sendPushLogforAppid:[Dict objectForKey:@"id"] andFromid:userId andToid:[Dict objectForKey:@"employee_id"] andPushType:pushtype];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *cDateStr = [dateFormatter stringFromDate:[NSDate date]];
        
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSString *cTimeStr = [dateFormatter stringFromDate:[NSDate date]];
        
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSString *strId = [NSString stringWithFormat:@"%@",[Dict objectForKey:@"id"]];
        
        //NSNumber *myNumber = [f numberFromString:strId];
        
        [db insertInETATableWithUserId:userId andAppointmentId:strId andToid:[Dict objectForKey:@"employee_id"] andPushtype:pushtype andDate:cDateStr andTime:cTimeStr andIsSend:@"YES"];

    }
    
}


-(void)GetDistance:(CLLocation *)location
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *hostUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=future+netwings&key=%@",strAddress,API_KEY];
    
    [manager GET:hostUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSArray *rows = [dict objectForKey:@"rows"];
        
        if ([rows count]>0) {
            
            NSDictionary *elements = [rows objectAtIndex:0];
            
            NSArray *details = [elements objectForKey:@"elements"];
            
            NSDictionary *ETAinfo = [details objectAtIndex:0];
            
            NSDictionary *distanceDic = [ETAinfo objectForKey:@"distance"];
            
            NSDictionary *durationDic = [ETAinfo objectForKey:@"duration"];
            
            distance = [distanceDic objectForKey:@"text"];
            
            duration = [durationDic objectForKey:@"text"];
            
            NSArray *arrUnit = [distance componentsSeparatedByString:@" "];
            
            if ([arrUnit count]>0) {
                
                NSString *addressStr = [arrUnit objectAtIndex:0];
                
                Dist = [addressStr doubleValue];
                
                if ([arrUnit containsObject:@"km"]) {
                    
                    Dist = Dist *100;
                }
             
            }
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
}


#pragma mark - Location Manager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
    
   // NSLog(@"didUpdateLocations: %@", _locationManager.location);
    
    [self locationSend];
    
    CLLocation *loc = [locations lastObject];
    
    if (loc!=nil)
    {
        //CLLocation *location = [[CLLocation alloc] initWithLatitude:22.573228 longitude:88.452763];
        
        //double Dist = [location distanceFromLocation:_locationManager.location];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        if ([meetingsArr count]>0) {
            
            [self GetDistance:_locationManager.location];
            
            if(Dist<=200)
            {
                [self checkUserArrivedOfficeOnMeetingTime:_locationManager.location];
                
            }
            else if (Dist>200)
            {
                //[self reverseGeoCode:_locationManager.location];
                
                //            [Userdefaults removeObjectForKey:@"DateRecorded"];
                //
                //            [Userdefaults synchronize];
            }
            
            
            if ([Userdefaults boolForKey:@"dateNotification"]==YES) {
                
                if ([Userdefaults boolForKey:@"isETAFiredOnce"]==YES) {
                    
                    if ([Userdefaults boolForKey:@"isETALoopFiredOnce"]==YES) {
                        
                        NSLog(@"No ETA fire");
                        
                    } else {
                        
                        [self performSelector:@selector(IsMeetingToday:) withObject:_locationManager.location afterDelay:300.0];
                        
                        [Userdefaults setBool:YES forKey:@"isETALoopFiredOnce"];
                        [Userdefaults synchronize];
                    }
                    
                } else {
                    
                    [self IsMeetingToday:_locationManager.location];
                    
                    [Userdefaults setBool:YES forKey:@"isETAFiredOnce"];
                    [Userdefaults synchronize];
                }
                
            }
        }
        
    }
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager error: %@", error.localizedDescription);
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusDenied) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorised" message:@"This app needs you to authorise locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else
        
        NSLog(@"Wrong location status");
}


-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ExitDrawer"
     object:self];

}

-(void)swiperightFromRoot:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //button.hidden = YES;
    //Do what you want here
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ExitDrawer"
     object:self];
    
}



- (void) receiveOpenDrawerNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"OpenDrawer"]){
        NSLog (@"Successfully received the OpenDrawer notification!");
//        self.window.rootViewController.view.frame = CGRectMake(-self.window.rootViewController.view.frame.size.width/2,self.window.rootViewController.view.frame.size.height/6 ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height/2);
        [UIView animateWithDuration:0.3 animations:^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MenuDrawerStoryboard" bundle:[NSBundle mainBundle]];
            drawer = [storyboard instantiateViewControllerWithIdentifier:@"RightSideDrawerViewController"];
            [UIView animateWithDuration:0.1 animations:^{
                [self.window addSubview:drawer.view];
                //[self.window bringSubviewToFront:self.window.rootViewController];
            }];
            self.window.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
            self.window.rootViewController.view.frame = CGRectMake(-100,self.window.rootViewController.view.frame.origin.y ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height);
            button = [[UIButton alloc]initWithFrame:self.window.rootViewController.view.bounds];
            [button addTarget:self action:@selector(exitDrawerFromRoot:) forControlEvents:UIControlEventTouchUpInside];
            [self.window.rootViewController.view addSubview:button];
            UISwipeGestureRecognizer * swiperightFromRoot=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperightFromRoot:)];
            swiperightFromRoot.direction=UISwipeGestureRecognizerDirectionRight;
            [button addGestureRecognizer:swiperightFromRoot];

            // [storyboard instantiateViewControllerWithIdentifier:@"RightSideDrawerViewController"];
            
        }];
        
        [self.window sendSubviewToBack:drawer.view];
    }
    
}


-(void)exitDrawerFromRoot:(UIButton *)sender{
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ExitDrawer"
     object:self];
}


- (void) receiveExitDrawerNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"ExitDrawer"]){
        
        NSLog (@"Successfully received the ExitDrawer notification!");
        //        self.window.rootViewController.view.frame = CGRectMake(-self.window.rootViewController.view.frame.size.width/2,self.window.rootViewController.view.frame.size.height/6 ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height/2);
        [UIView animateWithDuration:0.3 animations:^{

        self.window.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        self.window.rootViewController.view.frame = CGRectMake(0,self.window.rootViewController.view.frame.origin.y ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height);
            [button removeFromSuperview];

                   }];
       // [self.window sendSubviewToBack:drawer.view];
    }
    
    [self performSelector:@selector(removeDrawer) withObject:self afterDelay:0.3];

}


-(void)removeDrawer{
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [drawer.view removeFromSuperview];
        
    }];

}


-(void) receiveClickedDrawerOptionNotification:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.window.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        self.window.rootViewController.view.frame = CGRectMake(0,self.window.rootViewController.view.frame.origin.y ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height);
        [button removeFromSuperview];

    }];

    if ([notification.name isEqualToString:@"ClickedDrawerOption"])
    {
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        NSLog (@"Successfully received ClickedDrawerOption notification! %i", index.intValue);
        
        NSDictionary* clicked = @{@"indexClickedOnDrawer": @(index.intValue)};
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        if (index.intValue==0) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ChangeTab"
             object:self userInfo:clicked];
            [button removeFromSuperview];
        }
        else if (index.intValue==1) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ChangeTab"
             object:self userInfo:clicked];
            [button removeFromSuperview];
        }
        else if (index.intValue==3) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ChangeTab"
             object:self userInfo:clicked];
            [button removeFromSuperview];
        }
        else if (index.intValue==4) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PushNewVC"
             object:self userInfo:clicked];
            [button removeFromSuperview];
        }
        else if (index.intValue==5) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"OpenControlVC"
             object:self userInfo:clicked];
            [button removeFromSuperview];
        }
        else if (index.intValue==6) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"PushToProfileVC"
             object:self userInfo:clicked];
            [button removeFromSuperview];
        }
        else if (index.intValue==7) {
            
            if (![userType isEqualToString:@"Guest"])
            {
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"PushToSetAvailabilityVC"
                 object:self userInfo:clicked];
                [button removeFromSuperview];
                
            } else {
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"PushToAboutVC"
                 object:self userInfo:clicked];
                [button removeFromSuperview];
            }
        }
        else if (index.intValue==8) {
            
            if (![userType isEqualToString:@"Guest"]) {
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"PushToAboutVC"
                 object:self userInfo:clicked];
                [button removeFromSuperview];
                
            } else {
                
                [self performSelector:@selector(logout) withObject:self afterDelay:1.0];
                
            }
            
        }
        else if (index.intValue==9) {
           
            [self performSelector:@selector(logout) withObject:self afterDelay:1.0];
            
        }
        
    }
    
    [self performSelector:@selector(removeDrawer) withObject:self afterDelay:0.3];

}


-(void)logout{
    
   // NSDictionary *userDict = [[responseDict objectForKey:@"profile"] objectAtIndex:0];
    
    [Userdefaults removeObjectForKey:@"ProfInfo"];
    [Userdefaults setObject:@"NO" forKey:@"isLoggedIn"];
    [Userdefaults removeObjectForKey:@"userType"];
    [Userdefaults removeObjectForKey:@"isMacUpdated"];
    [Userdefaults removeObjectForKey:@"isDeviceinfoUpdated"];
    
    [Userdefaults synchronize];
    
    [db deleteAllUsers];

    UIStoryboard *storyboardLogin = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:[NSBundle mainBundle]];

    [UIView animateWithDuration:0.1 animations:^{
        
        login = [storyboardLogin instantiateInitialViewController];
        
        [button removeFromSuperview];
        
        [self.window setRootViewController:login];
        
    }];

}


// This code block is invoked when application is in foreground (active-mode)
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
     NSLog(@"didReceiveLocalNotification");
}


-(void)localNotif
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNAuthorizationOptions options = UNAuthorizationOptionBadge + UNAuthorizationOptionSound;
    
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted) {
                                  NSLog(@"Something went wrong");
                              }
                          }];
}

- (void)registerForRemoteNotifications:(UIApplication *)application
{
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"8.0")){
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            
            if(!error){
                
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        
        // Code for old versions
    }
}


//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    
    if ([[notification.request.content.userInfo allKeys] count]>0) {
        
        userinfo = notification.request.content.userInfo;
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userinfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
       
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive||[UIApplication sharedApplication].applicationState == UIApplicationStateInactive||[UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        
        if ([Userdefaults objectForKey:@"ProfInfo"] != nil) {
            
            if ([[notification.request.content.userInfo allKeys] count]>0) {
                
                userDict = [Userdefaults objectForKey:@"ProfInfo"];
                
                userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
                
                NSMutableArray *arrNotif = [db getNotifications];
                
                NSString *notifID = [NSString stringWithFormat:@"%d",(int)[arrNotif count]];
                
                NSString *appid = [NSString stringWithFormat:@"%d",(int)[[userinfo objectForKey:@"aps"] objectForKey:@"appid"]];
                
               // NSString *appointmentID = [NSString stringWithFormat:@"%d",(int)[appid integerValue]];
                
                NSString *appointmentID;
                
                if (([appid isEqual:[NSNull null]] )|| (appid==nil) || ([appid isEqualToString:@"<null>"]) || ([appid isEqualToString:@"(null)"]) || (appid.length==0 )|| ([appid isEqualToString:@""])|| (appid==NULL)||(appid == (NSString *)[NSNull null])||[appid isKindOfClass:[NSNull class]]|| (appid == (id)[NSNull null]))
                {
                    appointmentID = @"";
                }
                else
                {
                    appointmentID = [NSString stringWithFormat:@"%d",(int)[appid integerValue]];
                }
                
                
                [db insertInNotificationTableWithNotificationid:notifID anDetails:[[userinfo objectForKey:@"aps"] objectForKey:@"alert"]andUserid:[NSString stringWithFormat:@"%@",userId] andappointmentid:appointmentID];
                
                
                NSMutableArray *arrMeetingDetails = [db getMeetingsById:appointmentID];
                
                if ([arrMeetingDetails count]>0) {
                    
                    NSDictionary *dict = [arrMeetingDetails objectAtIndex:0];
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    
                    manageDetails = [storyboard instantiateViewControllerWithIdentifier:@"ManageMeetingsDetailsViewController"];
                    
                    manageDetails.meetingDetailsDictionary = dict;
                    
                    [self.window.rootViewController.navigationController pushViewController:manageDetails animated:YES];
                }
                
            }
        }
        
    }
    
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}


//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    completionHandler();
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
}


-(void)sendEmailwithBody:(NSString *)strBody {
    // Email Subject
    NSString *emailTitle = @"Test Email";
    // Email Content
    NSString *messageBody = strBody;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"arijit.d@futurenetwings.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self.window.rootViewController presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
   // NSLog(@"deviceToken: %@", deviceToken);
    
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    NSLog(@"token: %@", token);
    
   // [self sendEmailwithBody:token];
    
    [Userdefaults setObject:token forKey:@"deviceToken"];
    
    [Userdefaults synchronize];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
    
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@",userInfo);
    
    application.applicationIconBadgeNumber = 0;
    
    if (application.applicationState == UIApplicationStateActive)
    {

    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
   // [self startStandardUpdates];
    
    if ([Userdefaults objectForKey:@"ProfInfo"] != nil) {
        
        [self getUpcomingMeetings];
    }
    
    // Stop heartbeat
    [self disableLocalHeartbeat];
    
    // Remove any open popups
    if (self.noConnectionAlert != nil) {
        [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:NO];
        self.noConnectionAlert = nil;
    }
    if (self.noBridgeFoundAlert != nil) {
        [self.noBridgeFoundAlert dismissWithClickedButtonIndex:[self.noBridgeFoundAlert cancelButtonIndex] animated:NO];
        self.noBridgeFoundAlert = nil;
    }
    if (self.authenticationFailedAlert != nil) {
        [self.authenticationFailedAlert dismissWithClickedButtonIndex:[self.authenticationFailedAlert cancelButtonIndex] animated:NO];
        self.authenticationFailedAlert = nil;
    }
}


-(void)locationSend
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
            
            userDict = [Userdefaults objectForKey:@"ProfInfo"];
            
            NSString *userType = [userDict objectForKey:@"usertype"];
            
            if ([userType isEqualToString:@"Guest"]) {
                
                if ([Userdefaults boolForKey:@"isConfirmFound"]) {
                    
                    if ([meetingsArr count]>0) {
                        
                        for (NSDictionary *dict in meetingsArr) {
                            
                            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                            
                            [dt setDateFormat:@"yyyy-MM-dd"];
                            
                            NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                            
                            NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
                            
                            NSComparisonResult compare = [currentDate compare:fromDate];
                            
                            if (compare==NSOrderedSame) {
                                
                                NSString *time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromtime"]];
                                
                                //NSString *dateString = [NSString stringWithFormat:@"%@ %@",Fdate,time];
                                
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                
                                [dateFormatter setDateFormat:@"hh:mm a"];
                                
                                NSDate *Date = [dateFormatter dateFromString:time];
                                
                                [dateFormatter setDateFormat:@"HH:mm"];
                                
                                NSString *dateString = [dateFormatter stringFromDate:Date];
                                
                                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                                
                                [dateFormatter setLocale:locale];
                                
                                NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                                
                                NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                                
                                NSTimeInterval secondsBetween = [dateFromString timeIntervalSinceDate:currentDate];
                                
                                int minutes = secondsBetween / 60;
                                
                                if ((minutes<=30) || (minutes<=-30)) {
                                    
                                    NSString *lat = [NSString stringWithFormat:@"%f",_locationManager.location.coordinate.latitude];
                                    
                                    if (![lat isEqualToString:@""]) {
                                        
                                        [self sendLat:[NSString stringWithFormat:@"%f",_locationManager.location.coordinate.latitude] andlong:[NSString stringWithFormat:@"%f",_locationManager.location.coordinate.longitude]];
                                        
                                    }
                                    
                                }
                                
                            }
                        
                        }
                    
                    }
                    
                }
                
            }
            
            if ([meetingsArr count]>0) {
                
                [self checkDayofMeeting:meetingsArr];
                
                [self checkHourofMeeting:meetingsArr];
                
                BOOL inRange = [Userdefaults boolForKey:@"inRange"];
                
                if (inRange) {
                    
                    [self checkMinutesofMeeting:meetingsArr];
                }
            }
            
        }
        
    });
}


-(void)checkUserArrivedOfficeOnMeetingTime:(CLLocation *)loc
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([Userdefaults objectForKey:@"ProfInfo"] != nil) {
            
            if ([meetingsArr count]>0) {
                
                for (NSDictionary *dict in meetingsArr) {
                    
                    NSString *statusStr = [dict objectForKey:@"status"];
                    
                    if ([statusStr isEqualToString:@"confirm"]) {
                        
                        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                        
                        [dt setDateFormat:@"yyyy-MM-dd"];
                        
                        NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                        
                        NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
                        
                        NSComparisonResult compare = [currentDate compare:fromDate];
                        
                        if (compare==NSOrderedSame) {
                            
                            NSString *time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromtime"]];
                            
                            //NSString *dateString = [NSString stringWithFormat:@"%@ %@",Fdate,time];
                            
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            
                            [dateFormatter setDateFormat:@"hh:mm a"];
                            
                            NSDate *Date = [dateFormatter dateFromString:time];
                            
                            [dateFormatter setDateFormat:@"HH:mm"];
                            
                            NSString *dateString = [dateFormatter stringFromDate:Date];
                            
                            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                            
                            [dateFormatter setLocale:locale];
                            
                            NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                            
                            NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                            
                            NSTimeInterval secondsBetween = [dateFromString timeIntervalSinceDate:currentDate];
                            
                            int minutes = secondsBetween / 60;
                            
                            if (minutes<=10) {
                                
                                [Userdefaults setObject:currentDate forKey:@"DateRecorded"];
                                
                                [Userdefaults setBool:YES forKey:[NSString stringWithFormat:@"isReachedOfficeForAppId:%@",[dict objectForKey:@"id"]]];
                                
                                [Userdefaults synchronize];
                                
                            }
                        }
                    }
                }
            }
        }
        
    });
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //[self startStandardUpdates];
    
    if ([Userdefaults objectForKey:@"ProfInfo"] != nil) {
        
        [self getUpcomingMeetings];
    }
    
    [self enableLocalHeartbeat];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [Userdefaults setObject:@"No" forKey:@"isInboxVisible"];
    
    [Userdefaults setBool:NO forKey:@"isETAFiredOnce"];
    
    [Userdefaults synchronize];
    
    [self.locationManager startMonitoringSignificantLocationChanges];

}


-(void)getUpcomingMeetings{
    
    if ([userId length]>0) {
        
        //[SVProgressHUD show];
        
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
                
                //[SVProgressHUD dismiss];
                
                meetingsArr = [responseDict objectForKey:@"apointments"];
                
                //NSLog(@"meetingsArr: %@", meetingsArr);
                
                if ([meetingsArr count]>0) {
                    
                    [Userdefaults removeObjectForKey:@"DateRecorded"];
                    
                    for (NSDictionary *dict in meetingsArr) {
                        
                        NSString *statusStr = [dict objectForKey:@"status"];
                        
                        if ([statusStr isEqualToString:@"confirm"]) {
                            
                            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                            
                            [dt setDateFormat:@"yyyy-MM-dd"];
                            
                            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                            
                            [dt setLocale:locale];
                            
                            NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                            
                            NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
                            
                            NSComparisonResult compare = [currentDate compare:fromDate];
                            
                            if (compare!=NSOrderedSame)
                            {
                                [db deleteETAByAppointmentId:[dict objectForKey:@"id"]];
                            }
                            
                            [Userdefaults setBool:NO forKey:[NSString stringWithFormat:@"isReachedOfficeForAppId:%@",[dict objectForKey:@"id"]]];
                            
                            [Userdefaults synchronize];
                            
                        }
                        
                    }
                    
                    [self IsMeetingToday:self.cLoc];
                    
                }
                
                
                [self CheckandSetNotification:meetingsArr];
                
                [self checkDayofMeeting:meetingsArr];
                
                [self checkHourofMeeting:meetingsArr];
                
                BOOL inRange = [Userdefaults boolForKey:@"inRange"];
                
                if (inRange) {
                    
                    [self checkMinutesofMeeting:meetingsArr];
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
            
            //[SVProgressHUD dismiss];
            
        }];

    }
}


-(void)sendPushLogforAppid:(NSString *)appid andFromid:(NSString *)fromid andToid:(NSString *)toid andPushType:(NSString *)pushtype{
    
    //[SVProgressHUD show];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"] integerValue]];
    
    NSDictionary *params = @{@"appid":appid,@"fromid":fromid,@"toid":toid,@"pushtype":pushtype};
    
    NSLog(@"params :%@",params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@getEta.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            NSLog(@"success");
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        //[SVProgressHUD dismiss];
        
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
        
        //NSLog(@"JSON: %@", responseObject);
        
       // NSDictionary *responseDict = responseObject;
        
       // NSString *success = [responseDict objectForKey:@"status"];
        
//        if ([success isEqualToString:@"success"]) {
//            
//            NSLog(@"success");
//        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self DayOfMeeting];
        
    }];
    
}


-(void)checkDayofMeeting:(NSArray *)arrMeetings
{
    for (id object in arrMeetings) {
        
        NSDictionary *dict = object;
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"])
        {
            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
            
            [dt setDateFormat:@"yyyy-MM-dd"];
            
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [dt setLocale:locale];
            
            NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
            
            NSDate *givendate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
            
            NSComparisonResult compare = [currentDate compare:givendate];
            
            if (compare==NSOrderedSame) {
                
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
            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
            
            [dt setDateFormat:@"yyyy-MM-dd"];
            
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [dt setLocale:locale];
            
            NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
            
            NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
            
            NSComparisonResult compare = [currentDate compare:fromDate];
            
            if (compare==NSOrderedSame) {
                
                NSString *time = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromtime"]];
                
                //NSString *dateString = [NSString stringWithFormat:@"%@ %@",Fdate,time];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setDateFormat:@"hh:mm a"];
                
                NSDate *Date = [dateFormatter dateFromString:time];
                
                [dateFormatter setDateFormat:@"HH:mm"];
                
                NSString *dateString = [dateFormatter stringFromDate:Date];
                
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                
                [dateFormatter setLocale:locale];
                
                NSDate *dateFromString = [dateFormatter dateFromString:dateString];
                
                NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                
                NSCalendar *c = [NSCalendar currentCalendar];
                
                NSDateComponents *components = [c components:NSCalendarUnitSecond fromDate:currentDate toDate:dateFromString options:0];
                
                NSInteger diff = components.second/60;
                
                if (diff<=120) {
                    
                    [self DayOfMeeting];
                    
                }
                
            }
            
        }
        
    }
    
}


-(void)checkMinutesofMeeting:(NSArray *)arrMeetings
{
    for (id object in arrMeetings) {
        
        NSDictionary *dict = object;
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"])
        {
            NSString *dateString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *cDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
            
            NSDate *gDate = [dateFormatter dateFromString:dateString];
            
            NSComparisonResult compare = [gDate compare:cDate];
            
            if (compare==NSOrderedSame) {
                
                [dateFormatter setDateFormat:@"HH:mm a"];
                
                NSString *timeStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"totime"]];
                
                NSDate *gtime = [dateFormatter dateFromString:timeStr];
                
                NSDate *ctime = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                
                NSCalendar *c = [NSCalendar currentCalendar];
                
                NSDateComponents *components = [c components:NSCalendarUnitSecond fromDate:gtime toDate:ctime options:0];
                
                NSInteger diff = components.minute;
                
                if (diff<=(10*60)) {
                    
                    NSString *strDetails = [NSString stringWithFormat:@"Only 10 minutes left for the current meeting. Do you want to Reschedule the meeting? Then please go to meeting details & extend the time of the current meeting."];
                    
                    [self startLocalNotification:strDetails];
                    
                }
                
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
            
            if(minutes <= 120)
            {
                [Userdefaults setBool:YES forKey:@"isConfirmFound"];
                
                [Userdefaults synchronize];
            }
            
        }
    }
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


#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    // Move to main screen (as you can't control lights when not connected)
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // Dismiss modal views when connection is lost
    if (self.navigationController.presentedViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    
    // Remove no connection alert
    if (self.noConnectionAlert != nil) {
        [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
        self.noConnectionAlert = nil;
    }
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
        // Dismiss modal views when connection is lost
        
        if (self.navigationController.presentedViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
        
        // No connection at all, show connection popup
        
        if (self.noConnectionAlert == nil) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            // Showing popup, so remove this view
            [self removeLoadingView];
            
            //[self showNoConnectionDialog];
        }
        
    }
    else {
        // One of the connections is made, remove popups and loading views
        
        if (self.noConnectionAlert != nil) {
            [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
            self.noConnectionAlert = nil;
        }
        [self removeLoadingView];
        
    }
}

/**
 Shows the first no connection alert with more connection options
 */
- (void)showNoConnectionDialog {
    
    self.noConnectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No connection", @"No connection alert title")
                                                        message:NSLocalizedString(@"Connection to bridge is lost", @"No Connection alert message")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Reconnect", @"No connection alert reconnect button"), NSLocalizedString(@"Find new bridge", @"No connection find new bridge button"),NSLocalizedString(@"Cancel", @"No connection cancel button"), nil];
    self.noConnectionAlert.tag = 1;
    [self.noConnectionAlert show];
    
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        //
        //[self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
        
       // [SVProgressHUD showWithStatus:@"Connecting..."];
        
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
        
    } else {
        
        // Automaticly start searching for bridges
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Show search screen
    //[self showLoadingViewWithText:NSLocalizedString(@"Searching...", @"Searching for bridges text")];
    
    //[SVProgressHUD showWithStatus:@"Connecting..."];
    
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAddressSearch:YES];
    
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        
        // Done with search, remove loading view
       // [self removeLoadingView];
        
        //[SVProgressHUD dismiss];
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            
            // Sort bridges by bridge id
            NSArray *sortedKeys = [bridgesFound.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            
            if ([sortedKeys count]>0) {
                
                // Get mac address and ip address of selected bridge
                NSString *bridgeId = [sortedKeys objectAtIndex:0];
                NSString *ip = [bridgesFound objectForKey:bridgeId];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                [defaults setObject:bridgeId forKey:@"selectedBridgeId"];
                [defaults setObject:ip forKey:@"ip"];
                [defaults setBool:YES forKey:@"bridgeSelected"];
                
                [defaults synchronize];
                
            }
//            else
//            {
//                [self searchForBridgeLocal];
//            }
            
            
//            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
//            
//            self.bridgeSelectionViewController = [[PHBridgeSelectionViewController alloc] initWithNibName:@"PHBridgeSelectionViewController" bundle:[NSBundle mainBundle] bridges:bridgesFound delegate:self];
//            
//            /***************************************************
//             Use the list of bridges, present them to the user, so one can be selected.
//             *****************************************************/
//            
//            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.bridgeSelectionViewController];
//            
//            navController.modalPresentationStyle = UIModalPresentationFormSheet;
//            
//            [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
            
        }
        else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/
            
            // No bridges were found, show this to the user
            
//            self.noBridgeFoundAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connect to WiFi", @"No bridge found alert title")
//                                                                 message:NSLocalizedString(@"Choose FNSPL and type Plz@ccess as password.", @"No bridge found alert message")
//                                                                delegate:self
//                                                       cancelButtonTitle:nil
//                                                       otherButtonTitles:NSLocalizedString(@"Retry", @"No bridge found alert retry button"),NSLocalizedString(@"Cancel", @"No bridge found alert cancel button"), nil];
//            
//            self.noBridgeFoundAlert.tag = 1;
//            
//            [self.noBridgeFoundAlert show];
            
        }
    }];
}


/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andBridgeId:(NSString *)bridgeId {
    /***************************************************
     Removing the selection view controller takes us to
     the 'normal' UI view
     *****************************************************/
    
    // Remove the selection view controller
    self.bridgeSelectionViewController = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    // Show a connecting view while we try to connect to the bridge
    //[self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
    
    //[SVProgressHUD showWithStatus:@"Connecting..."];
    
    // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
    //NSString *username = [PHUtilities whitelistIdentifier];
    
    /***************************************************
     Set the ipaddress and bridge id,
     as the bridge properties that the SDK framework will use
     *****************************************************/
    
    [self.phHueSDK setBridgeToUseWithId:bridgeId ipAddress:ipAddress];
    
    /***************************************************
     Setting the hearbeat running will cause the SDK
     to regularly update the cache with the status of the
     bridge resources
     *****************************************************/
    
    // Start local heartbeat again
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}


#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    // Disable heartbeats
    [self disableLocalHeartbeat];
    
    /***************************************************
     To be certain that we own this bridge we must manually
     push link it. Here we display the view to do this.
     *****************************************************/
    
    // Create an interface for the pushlinking
   // self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] initWithNibName:@"PHBridgePushLinkViewController" bundle:[NSBundle mainBundle] hueSDK:self.phHueSDK delegate:self];
    
    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] init];
    
    self.pushLinkViewController.delegate = self;
    self.pushLinkViewController.phHueSDK = self.phHueSDK;
    
    [self.window.rootViewController presentViewController:self.pushLinkViewController animated:YES completion:^{
        /***************************************************
         Start the push linking process.
         *****************************************************/
        
        // Start pushlinking when the interface is shown
        [self.pushLinkViewController startPushLinking];
        
    }];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    /***************************************************
     Push linking succeeded we are authenticated against
     the chosen bridge.
     *****************************************************/
    
    // Remove pushlink view controller
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */

- (void)pushlinkFailed:(PHError *)error {
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        self.authenticationFailedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")
                                                                    message:NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Retry", @"Authentication failed alert retry button"), NSLocalizedString(@"Cancel", @"Authentication failed cancel button"), nil];
        [self.authenticationFailedAlert show];
    }
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.noConnectionAlert && alertView.tag == 1) {
        // This is a no connection alert with option to reconnect or more options
        self.noConnectionAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry, just wait for the heartbeat to finish
            //[self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
            
           // [SVProgressHUD dismiss];
            
        }
        else if (buttonIndex == 1) {
            // Find new bridge button
            [self searchForBridgeLocal];
        }
        else if (buttonIndex == 2) {
            // Cancel and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    else if (alertView == self.noBridgeFoundAlert && alertView.tag == 1) {
        // This is the alert which is shown when no bridges are found locally
        self.noBridgeFoundAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry
            [self searchForBridgeLocal];
        } else if (buttonIndex == 1) {
            // Cancel and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
    else if (alertView == self.authenticationFailedAlert) {
        // This is the alert which is shown when local pushlinking authentication has failed
        self.authenticationFailedAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry authentication
            [self doAuthentication];
        } else if (buttonIndex == 1) {
            // Remove connecting loading message
            [self removeLoadingView];
            // Cancel authentication and disable local heartbeat unit started manually again
            [self disableLocalHeartbeat];
        }
    }
}

#pragma mark - Loading view

/**
 Shows an overlay over the whole screen with a black box with spinner and loading text in the middle
 @param text The text to display under the spinner
 */
- (void)showLoadingViewWithText:(NSString *)text {
    // First remove
   // [self removeLoadingView];
    
    //[SVProgressHUD dismiss];
    
    // Then add new
    self.loadingView = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    self.loadingView.view.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.loadingView.view];
    self.loadingView.loadingLabel.text = text;
}

/**
 Removes the full screen loading overlay.
 */
- (void)removeLoadingView {
    if (self.loadingView != nil) {
        [self.loadingView.view removeFromSuperview];
        self.loadingView = nil;
    }
}


@end
