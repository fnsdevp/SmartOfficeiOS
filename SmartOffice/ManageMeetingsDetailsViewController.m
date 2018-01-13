//
//  ManageMeetingsDetailsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 23/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ManageMeetingsDetailsViewController.h"

typedef enum{
    
    kPendingType = 1,
    kConfirmType,
    kCancelType,
    kEndType
    
} meetingType;


@interface ManageMeetingsDetailsViewController (){
    UIView *navView;
    NSString *userId;
    
    meetingType mType;
}

@end


@implementation ManageMeetingsDetailsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    db = [Database sharedDB];
    
    NSLog(@"_meetingDetailsDictionary :%@",_meetingDetailsDictionary);
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    [self getUpcomingMeetings];
    
    [self setUpDetails];
    
    [self startStandardUpdates];
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _commentsView.frame.origin.y+_commentsView.frame.size.height);
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    [Userdefaults setBool:NO forKey:@"ETAFiredOnceForDetails"];
    
    [Userdefaults setBool:NO forKey:@"ETALoopFiredOnceForDetails"];
    
    [Userdefaults synchronize];
    
    [navView removeFromSuperview];
}


-(void)setUpDetails
{
    [self.etaVw setHidden:YES];
    
    _lblAgenda.text = [NSString stringWithFormat:@"Agenda: %@",[_meetingDetailsDictionary objectForKey:@"agenda"]];
    _lblAgenda.numberOfLines = 0;
    _lblAgenda.lineBreakMode = NSLineBreakByWordWrapping;
    [_lblAgenda sizeToFit];
    
    NSString *Date = [_meetingDetailsDictionary objectForKey:@"fdate"];
    NSArray *split = [Date componentsSeparatedByString:@"-"];
    NSLog(@"split :%@",split);
    
    NSString *day = [split objectAtIndex:2];
    NSLog(@"day :%@",day);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate* myDate = [dateFormatter dateFromString:[split objectAtIndex:1]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    
    NSLog(@"%@", stringFromDate);
    NSString *month = stringFromDate;
    NSLog(@"month :%@",month);
    
    NSString *year = [split objectAtIndex:0];
    NSLog(@"year :%@",year);
    
    _lblDate.text = day;
    _lblMonthYear.text = [NSString stringWithFormat:@"%@ %@",month,year];
    
    NSDictionary *dictUserDetails = [_meetingDetailsDictionary objectForKey:@"userdetails"];
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    NSString *status = [dict objectForKey:@"status"];
    
    appointmentID = [_meetingDetailsDictionary objectForKey:@"id"];
    
    fDateSel = [_meetingDetailsDictionary objectForKey:@"fdate"];
    
    _lblName.text = [dictUserDetails objectForKey:@"contact"];
    _lblEmail.text = [dictUserDetails objectForKey:@"email"];
    _lblPhoneNumber.text = [dictUserDetails objectForKey:@"phone"];
    
    _lblMeetingType.text = [NSString stringWithFormat:@"Meeting Type: %@",[_meetingDetailsDictionary objectForKey:@"appointmentType"]];
    
    
    if ([_lblMeetingType.text isEqualToString:@"Meeting Type: flexible"]) {
        
        if([status isEqualToString:@"pending"]){
            
            _lblMeetingDate.text = [NSString stringWithFormat:@"Meeting Date: %@ to %@",[_meetingDetailsDictionary objectForKey:@"fdate"],[_meetingDetailsDictionary objectForKey:@"sdate"]];
        }
        else
        {
            _lblMeetingDate.text = [NSString stringWithFormat:@"Meeting Date: %@",[_meetingDetailsDictionary objectForKey:@"fdate"]];
        }
        
    }else{
        
        _lblMeetingDate.text = [NSString stringWithFormat:@"Meeting Date: %@",[_meetingDetailsDictionary objectForKey:@"fdate"]];
    }
    
    _lblTiming.text = [NSString stringWithFormat:@"Timing: %@ - %@",[_meetingDetailsDictionary objectForKey:@"fromtime"],[_meetingDetailsDictionary objectForKey:@"totime"]];
    
    _lblLocation.text = [NSString stringWithFormat:@"Location: %@",[_meetingDetailsDictionary objectForKey:@"location"]];
    
    navView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [navView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, navView.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
    NSString *blueText = @"Manage";
    NSString *whiteText = @"Meetings";
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
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    [navView addSubview:label];
    
    [self.navigationController.navigationBar addSubview:navView];
    
    
    if([status isEqualToString:@"pending"]){
        
        _statusImage.image = [UIImage imageNamed:@"pending.png"];
        
        [self.btnEndMeetingOutlet setHidden:NO];
        
        mType = kPendingType;
        
    }else if([status isEqualToString:@"confirm"]){
        
        _statusImage.image = [UIImage imageNamed:@"confirm.png"];
        
        [self.btnEndMeetingOutlet setHidden:NO];
        [self.confirmedImage setHidden:YES];
        [self.btnConfirmedMeetingOutlet setHidden:YES];
        
        mType = kConfirmType;
        
    }else if([status isEqualToString:@"cancel"]){
        
        _statusImage.image = [UIImage imageNamed:@"cancelMeeting"];
        
        [self.confirmedImage setHidden:YES];
        [self.btnConfirmedMeetingOutlet setHidden:YES];
        [self.cancelImage setHidden:YES];
        [self.btnCancelMeetingOutlet setHidden:YES];
        [self.endImage setHidden:YES];
        [self.btnEndMeetingOutlet setHidden:YES];
        [self.calenderImage setHidden:YES];
        [self.btnSaveToCalenderOutlet setHidden:YES];
        
        mType = kCancelType;
        
    }else if([status isEqualToString:@"end"]){
        
        _statusImage.image = [UIImage imageNamed:@"endMeeting"];
        
        [self.confirmedImage setHidden:YES];
        [self.btnConfirmedMeetingOutlet setHidden:YES];
        [self.cancelImage setHidden:YES];
        [self.btnCancelMeetingOutlet setHidden:YES];
        [self.endImage setHidden:YES];
        [self.btnEndMeetingOutlet setHidden:YES];
        [self.calenderImage setHidden:YES];
        [self.btnSaveToCalenderOutlet setHidden:YES];
        
        mType = kEndType;
    }
    
    addressFetch = NO;
    
    self.etaVw.layer.cornerRadius = 5.0;
    
    self.btnPostCommentOutlet.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnPostCommentOutlet.layer.borderWidth = 1.0;
    self.btnPostCommentOutlet.layer.cornerRadius = 5.0;
    
    self.etaVw.layer.cornerRadius = 5.0;
    
    self.lbldistance.text = @"--";
    self.lblduration.text = @"--";
    
    [self getReviewByAppointmentId:[dict objectForKey:@"id"]];
    
    [self adjustButtons];
    
}


-(void)endBtnOpen
{
    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
    
    [dt setDateFormat:@"yyyy-MM-dd"];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dt setLocale:locale];
    
    NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
    
    NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[_meetingDetailsDictionary objectForKey:@"fdate"]]];
    
    NSComparisonResult compare = [currentDate compare:fromDate];
    
    if (compare==NSOrderedSame) {
        
        NSString *time = [NSString stringWithFormat:@"%@",[_meetingDetailsDictionary objectForKey:@"totime"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"hh:mm a"];
        
        NSDate *Date = [dateFormatter dateFromString:time];
        
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSString *dateString = [dateFormatter stringFromDate:Date];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dateFormatter setLocale:locale];
        
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        NSDate *dateFromString = [dateFormatter dateFromString:dateString];
        
        NSDate *currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
        
        
        NSTimeInterval secondsBetween = [dateFromString timeIntervalSinceDate:currentDate];
        
        int minutes = secondsBetween / 60;
        
        if(minutes>0)
        {
           isResceduleBtn=YES;
            isEndBtn=NO;
        }
        else
        {
           isResceduleBtn=NO;
            isEndBtn=YES;
           
        }
        
    }
    else if(compare==NSOrderedDescending) {
        
        isResceduleBtn=NO;
        isEndBtn=YES;
    }
    
}


-(void)adjustButtons
{
    switch (mType) {
            
        case kPendingType:
            [self setButtons:kPendingType];
            break;
            
        case kConfirmType:
            [self setButtons:kConfirmType];
            break;
            
        case kCancelType:
            [self setButtons:kCancelType];
            break;
            
        case kEndType:
            [self setButtons:kEndType];
            break;
            
        default:
            break;
    }
}


-(void)setButtons:(meetingType)type
{
    if (type==kPendingType) {
        
        if (self.isRequest) {
            
            isConfirmBtn=YES;
            
        } else {
            
            isConfirmBtn=NO;
        }
        
        isCancelBtn=YES;
        isResceduleBtn=YES;
        isCallBtn=YES;
        
        [self createButton];
        
    }
    else if (type==kConfirmType) {
        
        isCancelBtn=YES;
        isResceduleBtn=YES;
        isCallBtn=YES;
        isMapBtn=YES;
        isNavigationBtn = YES;
        
        [self endBtnOpen];
        
        [self createButton];
        
    }
    else if (type==kCancelType) {
        
        
    }
    else if (type==kEndType) {
        
        
        
    }
    else {
        
        
    }
}


-(void)createButton
{
    x = 0.0;
    
    float width = SCREENWIDTH/5.0;
    
    if (isConfirmBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(btnConfirmedMeetingsDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"confirmMeeting"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
    if (isCancelBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(btnCancelMeetingDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"cancelMeeting"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
    if (isEndBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(btnEndMeetingsDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"endMeeting"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
    if (isResceduleBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(btnRescheduleDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"rescheduleMetting"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
    if (isCallBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(btnCallDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"callBtn"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
    if (isMapBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(btnOpenDirectionsDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"mapBtn"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
    if (isNavigationBtn) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(showGoogleMap:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"navigationBtn"] forState:UIControlStateNormal];
        button.frame = CGRectMake(x, 0.0, width, width);
        
        [_statusVw addSubview:button];
        
        x = x+width;
    }
    
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
    //self.locationManager.distanceFilter = 10; // meters
    
    [self.locationManager startUpdatingLocation];
    
    if(IS_OS_8_OR_LATER) {
        
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    
}


-(void)IsMeetingToday:(CLLocation *)lc
{
    NSArray *arrDuration = [duration componentsSeparatedByString:@" "];
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    NSString *status = [dict objectForKey:@"status"];
    
    if([status isEqualToString:@"confirm"])
    {
        [self.etaVw setHidden:NO];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dt setLocale:locale];
        
        NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
        
        NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]]];
        
        NSComparisonResult compare = [currentDate compare:fromDate];
        
        if (compare==NSOrderedSame) {
            
            NSString *RecordedDateStr = [Userdefaults objectForKey:@"DateRecorded"];
            
            if (RecordedDateStr!=nil) {
                
                NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
                
                NSDate *RecordedDate = [dt dateFromString:[NSString stringWithFormat:@"%@",RecordedDateStr]];
                
                NSComparisonResult compare = [currentDate compare:RecordedDate];
                
                if (compare==NSOrderedSame){
                    
                    [self.etaVw setHidden:YES];
                    
                }
                else {
                    
                    int appid = (int)[[dict objectForKey:@"id"] integerValue];
                    
                    int ID = (int)[appointmentID integerValue];
                    
                    if (appid == ID) {
                        
                        //NSString *Fdate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
                        
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
                        
                        if (arrDuration ==nil) {
                            
                            [self reverseGeoCode:lc];
                            
                        } else {
                            
                            int durationMin = (int)[[arrDuration objectAtIndex:0] integerValue];
                            
                            //NSDictionary *dict1 = [dict objectForKey:@"guest"];
                            
                            if (durationMin<=5) {
                                
                            }
                            else
                            {
                                [self reverseGeoCode:lc];
                            }
                        }
                    }
                }
            }
            else
            {
                
                int appid = (int)[[dict objectForKey:@"id"] integerValue];
                
                int ID = (int)[appointmentID integerValue];
                
                if (appid == ID) {
                    
                    //NSString *Fdate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fdate"]];
                    
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
                    
                    if (arrDuration == nil) {
                        
                        [self reverseGeoCode:lc];
                        
                    } else {
                        
                        int durationMin = (int)[[arrDuration objectAtIndex:0] integerValue];
                        
                        //NSDictionary *dict1 = [dict objectForKey:@"guest"];
                        
                        if (durationMin<=5) {
                            
                        }
                        else
                        {
                            [self reverseGeoCode:lc];
                        }
                    }
                }
            }
        }
    }
    else
    {
        [self.etaVw setHidden:YES];
    }
}


-(void)reverseGeoCode:(CLLocation *)location{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *hostUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", location.coordinate.latitude, location.coordinate.longitude];
    
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
            
            NSString *distance = [distanceDic objectForKey:@"text"];
            
            NSString *DuraTion = [durationDic objectForKey:@"text"];
            
            NSArray *arrUnit = [distance componentsSeparatedByString:@" "];
            
            if ([arrUnit containsObject:@"m"]||[arrUnit containsObject:@"km"])
            {
                self.lbldistance.text = [NSString stringWithFormat:@"%@",distance];
                self.lblduration.text = DuraTion;
                
                duration = DuraTion;
            }
            else
            {
                int meter = (int)[[arrUnit objectAtIndex:0] integerValue];
                
                self.lbldistance.text = [NSString stringWithFormat:@"%.f m",(meter *FEET_TO_METERS)];
                self.lblduration.text = DuraTion;
                
                duration = DuraTion;
            }
            
            [Userdefaults setBool:YES forKey:@"ETALoopFiredOnceForDetails"];
            
            [Userdefaults synchronize];
            
            //NSLog(@"distance: %@", distance);
            // NSLog(@"duration: %@", duration);

        }
            
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [Userdefaults setBool:NO forKey:@"ETALoopFiredOnceForDetails"];
        
        [Userdefaults synchronize];
        
    }];
    
  // https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=Washington,DC&destinations=New+York+City,NY&key=YOUR_API_KEY

}


-(IBAction)showGoogleMap:(id)sender
{
    NSURL *testURL = [NSURL URLWithString:@"comgooglemaps-x-callback://"];
    
    if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
        
        NSMutableString *directionsRequest = [NSMutableString   stringWithString:@"comgooglemaps-x-callback://"];
        
        [directionsRequest appendFormat:@"maps.google.com/maps?f=d&daddr=future+netwings&sll=22.5731315,88.4505025&sspn=0.2,0.1&nav=1"];
        
        NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
        
        [[UIApplication sharedApplication] openURL:directionsURL];
        
    } else {
        
        NSLog(@"Can't use comgooglemaps-x-callback://");
    }
}



#pragma mark - Location Manager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
    
    CLLocation *loc = [locations lastObject];
    
    if (loc!=nil)
    {
        cLoc = loc;
        
        if ([Userdefaults boolForKey:@"ETAFiredOnceForDetails"]==YES) {
            
            if ([Userdefaults boolForKey:@"ETALoopFiredOnceForDetails"]==YES) {
                
                NSLog(@"No ETA fire");
                
            } else {
                
                [self performSelector:@selector(IsMeetingToday:) withObject:loc afterDelay:300.0];
                
                [Userdefaults setBool:YES forKey:@"ETALoopFiredOnceForDetails"];
                [Userdefaults synchronize];
            }
            
        } else {
            
            [self IsMeetingToday:loc];
            
            [Userdefaults setBool:YES forKey:@"ETAFiredOnceForDetails"];
            [Userdefaults synchronize];
        }
        
    }
    
   // [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", loc.coordinate.latitude, loc.coordinate.longitude];
    
  //  NSLog(@"%@",[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", loc.coordinate.latitude, loc.coordinate.longitude]);
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Location manager error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusDenied) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized" message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else
        
        NSLog(@"Wrong location status");
}



-(IBAction)btnOpenDirectionsDidTap:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BeaconFlow" bundle:[NSBundle mainBundle]];
    
    IndoorMapViewController *indoorMap = [storyboard instantiateViewControllerWithIdentifier:@"IndoorMapViewController"];
    
    [self.navigationController pushViewController:indoorMap animated:YES];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [commentsArray count];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 35;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CommentTableCell";
    
    CommentTableCell *cell = (CommentTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentTableCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSDictionary *dict = [commentsArray objectAtIndex:indexPath.row];
    
    cell.userImage.image = nil;
    cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2;
    cell.userImage.backgroundColor = [UIColor lightGrayColor];
    
    NSString *strName = [dict objectForKey:@"username"];
    
    NSArray *subArr = [strName componentsSeparatedByString:@" "];
    
    if ([subArr count]>1) {
        
        NSString *letter1 = [subArr objectAtIndex:0];
        NSString *letter2 = [subArr objectAtIndex:1];
        
        NSString * firstLetter;
        NSString * secondLetter;
        
        if ([letter1 length] > 0) {
            
            firstLetter = [[letter1 substringWithRange:[letter1 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
        }
        
        if ([letter2 length] > 0) {
            
            secondLetter = [[letter2 substringWithRange:[letter2 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
        }
        
        cell.lblUserName.text = [NSString stringWithFormat:@"%@%@",firstLetter,secondLetter];
    }
    else
    {
        NSString *letter1 = [subArr objectAtIndex:0];
        
        NSString * firstLetter;
        
        if ([letter1 length] > 0) {
            
            firstLetter = [[letter1 substringWithRange:[letter1 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
        }
        
        cell.lblUserName.text = [NSString stringWithFormat:@"%@",firstLetter];
    }
    
    cell.lblComment.text = [dict objectForKey:@"review"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)btnEndMeetingsDidTap:(UIButton *)sender {
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Info"
                                  message:@"Do you want to end this appointment?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self endAppointment:[dict objectForKey:@"id"]];
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnConfirmedMeetingsDidTap:(UIButton *)sender {
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    NSString *meetingType = [dict objectForKey:@"appointmentType"];
    
    if ([userType isEqualToString:@"Guest"])
    {
        if ([meetingType isEqualToString:@"flexible"]) {
            
            [self dateSelect:sender];
        }
        else
        {
            [self confirmAppointment:[dict objectForKey:@"id"] withSender:sender];
        }
    }
    else
    {
        if ([meetingType isEqualToString:@"flexible"]) {
            
            [self dateSelect:sender];
        }
        else
        {
            [self roomSelect:sender];
        }
    }
}

- (IBAction)btnCancelMeetingDidTap:(id)sender{
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Info"
                                  message:@"Do you want to cancel this appointment?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self cancelAppointment:[dict objectForKey:@"id"]];
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)btnPostCommentDidTap:(UIButton *)sender{
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    if ([_txtPost hasText]) {
        
        [self createReviewByAppointmentId:[dict objectForKey:@"id"] andReview:_txtPost.text];
    }
}

    
#pragma mark - text field delegates
    
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    Height = _scrollView.frame.size.height;
    
    Width = _scrollView.frame.size.width;
    
    [_scrollView setContentOffset:CGPointMake(0, (105 + textField.frame.size.height))];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _scrollView.frame = CGRectMake(0, 0, Width, Height);
    
    [textField resignFirstResponder];
    
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


-(IBAction)btnRescheduleDidTap:(UIButton *)sender {
    
    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
    
    NSString *strDateTime = [NSString stringWithFormat:@"%@",fDateSel];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dt setLocale:locale];
    
    [dt setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *FirstDate = [dt dateFromString:strDateTime];
    
    NSDate *currentDate = [NSDate date];
    
    unsigned int unitFlags = NSCalendarUnitDay;
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:FirstDate  toDate:currentDate  options:0];
    
    int days = (int)[comps day];
    
    NSLog(@"%d",days);
    
    if (days > 0) {
        
        [self showAlert];
        
    } else {
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dt setLocale:locale];
        
        [dt setDateFormat:@"yyyy-MM-dd"];

        
        objReschedule = [[RescheduleView alloc] init];
        
        objReschedule.frame = self.view.window.bounds;
        objReschedule.delegate = self;
        
        objReschedule.fDateSel = fDateSel;
        
        objReschedule.fdate = [dt stringFromDate:[NSDate date]];
        
        objReschedule.selectedDate = [dt stringFromDate:[NSDate date]];
        
        objReschedule.initialDate = [NSDate date];
        
        objReschedule.dictdetails = _meetingDetailsDictionary;
        
        objReschedule.hours = [NSArray arrayWithObjects:@"10:00 AM-11:00 AM",@"11:00 AM-12:00 PM",@"12:00 PM-01:00 PM",@"01:00 PM-02:00 PM",@"02:00 PM-03:00 PM",@"03:00 PM-04:00 PM",@"04:00 PM-05:00 PM",@"05:00 PM-06:00 PM",nil];
        
        [objReschedule.collectionViewDates registerNib:[UINib nibWithNibName:@"RescheduleDateCell" bundle:[NSBundle mainBundle]]
                            forCellWithReuseIdentifier:@"RescheduleDateCell"];
        
        
        [objReschedule.collectionViewTimes registerNib:[UINib nibWithNibName:@"RescheduleTimeCell" bundle:[NSBundle mainBundle]]
                            forCellWithReuseIdentifier:@"RescheduleTimeCell"];
        
        
        [self.view.window addSubview:objReschedule];
    }
    
}

    
-(void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You cannot reschedule a meeting which is in past."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    
    [alertView show];
}


-(void)RescheduleView:(RescheduleView *)obj didShowAlert:(BOOL)isShow
{
    if (isShow) {
        
        NSDateFormatter *dateFormatterForAPI = [[NSDateFormatter alloc]init];
        
        [dateFormatterForAPI setDateFormat:@"yyyy-MM-dd"];
        
        NSString *dateForAPI = fDateSel;
        
        NSDate *FirstDate = [dateFormatterForAPI dateFromString:dateForAPI];
        
        
        [UIView animateWithDuration:0 animations:^{
            
           // [self getTodaysMeetings:dateForAPI];
            
        } completion:^(BOOL finished) {
            //Do something after that...
            
            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
            
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            [dt setLocale:locale];
            
            [dt setDateFormat:@"yyyy-MM-dd"];
            
            objReschedule = [[RescheduleView alloc] init];
            
            objReschedule.frame = self.view.window.bounds;
            objReschedule.delegate = self;
            
            objReschedule.fDateSel = dateForAPI;
            
            objReschedule.selectedDate = [dt stringFromDate:[NSDate date]];
            
            objReschedule.fdate = [dt stringFromDate:[NSDate date]];
            
            objReschedule.initialDate = [NSDate date];
            
            objReschedule.dictdetails = _meetingDetailsDictionary;
            
            objReschedule.hours = [NSArray arrayWithObjects:@"10:00 AM-11:00 AM",@"11:00 AM-12:00 PM",@"12:00 PM-01:00 PM",@"01:00 PM-02:00 PM",@"02:00 PM-03:00 PM",@"03:00 PM-04:00 PM",@"04:00 PM-05:00 PM",@"05:00 PM-06:00 PM",nil];
            
            [objReschedule.collectionViewDates registerNib:[UINib nibWithNibName:@"RescheduleDateCell" bundle:[NSBundle mainBundle]]
                                forCellWithReuseIdentifier:@"RescheduleDateCell"];
            
            
            [objReschedule.collectionViewTimes registerNib:[UINib nibWithNibName:@"RescheduleTimeCell" bundle:[NSBundle mainBundle]]
                                forCellWithReuseIdentifier:@"RescheduleTimeCell"];
            
            
            [self.view.window addSubview:objReschedule];
            
        }];

    }
}


-(void)RescheduleView:(RescheduleView *)obj didTapOnCalender:(BOOL)isTapped
{
    if (isTapped) {
        
        [obj removeFromSuperview];
        
        dateSel = [WWCalendarTimeSelector instantiate];
        dateSel.delegate = self;
        //dateSel.optionStyles.showTime = NO;
        // dateSel.optionStyles.sh
        
        [dateSel.optionStyles showTime:NO];
        dateSel.optionTopPanelBackgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0];
        dateSel.optionMainPanelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        dateSel.optionBottomPanelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        
        dateSel.optionSelectorPanelBackgroundColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
        dateSel.optionButtonTitleCancel = @"CANCEL";
        dateSel.optionButtonTitleDone = @"OK";
        dateSel.optionButtonFontColorDone = [UIColor blackColor];
        dateSel.optionButtonFontColorCancel = [UIColor blackColor];
        dateSel.optionCalendarBackgroundColorTodayHighlight = [UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1.0];
        dateSel.optionCalendarBackgroundColorFutureDatesHighlight = [UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1.0];
        
        // dateSel. = [UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1.0];
        
        [self.tabBarController presentViewController:dateSel animated:YES completion:nil];
    }
}

-(void)RescheduleView:(RescheduleView *)obj didTapOnBackground:(BOOL)isClose
{
    if (isClose) {
        
        [obj removeFromSuperview];
    }
}

-(void)RescheduleView:(RescheduleView *)obj fromTime:(NSString *)FromTime toTime:(NSString *)ToTime duration:(NSString *)Duration fDateSel:(NSString *)FDateSel okPressed:(BOOL)isTapped
{
    
    if (isTapped) {
        
        fromTime = FromTime;
        toTime = ToTime;
        DuraTion = Duration;
        fDateSel = FDateSel;
        
        [self RescheduleAppointment:appointmentID];
        
        [obj removeFromSuperview];
    }

}
    
    
#pragma mark - WWCalendarSelector
    
- (void)WWCalendarTimeSelectorDone:(WWCalendarTimeSelector * _Nonnull)selector date:(NSDate * _Nonnull)date{
    
    NSDateFormatter *dateFormatterForAPI = [[NSDateFormatter alloc]init];
    
    [dateFormatterForAPI setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateForAPI = [dateFormatterForAPI stringFromDate:date];
    
    
    NSDate *CDate = date;
    
    NSDate *currentDate = [dateFormatterForAPI dateFromString:[dateFormatterForAPI stringFromDate:[NSDate date]]];
    
    NSComparisonResult compare = [currentDate compare:CDate];
    
    NSDate *currentWeekDate = [NSDate dateWithTimeInterval:(24*60*60*7) sinceDate:currentDate];
    
    switch (compare)
    {
        case NSOrderedAscending:
        
        NSLog(@"%@ is in future from %@", CDate, currentDate);
        
        fdate = dateForAPI;
        sdate = @"";
        
        isSelectedDate = YES;
        
        initialDate = date;
        
        selectedDate = fdate;
        
        fDateSel = dateForAPI;
        
        seletedTag = 0;
        
        break;
        
        case NSOrderedDescending:
        
        NSLog(@"%@ is in past from %@", CDate, currentDate);
        
        [self showAlert];
        
        initialDate = [NSDate date];
        
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
        
        fdate = [dateFormatterForAPI stringFromDate:initialDate];
        sdate = @"";
        
        break;
        
        case NSOrderedSame:
        
        fdate = dateForAPI;
        sdate = @"";
        
        isSelectedDate = YES;
        
        initialDate = date;
        
        selectedDate = fdate;
        
        fDateSel = dateForAPI;
        
        seletedTag = 0;
        
        break;
        
    }
    
    [UIView animateWithDuration:0 animations:^{
        
        NSDateFormatter *dateFormatterForAPI = [[NSDateFormatter alloc]init];
        
        [dateFormatterForAPI setDateFormat:@"yyyy-MM-dd"];
        
        NSString *dateForAPI = [dateFormatterForAPI stringFromDate:initialDate];
        
        //[self getTodaysMeetings:dateForAPI];
        
    } completion:^(BOOL finished) {
        //Do something after that...
        
        objReschedule = [[RescheduleView alloc] init];
        
        objReschedule.frame = self.view.window.bounds;
        objReschedule.delegate = self;
        
        objReschedule.fDateSel = dateForAPI;
        
        objReschedule.selectedDate = selectedDate;
        
        objReschedule.initialDate = initialDate;
        
        objReschedule.dictdetails = _meetingDetailsDictionary;
        
        objReschedule.hours = [NSArray arrayWithObjects:@"10:00 AM-11:00 AM",@"11:00 AM-12:00 PM",@"12:00 PM-01:00 PM",@"01:00 PM-02:00 PM",@"02:00 PM-03:00 PM",@"03:00 PM-04:00 PM",@"04:00 PM-05:00 PM",@"05:00 PM-06:00 PM",nil];
        
        [objReschedule.collectionViewDates registerNib:[UINib nibWithNibName:@"RescheduleDateCell" bundle:[NSBundle mainBundle]]
                            forCellWithReuseIdentifier:@"RescheduleDateCell"];
        
        
        [objReschedule.collectionViewTimes registerNib:[UINib nibWithNibName:@"RescheduleTimeCell" bundle:[NSBundle mainBundle]]
                            forCellWithReuseIdentifier:@"RescheduleTimeCell"];
        
        
        [self.view.window addSubview:objReschedule];
        
    }];
    
}


-(void)roomSelect:(UIButton *)sender
{
    NSDictionary *dict = _meetingDetailsDictionary;
    
    //NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    //NSString *userType = [userDict objectForKey:@"usertype"];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:@"Please select appointment location"];
    
    [hogan addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20.0] range:NSMakeRange(0, 34)];
    
    [hogan addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 34)];
    
    [actionSheet setValue:hogan forKey:@"attributedMessage"];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Conference room" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        locationName = @"conference room";
        
        [self confirmAppointment:[dict objectForKey:@"id"] withSender:sender];
        
        // Distructive button tapped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Director room" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        locationName = @"director room";
        
        [self confirmAppointment:[dict objectForKey:@"id"] withSender:sender];
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}


-(void)dateSelect:(UIButton *)sender
{
    NSDictionary *dict = _meetingDetailsDictionary;
    
    pickerVw = [[UIView alloc] init];
    
    pickerVw.backgroundColor = [UIColor clearColor];
    pickerVw.frame = CGRectMake(0,0,SCREENWIDTH,SCREENHEIGHT);
    
    
    UIView *backVw = [[UIView alloc] init];
    
    backVw.backgroundColor = [UIColor blackColor];
    backVw.alpha = 0.65;
    backVw.frame = CGRectMake(0,0,SCREENWIDTH,SCREENHEIGHT);
    
    [pickerVw addSubview:backVw];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    tabbar = [[CustomTabBarController alloc] init];
    
    datepicker = [[UIDatePicker alloc]init];
    
    datepicker.frame = CGRectMake(0, (pickerVw.frame.size.height - (236+tabbar.tabBar.frame.size.height)), SCREENWIDTH, 236);
    
    [datepicker setDatePickerMode:UIDatePickerModeDate];
    datepicker.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"%@",[dict objectForKey:@"fdate"]);
    NSLog(@"%@",[dict objectForKey:@"sdate"]);
    
    NSLog(@"%@",[dateFormatter dateFromString:[dict objectForKey:@"fdate"]]);
    
    [datepicker setMinimumDate:[dateFormatter dateFromString:[dict objectForKey:@"fdate"]]];
    [datepicker setMaximumDate:[dateFormatter dateFromString:[dict objectForKey:@"sdate"]]];
    
    [datepicker setDate:[dateFormatter dateFromString:[dict objectForKey:@"fdate"]]];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    date = [dateFormatter stringFromDate:datepicker.maximumDate];
    
    [datepicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    [pickerVw addSubview:datepicker];
    
    
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,(pickerVw.frame.size.height - (tabbar.tabBar.frame.size.height+datepicker.frame.size.height+44)),SCREENWIDTH,44)];
    
    toolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    
    doneButton.tag = sender.tag;
    
    [toolbar setItems:[NSArray arrayWithObjects:cancelButton, flexibleSpaceLeft, doneButton, nil]];
    
    [pickerVw addSubview:toolbar];
    
    [self.view addSubview:pickerVw];
}


- (void)datePickerChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    date = [dateFormatter stringFromDate:datepicker.date];
    
    NSLog(@"Date: %@", date);
}

-(IBAction)doneAction:(UIButton *)sender
{
    NSDictionary *dict = _meetingDetailsDictionary;
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if ([userType isEqualToString:@"Guest"])
    {
        [self confirmAppointment:[dict objectForKey:@"id"] withSender:sender];
        
        [pickerVw removeFromSuperview];
    }
    else
    {
        [self roomSelect:sender];
        
        [pickerVw removeFromSuperview];
    }
}

-(IBAction)cancelAction:(UIButton *)sender
{
    [pickerVw removeFromSuperview];
}

-(void)confirmAppointment:(NSString *)appointmentId withSender:(UIButton *)sender{
    
    [SVProgressHUD show];
    
    NSDictionary *params;
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    NSString *meetingType = [dict objectForKey:@"appointmentType"];
    
    if ([userType isEqualToString:@"Guest"])
    {
        if ([meetingType isEqualToString:@"flexible"]) {
            
            params = @{@"appid":appointmentId,@"status":@"confirm",@"userid":userId,@"date":date};
        }
        else
        {
            params = @{@"appid":appointmentId,@"status":@"confirm",@"userid":userId};
        }
    }
    else
    {
        if ([meetingType isEqualToString:@"flexible"]) {
            
            params = @{@"appid":appointmentId,@"status":@"confirm",@"location":locationName,@"userid":userId,@"date":date};
        }
        else
        {
            params = @{@"appid":appointmentId,@"status":@"confirm",@"location":locationName,@"userid":userId};
        }
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@set_status.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            _statusImage.image = [UIImage imageNamed:@"confirm.png"];
            
            [self.confirmedImage setHidden:YES];
            [self.btnConfirmedMeetingOutlet setHidden:YES];
            [self.btnEndMeetingOutlet setHidden:NO];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No appointments found."
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


-(void)cancelAppointment:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"appid":appointmentId,@"status":@"cancel",@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@set_status.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            [self.confirmedImage setHidden:YES];
            [self.btnConfirmedMeetingOutlet setHidden:YES];
            [self.cancelImage setHidden:YES];
            [self.btnCancelMeetingOutlet setHidden:YES];
            [self.btnEndMeetingOutlet setHidden:YES];
            [self.calenderImage setHidden:YES];
            [self.btnSaveToCalenderOutlet setHidden:YES];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No appointments found."
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


-(void)endAppointment:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"appid":appointmentId,@"status":@"end",@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@set_status.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            [self.confirmedImage setHidden:YES];
            [self.btnConfirmedMeetingOutlet setHidden:YES];
            [self.cancelImage setHidden:YES];
            [self.btnCancelMeetingOutlet setHidden:YES];
            [self.btnEndMeetingOutlet setHidden:YES];
            [self.calenderImage setHidden:YES];
            [self.btnSaveToCalenderOutlet setHidden:YES];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No appointments found."
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


-(IBAction)btnCallDidTap:(id)sender{
    
    NSDictionary *dict = _meetingDetailsDictionary;
    
    NSDictionary *dictUserDetails = [dict objectForKey:@"userdetails"];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",[dictUserDetails objectForKey:@"phone"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        [[UIApplication sharedApplication] openURL:phoneUrl];
        
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}


- (IBAction)btnMenuDidTap:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
}

-(void)getUpcomingMeetings{
    
    if ([UserId length]>0) {
        
        NSDictionary *params = @{@"userid":UserId};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        NSString *host_url = [NSString stringWithFormat:@"%@upcoming_appointments.php",BASE_URL];
        
        [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *responseDict = responseObject;
            NSString *success = [responseDict objectForKey:@"status"];
            
            if ([success isEqualToString:@"success"]) {
                
                meetingsArr = [responseDict objectForKey:@"apointments"];
                
                NSLog(@"cLoc: %@", cLoc);
                
                [self IsMeetingToday:cLoc];
                
                //NSLog(@"meetingsArr: %@", meetingsArr);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
        }];
        
    }
}


-(void)getTodaysMeetings:(NSString *)currentDate
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId,@"date":currentDate};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_todaysMeetings.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [self getRoomsAvailableonDate:currentDate];
            
            [SVProgressHUD dismiss];
            
            //            NSMutableArray *meetingsArr = [responseDict objectForKey:@"apointments"];
            //
            //            //NSLog(@"meetingsArr: %@", meetingsArr);
            //
            //            if ([meetingsArr count]>0) {
            //
            //                for (NSDictionary *dict in meetingsArr) {
            //
            //                    NSString *appointmentId = [dict objectForKey:@"id"];
            //
            //                    NSMutableArray *arrMeetings = [db getMeetingsById:appointmentId];
            //
            //                    if ([arrMeetings count]==0) {
            //
            //
            //                    }
            //                }
            //            }
            
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
    
    
-(void)getRoomsAvailableonDate:(NSString *)currentDate
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"date":currentDate};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@RoomsAvailable.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getReviewByAppointmentId:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    
    NSDictionary *params;
    
    params = @{@"appid":appointmentId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@all_reviewByapp.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        NSDictionary *dict = responseDict;
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            commentsArray = [dict objectForKey:@"review"];
            
            [_tableViewComments reloadData];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"No Review found."
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


-(void)createReviewByAppointmentId:(NSString *)appointmentId andReview:(NSString *)review{
    
    [SVProgressHUD show];
    
    NSDictionary *params;
    
    params = @{@"appid":appointmentId,@"review":review,@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@createReview.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            [self.view endEditing:YES];
            
            [self getReviewByAppointmentId:appointmentId];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Review post not done successfully, try again."
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

    
-(void)RescheduleAppointment:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"appid":appointmentId,@"contact":[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"],@"from_time":fromTime,@"to_time":toTime,@"duration":DuraTion,@"fdate":fDateSel};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@reschedule.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            [self getAppointmentByID:appointmentId];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appointment rescheduled successfully."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];

            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appointment reschedule error, please try again."
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
    

-(void)getAppointmentByID:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"appid":appointmentId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@getappointment_by_id.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            _meetingDetailsDictionary = [[responseDict objectForKey:@"apointments"] objectAtIndex:0];
            
            [self setUpDetails];
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appointment reschedule error, please try again."
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
    

@end
