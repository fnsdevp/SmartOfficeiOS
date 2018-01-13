//
//  MeetingFormViewController.m
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "MeetingFormViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "Constants.h"
#import "SVProgressHUD.h"
#import "VeeContactPickerViewController.h"
#import "VenueSelectionView.h"

@interface MeetingFormViewController (){
    
    NSArray *hours;
    UIView *navView;
    bool firstDate;
    bool secondDate;
    
    NSString *userId;
    NSString *department;
    NSString *designation;
    NSString *fromTime;
    NSString *toTime;
    NSString *duration;
    NSString *agenda;
    NSString *fdate;
    NSString *sdate;
    NSString *hr;
    NSString *min;
    NSString *per;
    NSString *daySel;
    NSString *monthSel;
    NSString *yearSel;
    
    NSString *fDateSel;
    NSString *sDateSel;
    NSString *phone;
    NSArray *venues;
    
    NSMutableArray *arrTimes;
    NSMutableArray *arrIndex;
    
    ContactsTableController *contactVC;
    
    VenueSelectionView *venueSelect;

}

@end

@implementation MeetingFormViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [SVProgressHUD dismiss];
    
    hours = @[@"10:00 AM-11:00 AM",@"11:00 AM-12:00 PM",@"12:00 PM-01:00 PM",@"01:00 PM-02:00 PM",@"02:00 PM-03:00 PM",@"03:00 PM-04:00 PM",@"04:00 PM-05:00 PM",@"05:00 PM-06:00 PM"];
    
    venues = @[@"Conference Room",@"Director's Room"];
    
    //_confirmationView.hidden = YES;
    
    _confirmMeetingView.layer.cornerRadius = 5.0f;
    
    fdate = @"";
    sdate = @"";
    fromTime = @"";
    toTime = @"";
    
    arrTimes = [[NSMutableArray alloc] init];
    
    arrBooked = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    
    fdate = [dateFormatter stringFromDate:[NSDate date]];
    sdate = @"";
    
    selectedDate = fdate;
    
    initialDate = [dateFormatter dateFromString:fdate];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"departmentsArr : %@",_departmentsArr);
    
    db = [Database sharedDB];
    
    navView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [navView addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, navView.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
    isCurrentWeek = YES;
    
    NSString *blueText = @"Schedule";
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
    
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _timeView.frame.origin.y+_timeView.frame.size.height+60);
    
    NSDateFormatter *dateFormatterForAPI = [[NSDateFormatter alloc]init];
    [dateFormatterForAPI setDateFormat:@"yyyy-MM-dd"];
    
//    fDateSel = [dateFormatterForAPI stringFromDate:[NSDate date]];
//    sDateSel = [dateFormatterForAPI stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(24*60*60)]];
    
    fDateSel = [dateFormatterForAPI stringFromDate:[NSDate date]];
    sDateSel = @"";
    
    [self.txtDepartmentName setValue:[UIColor whiteColor]
                          forKeyPath:@"_placeholderLabel.textColor"];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    [self.collectionViewDates registerNib:[UINib nibWithNibName:@"MeetingFormCollectionViewCell" bundle:[NSBundle mainBundle]]
               forCellWithReuseIdentifier:@"MeetingFormCollectionViewCell"];
    
    
    [self.collectionViewTimes registerNib:[UINib nibWithNibName:@"MeetingTimeCollectionViewCell" bundle:[NSBundle mainBundle]]
               forCellWithReuseIdentifier:@"MeetingTimeCollectionViewCell"];
    
    
   // [self getMeetingTimes];

    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
    
    NSDate *currentdate = [NSDate date];
    
    [dt setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currentDateStr = [dt stringFromDate:currentdate];
    
   // [self getTodaysMeetings:currentDateStr];
    
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if ([userType isEqualToString:@"Guest"]) {
        
       // [self getEmployeeavailTimeforDate:currentDateStr];
        
    } else {
        
        [self getUseravailTimeforDate:currentDateStr];
    }
    
    _confirmationView.hidden = YES;
    
    
    //NSLog(@"_confirmationView-x: %f",_confirmationView.frame.origin.x);
    //NSLog(@"_confirmationView-y: %f",_confirmationView.frame.origin.y);
    
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [navView removeFromSuperview];
}


-(NSArray *)setTheDate:(NSDate *)Date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar startOfDayForDate:Date];
    
    NSLog(@"%@", startDate);
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE MMM dd HH:mm:ss YYYY"];
    NSString *startDateStr = [format stringFromDate:startDate];
    
    NSArray *dateArr = [startDateStr componentsSeparatedByString:@" "];
    
    return dateArr;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}


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
    
    if(collectionView == self.collectionViewDates){
        
        return 8;
        
    }else{
        
        return [hours count];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == self.collectionViewDates){
    
        return CGSizeMake(58, 61);
    }
    else
    {
        CGSize sizes = CGSizeMake(SCREENWIDTH/2, 46 * (self.view.frame.size.height/480));
        
        return sizes;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == self.collectionViewDates){
        
        static NSString *identifier = @"MeetingFormCollectionViewCell";
        
        MeetingFormCollectionViewCell *cell1 = (MeetingFormCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        cell1.tag = indexPath.item;
        cell1.btnDate.tag = indexPath.item;
        cell1.delegate = self;
        
        
        if (isSelectedDate) {
            
            NSLog(@"%d",(int)indexPath.item);
            
            if (indexPath.item==0) {
                
                nextday = initialDate;
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                
            }
            else
            {
                nextday = initialDate;
                nextday = [NSDate dateWithTimeInterval:((indexPath.item)*(24*60*60)) sinceDate:nextday];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
            }
            
            
            NSLog(@"%@",nextday);
            NSLog(@"%d",(int)cell1.tag);
            
            
            [cell1.btnDate setSelected:NO];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            [df setDateFormat:@"EEE"];
            
            day = [df stringFromDate:nextday];
            
            cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
            
            [df setDateFormat:@"d"];
            
            date = [df stringFromDate:nextday];
            
            cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
            
            [df setDateFormat:@"MMM"];
            
            month = [df stringFromDate:nextday];
            
            cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
            
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            
            BOOL isWeekEnd = [calendar isDateInWeekend:nextday];
            
            
            if (isWeekEnd) {
                
                [cell1.imgBg setHidden:NO];
                
                cell1.imgBg.image = [UIImage imageNamed:@"holidayImg"];
                
                cell1.lblday.textColor = [UIColor redColor];
                cell1.lblDate.textColor = [UIColor redColor];
                cell1.lblMonth.textColor = [UIColor redColor];
                
                cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                
                cell1.alpha = 1.0;
                
            }
            else
            {
                cell1.lblday.textColor = [UIColor whiteColor];
                cell1.lblDate.textColor = [UIColor whiteColor];
                cell1.lblMonth.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                [cell1.imgBg setHidden:YES];
                
                cell1.alpha = 0.4;
                
            }
            
            [df setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *fDate = [df dateFromString:[NSString stringWithFormat:@"%@",fdate]];
            
            NSComparisonResult compare1 = [nextday compare:fDate];
            
            if (compare1==NSOrderedSame) {
                
                [cell1.btnDate  setSelected:YES];
                
                [cell1.imgBg setHidden:NO];
                
                cell1.imgBg.image = [UIImage imageNamed:@"currentDateImg"];
                
                cell1.lblday.textColor = [UIColor whiteColor];
                cell1.lblDate.textColor = [UIColor whiteColor];
                cell1.lblMonth.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                cell1.alpha = 1.0;
            }
            
            
            if (indexPath.item==7) {
                
                //nextday = initialDate;
                
                [cell1.imgBg setHidden:YES];
                
                cell1.lblday.text = [NSString stringWithFormat:@""];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
                cell1.lblDate.text = [NSString stringWithFormat:@"More"];
                
                cell1.lblMonth.text = [NSString stringWithFormat:@""];
                
                cell1.lblDate.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                
                cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                
                [cell1.imgBg setHidden:YES];
                
                cell1.alpha = 0.4;
                
            }
            
            
        } else {
            
            if (indexPath.item==0) {
                
                nextday = [NSDate date];
                
            } else {
                
                nextday = [NSDate date];
                nextday = [NSDate dateWithTimeInterval:((indexPath.item)*(24*60*60)) sinceDate:nextday];
            }
            
            if (indexPath.item==0) {
                
                if (cell1.userInteractionEnabled) {
                    
                    [cell1.btnDate  setSelected:YES];
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    
                    [df setDateFormat:@"EEE"];
                    
                    day = [df stringFromDate:nextday];
                    
                    cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
                    
                    [df setDateFormat:@"d"];
                    
                    date = [df stringFromDate:nextday];
                    
                    cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
                    
                    [df setDateFormat:@"MMM"];
                    
                    month = [df stringFromDate:nextday];
                    
                    cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
                    
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:nextday];
                    
                    if (isWeekEnd) {
                        
                        cell1.imgBg.image = [UIImage imageNamed:@"holidayImg"];
                        
                        cell1.lblday.textColor = [UIColor redColor];
                        cell1.lblDate.textColor = [UIColor redColor];
                        cell1.lblMonth.textColor = [UIColor redColor];
                        
                        cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                        cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                        cell1.alpha = 1.0;
                        
                    } else {
                        
                        cell1.imgBg.image = [UIImage imageNamed:@"currentDateImg"];
                        
                        cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                        
                        cell1.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                        cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];

                    }
                    
                }
                else
                {
                    [cell1.btnDate setSelected:NO];
                    
                    cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                    
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    
                    [df setDateFormat:@"EEE"];
                    
                    day = [df stringFromDate:nextday];
                    
                    cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
                    
                    [df setDateFormat:@"d"];
                    
                    date = [df stringFromDate:nextday];
                    
                    cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
                    
                    [df setDateFormat:@"MMM"];
                    
                    month = [df stringFromDate:nextday];
                    
                    cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
                    
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:nextday];
                    
                    if (isWeekEnd) {
                        
                        cell1.imgBg.image = [UIImage imageNamed:@"holidayImg"];
                        
                        cell1.lblday.textColor = [UIColor redColor];
                        cell1.lblDate.textColor = [UIColor redColor];
                        cell1.lblMonth.textColor = [UIColor redColor];
                        
                        cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                        cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                        cell1.alpha = 1.0;
                        
                    }
                    else
                    {
                        cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                        cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                        [cell1.imgBg setHidden:YES];
                        cell1.alpha = 0.4;
                    }

                }
                
            }
            else
            {
                
                [cell1.btnDate setSelected:NO];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                
                [df setDateFormat:@"EEE"];
                
                day = [df stringFromDate:nextday];
                
                cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
                
                [df setDateFormat:@"d"];
                
                date = [df stringFromDate:nextday];
                
                cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
                
                [df setDateFormat:@"MMM"];
                
                month = [df stringFromDate:nextday];
                
                cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
                
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:nextday];
                
                if (isWeekEnd) {
                    
                    cell1.imgBg.image = [UIImage imageNamed:@"holidayImg"];
                    
                    cell1.lblday.textColor = [UIColor redColor];
                    cell1.lblDate.textColor = [UIColor redColor];
                    cell1.lblMonth.textColor = [UIColor redColor];
                    
                    cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                    cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                    cell1.alpha = 1.0;
                    
                }
                else
                {
                    cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                    cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                    [cell1.imgBg setHidden:YES];
                    cell1.alpha = 0.4;
                }
                
                if (indexPath.item==7) {
                    
//                    nextday = [NSDate date];
                    
                    [cell1.imgBg setHidden:YES];
                    
                    cell1.lblday.text = [NSString stringWithFormat:@""];
                    
                    cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
                    cell1.lblDate.text = [NSString stringWithFormat:@"More"];
                    
                    cell1.lblMonth.text = [NSString stringWithFormat:@""];
                    
                    cell1.lblDate.textColor = [UIColor whiteColor];
                    
                    cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                    cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                    [cell1.imgBg setHidden:YES];
                    cell1.alpha = 0.4;
                }
                
            }
            
        }
        
        return cell1;
    }
    else
    {
        static NSString *identifier = @"MeetingTimeCollectionViewCell";
        
        MeetingTimeCollectionViewCell *cell2 = (MeetingTimeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        if ([userType isEqualToString:@"Guest"]) {
            
            cell2.tag = indexPath.item;
            cell2.btnTime.tag = indexPath.item;
            cell2.delegate = self;
            
            if ([phone length]>0) {
                
                [self timeSlotSettings:cell2 withIndexPath:indexPath];
                
            } else {
                
                [cell2.btnTime setTitle:[NSString stringWithFormat:@"%@",[hours objectAtIndex:indexPath.item]] forState:UIControlStateNormal];
                
                [cell2.btnTime setSelected:NO];
                [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                [cell2.btnTime setEnabled:NO];
                
                cell2.btnTime.alpha = 0.4;
            }
            
        } else {
            
            cell2.tag = indexPath.item;
            cell2.btnTime.tag = indexPath.item;
            cell2.delegate = self;
            
            [self timeSlotSettings:cell2 withIndexPath:indexPath];
        }
        
        return cell2;
    }
    
}


-(void)timeSlotSettings:(MeetingTimeCollectionViewCell *)cell2 withIndexPath:(NSIndexPath *)indexPath
{
    [cell2.btnTime setTitle:[NSString stringWithFormat:@"%@",[hours objectAtIndex:indexPath.item]] forState:UIControlStateNormal];
    
    if (isSelectedTime) {
        
        NSArray *arr1 = [[hours objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"];
        
        NSString *firstTime = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        
        NSString *strDateTime = [NSString stringWithFormat:@"%@ %@",fdate,firstTime];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
        
        NSDate *FirstDate = [dt dateFromString:strDateTime];
        
        NSDate *currentDate = [NSDate date];
        
        NSComparisonResult compare = [currentDate compare:FirstDate];
        
        
        if((compare==NSOrderedAscending)||(compare==NSOrderedSame))
        {
            if (![arrBooked containsObject:[hours objectAtIndex:indexPath.item]]) {
                
                if ([arrTimes containsObject:[hours objectAtIndex:indexPath.item]]) {
                    
                    [cell2.btnTime setSelected:YES];
                    [cell2.btnTime setEnabled:YES];
                    [cell2.btnTime setBackgroundColor:[UIColor blackColor]];
                    [cell2.btnTime setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                    
                    UIColor *color = [UIColor whiteColor];
                    cell2.btnTime.layer.shadowColor = [color CGColor];
                    cell2.btnTime.layer.shadowRadius = 5.0f;
                    cell2.btnTime.layer.shadowOpacity = .9;
                    cell2.btnTime.layer.shadowOffset = CGSizeZero;
                    cell2.btnTime.layer.masksToBounds = NO;
                    
                    [arrTimes addObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
                    
                }
                else
                {
                    [cell2.btnTime setSelected:NO];
                    [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                    [cell2.btnTime setEnabled:YES];
                    
                    if ([arrTimes containsObject:[hours objectAtIndex:(int)cell2.btnTime.tag]]) {
                        
                        [arrTimes removeObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
                    }
                }
                
                cell2.btnTime.alpha = 1.0;
                
            } else {
                
                [cell2.btnTime setSelected:NO];
                [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                [cell2.btnTime setEnabled:NO];
                
                cell2.btnTime.alpha = 0.4;
                
                if ([arrTimes containsObject:[hours objectAtIndex:(int)cell2.btnTime.tag]]) {
                    
                    [arrTimes removeObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
                }
            }
            
        }
        else if (compare==NSOrderedDescending)
        {
            [cell2.btnTime setSelected:NO];
            [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
            [cell2.btnTime setEnabled:NO];
            
            cell2.btnTime.alpha = 0.4;
            
            if ([arrTimes containsObject:[hours objectAtIndex:(int)cell2.btnTime.tag]]) {
                
                [arrTimes removeObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
            }
        }
        
        
    } else {
        
        NSArray *arr1 = [[hours objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"];
        
        NSString *firstTime = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        
        NSString *strDateTime = [NSString stringWithFormat:@"%@ %@",fdate,firstTime];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dt setLocale:locale];
        
        [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
        
        NSDate *FirstDate = [dt dateFromString:strDateTime];
        
        NSDate *currentDate = [NSDate date];
        
        NSComparisonResult compare = [currentDate compare:FirstDate];
        
        
        if((compare==NSOrderedAscending)||(compare==NSOrderedSame))
        {
            if (![arrBooked containsObject:[hours objectAtIndex:indexPath.item]]) {
                
                if ([arrTimes count]==0) {
                    
                    [cell2.btnTime setSelected:YES];
                    [cell2.btnTime setEnabled:YES];
                    [cell2.btnTime setBackgroundColor:[UIColor blackColor]];
                    [cell2.btnTime setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                    
                    UIColor *color = [UIColor whiteColor];
                    cell2.btnTime.layer.shadowColor = [color CGColor];
                    cell2.btnTime.layer.shadowRadius = 5.0f;
                    cell2.btnTime.layer.shadowOpacity = .9;
                    cell2.btnTime.layer.shadowOffset = CGSizeZero;
                    cell2.btnTime.layer.masksToBounds = NO;
                    
                    [arrTimes addObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
                    
                }
                else
                {
                    [cell2.btnTime setSelected:NO];
                    [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                    [cell2.btnTime setEnabled:YES];
                    
                    if ([arrTimes containsObject:[hours objectAtIndex:(int)cell2.btnTime.tag]]) {
                        
                        [arrTimes removeObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
                    }
                }
                
                cell2.btnTime.alpha = 1.0;
                
            } else {
                
                [cell2.btnTime setSelected:NO];
                [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                [cell2.btnTime setEnabled:NO];
                
                cell2.btnTime.alpha = 0.4;
                
                if ([arrTimes containsObject:[hours objectAtIndex:(int)cell2.btnTime.tag]]) {
                    
                    [arrTimes removeObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
                }
            }
            
        }
        else if (compare==NSOrderedDescending)
        {
            [cell2.btnTime setSelected:NO];
            [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
            [cell2.btnTime setEnabled:NO];
            
            cell2.btnTime.alpha = 0.4;
            
            if ([arrTimes containsObject:[hours objectAtIndex:(int)cell2.btnTime.tag]]) {
                
                [arrTimes removeObject:[hours objectAtIndex:(int)cell2.btnTime.tag]];
            }
        }
        
    }

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionViewDates){
        
        MeetingFormCollectionViewCell *cell1 = (MeetingFormCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell1.delegate = self;
        
    }else{
        
        MeetingTimeCollectionViewCell *cell2 = (MeetingTimeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell2.delegate = self;
    }
}


#pragma Mark - MeetingTimeCollectionViewCellDelegate

- (void)cellTap:(id)sender {
    
    MeetingTimeCollectionViewCell* cell = (MeetingTimeCollectionViewCell *)sender;
    
    UIButton* btn = cell.btnTime;
    
    isSelectedTime = YES;
    
    if ([btn isSelected]) {
        
        NSLog(@"btn.tag: %d",(int)btn.tag);
        NSLog(@"([hours count]-1): %d",(int)([hours count]-1));
        
        if ([arrTimes count]==1) {
            
            btnTag = (int)btn.tag;
            
            UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Alert"
                                                                          message:@"You have to select atleast one date to schedule an meeting."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action)
                                       {
                                           
                                           NSLog(@"btn.tag: %d",(int)btn.tag);
                                           NSLog(@"btnTag: %d",btnTag);
                                           
                                           [self.collectionViewTimes reloadData];
                                           
                                       }];
            
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else
        {
            [btn setSelected:NO];
            [btn setBackgroundColor:[UIColor whiteColor]];
            
            [arrTimes removeObject:[hours objectAtIndex:(int)btn.tag]];
            
            [self deselectAutoDates:btn.tag];
        }
        
    } else {
        
        [btn setSelected:YES];
        [btn setBackgroundColor:[UIColor blackColor]];
        
        UIColor *color = [UIColor whiteColor];
        btn.layer.shadowColor = [color CGColor];
        btn.layer.shadowRadius = 5.0f;
        btn.layer.shadowOpacity = .7;
        btn.layer.shadowOffset = CGSizeZero;
        btn.layer.masksToBounds = NO;
        
        [arrTimes addObject:[hours objectAtIndex:(int)btn.tag]];
        
        [self selectAutoDates];
        
    }
    
    [self.collectionViewTimes reloadData];
}


#pragma Mark - MeetingFormCollectionViewCellDelegate

- (void)dateCellTap:(id)sender {
    
    MeetingFormCollectionViewCell* cell = (MeetingFormCollectionViewCell *)sender;
    
    UIButton* btn = cell.btnDate;
    
    if (btn.tag<7) {
        
        [btn setSelected:YES];
        
        seletedTag = (int)btn.tag;
        
        isSelectedDate = YES;
        
        arrTimes = [[NSMutableArray alloc] init];
        
        NSString *strDate = [NSString stringWithFormat:@"%@ %@, 2017",cell.lblDate.text,cell.lblMonth.text];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"d MMM, yyyy"];
        
        NSDate *currentdate = [dt dateFromString:strDate];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSString *currentDateStr = [dt stringFromDate:currentdate];
        
        fdate = currentDateStr;
        
        selectedDate = currentDateStr;
        
        NSDate *CDate = [dt dateFromString:selectedDate];
        
        NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
        
        NSDate *currentWeekDate = [NSDate dateWithTimeInterval:(24*60*60*7) sinceDate:currentDate];
        
        //[arrTimes addObject:[hours objectAtIndex:0]];
        
        [UIView animateWithDuration:0 animations:^{
            
            NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
            
            NSString *userType = [userDict objectForKey:@"usertype"];
            
            NSComparisonResult compare2 = [currentWeekDate compare:CDate];
            
            if ((compare2==NSOrderedDescending)||(compare2==NSOrderedSame)){
                
                isCurrentWeek = YES;
                
                if ([userType isEqualToString:@"Guest"]) {
                    
                    if ([phone length]>0) {
                        
                        [self getEmployeeavailTimeforDate:selectedDate];
                    }
                    
                } else {
                    
                    [self getUseravailTimeforDate:currentDateStr];
                }
            }
            else
            {
                isCurrentWeek = NO;
                
                if ([userType isEqualToString:@"Guest"]) {
                    
                    if ([phone length]>0) {
                        
                        [self getEmployeeavailTimeforDate:selectedDate];
                    }
                    
                } else {
                    
                    [self getUseravailTimeforDate:currentDateStr];
                }
            }
            
        } completion:^(BOOL finished) {
            //Do something after that...
            
            [self.collectionViewDates reloadData];
            
        }];
        
    }
    else
    {
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
        
        [self.collectionViewDates setContentOffset:CGPointZero animated:YES];
        
        [self.tabBarController presentViewController:dateSel animated:YES completion:nil];
    }
    
}


-(void)deselectAutoDates:(NSInteger)btnTag
{
    if ([arrTimes count]>1) {
        
        arrIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrTimes count]; i++) {
            
            [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[hours indexOfObject:[arrTimes objectAtIndex:i]]]];
            
            // NSLog(@"works");
            
        }
        
        NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
        
        int minInt = (int)btnTag;
        int maxInt = (int)[[copyArr lastObject] integerValue];
        
        arrTimes = [[NSMutableArray alloc] init];
        
        for (int j=maxInt; j>minInt; j--) {
            
            [arrTimes addObject:[hours objectAtIndex:j]];
        }
        
    }
}


-(void)selectAutoDates
{
    if ([arrTimes count]>1) {
        
        arrIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrTimes count]; i++) {
            
            [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[hours indexOfObject:[arrTimes objectAtIndex:i]]]];
            
            // NSLog(@"works");
            
        }
        
        NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
        
        int minInt = (int)[copyArr[0] integerValue];
        int maxInt = (int)[[copyArr lastObject] integerValue];
        
        arrTimes = [[NSMutableArray alloc] init];
        
        for (int j=maxInt; j>(minInt-1); j--) {
            
            [arrTimes addObject:[hours objectAtIndex:j]];
        }
        
    }
    
}

    
#pragma mark - WWCalendarSelector

- (void)WWCalendarTimeSelectorDone:(WWCalendarTimeSelector * _Nonnull)selector date:(NSDate * _Nonnull)date{
    
    NSDateFormatter *dateFormatterForAPI = [[NSDateFormatter alloc]init];
    
    [dateFormatterForAPI setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateForAPI = [dateFormatterForAPI stringFromDate:date];
    
    NSDate *CDate = [dateFormatterForAPI dateFromString:[dateFormatterForAPI stringFromDate:date]];
    
    NSDate *currentDate = [dateFormatterForAPI dateFromString:[dateFormatterForAPI stringFromDate:[NSDate date]]];
    
    NSComparisonResult compare = [currentDate compare:CDate];
    
    NSDate *currentWeekDate = [NSDate dateWithTimeInterval:(24*60*60*7) sinceDate:currentDate];
    
    if ((compare==NSOrderedAscending)||(compare==NSOrderedSame)) {
        
        fDateSel = dateForAPI;
        fdate = dateForAPI;
        sdate = @"";
        
        isSelectedDate = YES;
        
        initialDate = [dateFormatterForAPI dateFromString:[dateFormatterForAPI stringFromDate:date]];
        
        selectedDate = fdate;
        
    } else {
        
        [self showAlert];
        
        initialDate = [dateFormatterForAPI dateFromString:[dateFormatterForAPI stringFromDate:[NSDate date]]];
        
        fdate = [dateFormatterForAPI stringFromDate:initialDate];
        sdate = @"";
    }
  
    
   // nextday = initialDate;
    
    
    [UIView animateWithDuration:0 animations:^{
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        NSComparisonResult compare2 = [currentWeekDate compare:CDate];
        
        if ((compare2==NSOrderedDescending)||(compare2==NSOrderedSame)){
            
            isCurrentWeek = YES;
            
            if ([userType isEqualToString:@"Guest"]) {
                
                if ([phone length]>0) {
                    
                    [self getEmployeeavailTimeforDate:selectedDate];
                }
                
            } else {
                
                [self getUseravailTimeforDate:dateForAPI];
            }
        }
        else
        {
            isCurrentWeek = NO;
            
            if ([userType isEqualToString:@"Guest"]) {
                
                if ([phone length]>0) {
                    
                    [self getEmployeeavailTimeforDate:selectedDate];
                }
                
            } else {
                
                [self getUseravailTimeforDate:dateForAPI];
            }
        }
        
    } completion:^(BOOL finished) {
        //Do something after that...
        
        [self.collectionViewDates reloadData];
        
        [self.collectionViewDates setContentOffset:CGPointZero animated:YES];
        
    }];
    
}

    
-(void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You cannot select previous date to schedule a meeting."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    
    [alertView show];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)btnConfirmDidTap:(id)sender{
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if (![userType isEqualToString:@"Guest"])
    {
        [self selectRoom:userType];
    }
    else
    {
        [self bookFixedMeeting:userType];
    }
}

- (IBAction)btnConfirmedOkDidTap:(id)sender {
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         _confirmationView.frame = CGRectMake(_confirmationView.frame.origin.x, self.tabBarController.view.frame.size.height+_confirmationView.frame.size.height, _confirmationView.frame.size.width, _confirmationView.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    [_confirmationView removeFromSuperview];
    
    _confirmationView.hidden = YES;
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (IBAction)btnDrawerMenuDidTap:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
}

-(void)selectRoom:(NSString *)type
{
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
        
        if (![type isEqualToString:@"Guest"])
        {
            locationName = @"conference room";
        }
        
        [self bookFixedMeeting:type];
        
        // Distructive button tapped.
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Director room" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (![type isEqualToString:@"Guest"])
        {
            locationName = @"director room";
        }
        
        [self bookFixedMeeting:type];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}


-(void)makeTimes
{
    if ([arrTimes count]>0) {
        
        arrIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrTimes count]; i++) {
            
            [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[hours indexOfObject:[arrTimes objectAtIndex:i]]]];
            
            // NSLog(@"works");
            
        }
        
        NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
        
        int minInt = (int)[copyArr[0] integerValue];
        int maxInt = (int)[[copyArr lastObject] integerValue];
        
        NSArray *arr1 = [[hours objectAtIndex:minInt] componentsSeparatedByString:@"-"];
        
        fromTime = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        
        NSArray *arr2 = [[hours objectAtIndex:maxInt] componentsSeparatedByString:@"-"];
        
        toTime = [NSString stringWithFormat:@"%@",[arr2 objectAtIndex:1]];
        
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
        
        NSString *fulldate1 = [NSString stringWithFormat:@"%@ %@",fdate,fromTime];
        
        NSDate* date1 = [dt dateFromString:fulldate1];
        
        NSString *fulldate2 = [NSString stringWithFormat:@"%@ %@",fdate,toTime];
        
        NSDate* date2 = [dt dateFromString:fulldate2];
        
        
        NSCalendar *c = [NSCalendar currentCalendar];
       
        
        NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:date1 toDate:date2 options:0];
        
        NSInteger diff = components.hour;
        
        duration = [NSString stringWithFormat:@"%d",(int)diff];
        
    }
}


-(void)bookFixedMeeting:(NSString *)type{
    
    if([self notEmptyChecking] == NO){return;}
    
    [SVProgressHUD show];
    
    [self makeTimes];
    
    if (([self.txtDepartmentName.text isEqualToString:@""])||([self.txtDepartmentName.text length]==0))
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enter contact name."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        
    } else {
        
        if ([fromTime length]>0) {
            
            department = @"";
            
            fDateSel = fdate;
            
            NSDictionary *params;
            
            if ([type isEqualToString:@"Guest"]) {
                
                if(([phone isEqualToString:@""])||([phone length]==0)){
                    
                    params = @{@"contact":[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"],@"department":department,@"designation":@"CEO",@"from_time":fromTime,@"to_time":toTime,@"duration":duration,@"agenda":_txtFieldAgenda.text,@"fdate":fDateSel,@"sdate":sDateSel,@"pushid_g":@"",@"phone":@"",@"location":@"None"};
                    
                }else{
                    
                    params = @{@"contact":[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"],@"department":@"",@"designation":@"CEO",@"from_time":fromTime,@"to_time":toTime,@"duration":duration,@"agenda":_txtFieldAgenda.text,@"fdate":fDateSel,@"sdate":sDateSel,@"pushid_g":@"",@"phone":phone,@"location":@"None"};
                    
                }
            }
            else
            {
                if(([phone isEqualToString:@""])||([phone length]==0)){
                    
                    params = @{@"contact":[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"],@"department":department,@"designation":@"CEO",@"from_time":fromTime,@"to_time":toTime,@"duration":duration,@"agenda":_txtFieldAgenda.text,@"fdate":fDateSel,@"sdate":sDateSel,@"pushid_g":@"",@"phone":@"",@"location":locationName};
                    
                }else{
                    
                    params = @{@"contact":[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"],@"department":department,@"designation":@"CEO",@"from_time":fromTime,@"to_time":toTime,@"duration":duration,@"agenda":_txtFieldAgenda.text,@"fdate":fDateSel,@"sdate":sDateSel,@"pushid_g":@"",@"phone":phone,@"location":locationName};
                    
                }
            }
            
            
            NSLog(@"params :%@",params);
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
            
            NSString *host_url = [NSString stringWithFormat:@"%@bookNew.php",BASE_URL];
            
            [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"JSON: %@", responseObject);
                
                NSDictionary *responseDict = responseObject;
                
                NSString *success = [responseDict objectForKey:@"status"];
                
                if ([success isEqualToString:@"success"]) {
                    
                    [SVProgressHUD dismiss];
                    
                    _confirmationView.layer.shadowRadius = 30;
                    _confirmationView.layer.shadowColor = [[UIColor blackColor] CGColor];
                    _confirmationView.layer.shadowOpacity = 1.0;
                    
                    NSArray *months = @[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
                    
                    NSDateFormatter *dateFormatterForAPI = [[NSDateFormatter alloc]init];
                    [dateFormatterForAPI setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *Fdate = [dateFormatterForAPI dateFromString:fDateSel];
                    
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:Fdate];
                    
                    NSInteger day1 = [components day];
                    NSInteger month1 = [components month];
                    NSInteger year1 = [components year];
                    
                    daySel = [NSString stringWithFormat:@"%d",(int)day1];
                    
                    monthSel = [months objectAtIndex:(month1 -1)];
                    
                    yearSel = [NSString stringWithFormat:@"%d",(int)year1];
                    
                    NSUInteger characterCount = [daySel length];
                    
                    if (characterCount==1) {
                        
                        daySel = [NSString stringWithFormat:@"0%@",daySel];
                    }
                    
                    _lblDay1.text = daySel;
                    _lblMonth1.text = monthSel;
                    _lblYear1.text = yearSel;
                    
                    
                    _lblMeetingDateTime.text = [NSString stringWithFormat:@"Meeting on"];
                    
                    _lblMeetingWith.text = [NSString stringWithFormat:@"Meeting with %@",self.txtDepartmentName.text];
                    
                    // NSLog(@"%f",self.tabBarController.view.frame.size.height);
                    // NSLog(@"%f",_confirmationView.frame.size.height);
                    
                    _confirmationView.hidden = NO;
                    
                    
                    //  NSLog(@"%f",_confirmationView.frame.origin.y);
                    
                    [UIView animateWithDuration:0.5
                                          delay:0.1
                                        options: UIViewAnimationOptionCurveEaseIn
                                     animations:^{
                                         
                                     }
                                     completion:^(BOOL finished){
                                         
                                     }];
                    
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
            
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please select a  time."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            [SVProgressHUD dismiss];
        }
        
    }
    
}


-(void)getMeetingTimes{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_time.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            NSMutableArray *meetingsArr = [responseDict objectForKey:@"apointments"];
            
            //NSLog(@"meetingsArr: %@", meetingsArr);
            
            if ([meetingsArr count]>0) {
                
                for (NSDictionary *dict in meetingsArr) {
                    
                    
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


-(void)getUpcomingMeetings{
    
    //if([self notEmptyChecking] == NO){return;}
    
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
            
            NSMutableArray *meetingsArr = [responseDict objectForKey:@"apointments"];
            
            //NSLog(@"meetingsArr: %@", meetingsArr);
         
            if ([meetingsArr count]>0) {
                
                for (NSDictionary *dict in meetingsArr) {
                    
                    NSString *appointmentId = [dict objectForKey:@"id"];
                    
                    NSMutableArray *arrMeetings = [db getMeetingsById:appointmentId];
                    
                    if ([arrMeetings count]==0) {
                        
                        NSString *fDate = [dict objectForKey:@"fdate"];
                        
                        NSString *sDate = [dict objectForKey:@"sdate"];
                        
                        NSString *otp = [dict objectForKey:@"otp"];
                        
                        NSString *appointmentID = [NSString stringWithFormat:@"%d",(int)[[dict objectForKey:@"id"] integerValue]];
                        
                        NSString *employeeId = [NSString stringWithFormat:@"%d",(int)[[dict objectForKey:@"employee_id"] integerValue]];
                        
                        [db insertInMeetingTableWithAppointmentId:appointmentID andEmployeeId:employeeId andEmployeeName:[dict objectForKey:@"employee_name"] andEmployeeEmail:[dict objectForKey:@"employee_email"] andEmployeePhone:[dict objectForKey:@"employee_phone"] andDepartment:[dict objectForKey:@"department"] andAppointmentTime:[dict objectForKey:@"time"] anDuration:[dict objectForKey:@"duration"] anAgenda:[dict objectForKey:@"agenda"] andFdate:fDate anSdate:sDate andAppointmentType:[dict objectForKey:@"appointmentType"] andReadStatus:[dict objectForKey:@"read_status"] andStatus:[dict objectForKey:@"status"] andOtp:otp andEventId:@""];
                    }
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

    
-(void)getUseravailTimeforDate:(NSString *)Date
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId,@"date":Date};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_time_by_dateNuserid.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseDict allKeys] containsObject:@"timing"]) {
                
                arrTiming = [responseDict objectForKey:@"timing"];
                
                arrBooked = [[NSMutableArray alloc] init];
                
                if (isCurrentWeek) {
                    
                    [self checkAvailability:arrTiming];
                    
                } else {
                    
                    [self checkAvailableTime:arrTiming];
                }
                
            } else {
                
                if (isCurrentWeek) {
                    
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSString *msg = [responseDict objectForKey:@"message"];
                    
                    if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                    {
                        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                        
                        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                        
                        [dt setDateFormat:@"yyyy-MM-dd"];
                        
                        NSDate *currentDate = [dt dateFromString:Date];
                        
                        BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                        
                        if (isWeekEnd) {
                            
                            for (int i=0; i<[hours count]; i++) {
                                
                                if (![arrBooked containsObject:[hours objectAtIndex:i]])
                                {
                                    [arrBooked addObject:[hours objectAtIndex:i]];
                                }
                            }
                        }
                        
                    } else {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                        
                        [alertView show];
                    }
                    
                    [self.collectionViewTimes reloadData];
                    
                }
                else
                {
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[hours count]; i++) {
                            
                            if (![arrBooked containsObject:[hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                    [self.collectionViewTimes reloadData];
                    
                }
                
            }
            
            
        }else{
            
            if (isCurrentWeek) {
                
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                NSString *msg = [responseDict objectForKey:@"message"];
                
                if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                {
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[hours count]; i++) {
                            
                            if (![arrBooked containsObject:[hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                } else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                }
                
                [self.collectionViewTimes reloadData];
                
                [SVProgressHUD dismiss];
                
            }
            else
            {
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                
                [dt setDateFormat:@"yyyy-MM-dd"];
                
                NSDate *currentDate = [dt dateFromString:Date];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                    
                    for (int i=0; i<[hours count]; i++) {
                        
                        if (![arrBooked containsObject:[hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[hours objectAtIndex:i]];
                        }
                    }
                }
                
                [self.collectionViewTimes reloadData];
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
    
    
-(void)getEmployeeavailTimeforDate:(NSString *)Date
{
    [SVProgressHUD show];
    
    if ([phone length]==0) {
        
        phone = @"";
    }
    
    NSDictionary *params = @{@"phone":phone,@"date":Date};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableSet *jsonAcceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
    [jsonAcceptableContentTypes addObject:@"text/plain"];
    jsonResponseSerializer.acceptableContentTypes = jsonAcceptableContentTypes;
    
    manager.responseSerializer = jsonResponseSerializer;
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_time_by_numberNdate.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseDict allKeys] containsObject:@"timing"]) {
                
                arrTiming = [responseDict objectForKey:@"timing"];
                
                arrBooked = [[NSMutableArray alloc] init];
                
                if (isCurrentWeek) {
                    
                    [self checkAvailability:arrTiming];
                    
                } else {
                    
                   [self checkAvailableTime:arrTiming];
                }
                
            } else {
                
                if (isCurrentWeek) {
                    
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSString *msg = [responseDict objectForKey:@"message"];
                    
                    if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                    {
                        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                        
                        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                        
                        [dt setDateFormat:@"yyyy-MM-dd"];
                        
                        NSDate *currentDate = [dt dateFromString:Date];
                        
                        BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                        
                        if (isWeekEnd) {
                            
                            for (int i=0; i<[hours count]; i++) {
                                
                                if (![arrBooked containsObject:[hours objectAtIndex:i]])
                                {
                                    [arrBooked addObject:[hours objectAtIndex:i]];
                                }
                            }
                        }
                        
                    } else {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                        
                        [alertView show];
                    }
                    
                    [self.collectionViewTimes reloadData];
                   
                }
                else
                {
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[hours count]; i++) {
                            
                            if (![arrBooked containsObject:[hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                    [self.collectionViewTimes reloadData];
                }
                
            }
            
            
        }else{
            
            if (isCurrentWeek) {
                
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                NSString *msg = [responseDict objectForKey:@"message"];
                
                if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                {
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[hours count]; i++) {
                            
                            if (![arrBooked containsObject:[hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                } else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                }
                
                [self.collectionViewTimes reloadData];
                
                [SVProgressHUD dismiss];
                
            }
            else
            {
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                
                [dt setDateFormat:@"yyyy-MM-dd"];
                
                NSDate *currentDate = [dt dateFromString:Date];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                    
                    for (int i=0; i<[hours count]; i++) {
                        
                        if (![arrBooked containsObject:[hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[hours objectAtIndex:i]];
                        }
                    }
                }
                
                [self.collectionViewTimes reloadData];
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


-(void)checkAvailability:(NSArray *)arr
{
    for (NSDictionary *dict in arr) {
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *currentDate = [dt dateFromString:selectedDate];
        
        NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]]];
        
        NSComparisonResult compare = [currentDate compare:fromDate];
        
        if (compare==NSOrderedSame) {
            
            NSString *statusStr = [dict objectForKey:@"status"];
            
            if (([statusStr isEqual:[NSNull null]] )|| (statusStr==nil) || ([statusStr isEqualToString:@"<null>"]) || ([statusStr isEqualToString:@"(null)"]) || (statusStr.length==0 )|| ([statusStr isEqualToString:@""])|| (statusStr==NULL)||(statusStr == (NSString *)[NSNull null])||[statusStr isKindOfClass:[NSNull class]]|| (statusStr == (id)[NSNull null])) {
                
                statusStr = @"";
            }
            
            if ([statusStr isEqualToString:@"Y"])
            {
                NSString *givenFromTime = [dict objectForKey:@"from"];
                
                NSString *givenToTime = [dict objectForKey:@"to"];
                
                BOOL dontAddForm = false;
                BOOL dontAddTo = false;
                
                for (int i=0; i<[hours count]; i++) {
                    
                    NSArray *arr1 = [[hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                    
                    NSString *firstTime = [arr1 objectAtIndex:0];
                    
                    if (![firstTime isEqualToString:givenFromTime]) {
                        
                        if (dontAddForm==false) {
                            
                            if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                
                                [arrBooked addObject:[hours objectAtIndex:i]];
                            }
                        }
                    }
                    else if ([firstTime isEqualToString:givenFromTime])
                    {
                        dontAddForm = true;
                    }
                    
                    if (dontAddForm) {
                        
                        if ([firstTime isEqualToString:givenToTime]) {
                            
                            dontAddTo = true;
                            
                            if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                
                                [arrBooked addObject:[hours objectAtIndex:i]];
                            }
                            
                        }
                    }
                    
                    if (dontAddTo) {
                        
                        if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                            
                            [arrBooked addObject:[hours objectAtIndex:i]];
                        }
                    }
                }
                
                
                NSArray *arrMettings = [dict objectForKey:@"meetings"];
                
                NSMutableArray *FromArr = [[NSMutableArray alloc] init];
                NSMutableArray *ToArr = [[NSMutableArray alloc] init];
                
                
                if (([arrMettings isEqual:[NSNull null]] )||(arrMettings==nil)||(arrMettings==NULL)||(arrMettings == (NSArray *)[NSNull null])||[arrMettings isKindOfClass:[NSNull class]]|| (arrMettings == (id)[NSNull null])) {
                    
                    arrMettings = @[];
                    
                }
                
                if ([arrMettings count]>0) {
                    
                    for (NSDictionary *dict1 in arrMettings) {
                        
                        BOOL dontAddFormArr = false;
                        BOOL dontAddToArr = false;
                        
                        if ([[dict1 allKeys] containsObject:@"from"]) {
                            
                            [FromArr addObject:[dict1 objectForKey:@"from"]];
                            
                        }
                        
                        if ([[dict1 allKeys] containsObject:@"to"]){
                            
                            [ToArr addObject:[dict1 objectForKey:@"to"]];
                        }
                        
                        if ([FromArr count]>0) {
                            
                            for (int i=0; i<[hours count]; i++) {
                                
                                NSArray *arr1 = [[hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                                
                                if (dontAddFormArr) {
                                    
                                    if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                        
                                        dontAddToArr = true;
                                        
                                        if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                            
                                            [arrBooked addObject:[hours objectAtIndex:i]];
                                        }
                                    }
                                    else
                                    {
                                        if (dontAddToArr==0) {
                                            
                                            if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                                
                                                [arrBooked addObject:[hours objectAtIndex:i]];
                                            }
                                        }
                                    }
                                    
                                }
                                else
                                {
                                    if ([FromArr containsObject:[arr1 objectAtIndex:0]]) {
                                        
                                        dontAddFormArr = true;
                                        
                                        if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                            
                                            [arrBooked addObject:[hours objectAtIndex:i]];
                                        }
                                        
                                        if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                            
                                            dontAddToArr = true;
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                
            }
            else if ([statusStr isEqualToString:@"N"])
            {
                for (int i=0; i<[hours count]; i++) {
                    
                    if (![arrBooked containsObject:[hours objectAtIndex:i]])
                    {
                        [arrBooked addObject:[hours objectAtIndex:i]];
                    }
                }
                
            }
            else
            {
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                
                    for (int i=0; i<[hours count]; i++) {
                        
                        if (![arrBooked containsObject:[hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[hours objectAtIndex:i]];
                        }
                    }
                }
                else
                {
                    NSArray *arrMettings = [dict objectForKey:@"meetings"];
                    
                    NSMutableArray *FromArr = [[NSMutableArray alloc] init];
                    NSMutableArray *ToArr = [[NSMutableArray alloc] init];
                    
                    if (([arrMettings isEqual:[NSNull null]] )||(arrMettings==nil)||(arrMettings==NULL)||(arrMettings == (NSArray *)[NSNull null])||[arrMettings isKindOfClass:[NSNull class]]|| (arrMettings == (id)[NSNull null])) {
                        
                        arrMettings = @[];
                        
                    }
                    
                    
                    if ([arrMettings count]>0) {
                        
                        for (NSDictionary *dict1 in arrMettings) {
                            
                            BOOL dontAddFormArr = false;
                            BOOL dontAddToArr = false;
                            
                            if ([[dict1 allKeys] containsObject:@"from"]) {
                                
                                [FromArr addObject:[dict1 objectForKey:@"from"]];
                                
                            }
                            
                            if ([[dict1 allKeys] containsObject:@"to"]){
                                
                                [ToArr addObject:[dict1 objectForKey:@"to"]];
                            }
                            
                            if ([FromArr count]>0) {
                                
                                for (int i=0; i<[hours count]; i++) {
                                    
                                    NSArray *arr1 = [[hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                                    
                                    if (dontAddFormArr) {
                                        
                                        if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                            
                                            dontAddToArr = true;
                                            
                                            if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                                
                                                [arrBooked addObject:[hours objectAtIndex:i]];
                                            }
                                        }
                                        else
                                        {
                                            if (dontAddToArr==0) {
                                                
                                                if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                                    
                                                    [arrBooked addObject:[hours objectAtIndex:i]];
                                                }
                                            }
                                        }
                                        
                                    }
                                    else
                                    {
                                        if ([FromArr containsObject:[arr1 objectAtIndex:0]]) {
                                            
                                            dontAddFormArr = true;
                                            
                                            if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                                
                                                [arrBooked addObject:[hours objectAtIndex:i]];
                                            }
                                            
                                            if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                                
                                                dontAddToArr = true;
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        [self.collectionViewTimes reloadData];
    }
    
}


-(void)checkAvailableTime:(NSArray *)arr
{
    for (NSDictionary *dict in arr) {
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *currentDate = [dt dateFromString:selectedDate];
        
        NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]]];
        
        NSComparisonResult compare = [currentDate compare:fromDate];
        
        if (compare==NSOrderedSame) {
            
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            
            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
            
            [dt setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *currentDate = [dt dateFromString:selectedDate];
            
            BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
            
            if (isWeekEnd) {
                
                for (int i=0; i<[hours count]; i++) {
                    
                    if (![arrBooked containsObject:[hours objectAtIndex:i]])
                    {
                        [arrBooked addObject:[hours objectAtIndex:i]];
                    }
                }
            }
            else
            {
                NSArray *arrMettings = [dict objectForKey:@"meetings"];
                
                NSMutableArray *FromArr = [[NSMutableArray alloc] init];
                NSMutableArray *ToArr = [[NSMutableArray alloc] init];
                
                if (([arrMettings isEqual:[NSNull null]] )||(arrMettings==nil)||(arrMettings==NULL)||(arrMettings == (NSArray *)[NSNull null])||[arrMettings isKindOfClass:[NSNull class]]|| (arrMettings == (id)[NSNull null])) {
                    
                    arrMettings = @[];
                    
                }
                
                if ([arrMettings count]>0) {
                    
                    for (NSDictionary *dict1 in arrMettings) {
                        
                        if ([[dict1 allKeys] containsObject:@"from"]) {
                            
                            [FromArr addObject:[dict1 objectForKey:@"from"]];
                            
                        }
                        
                        if ([[dict1 allKeys] containsObject:@"to"]){
                            
                            [ToArr addObject:[dict1 objectForKey:@"to"]];
                        }
                    }
                    
                    if ([FromArr count]>0) {
                        
                        for (int i=0; i<[hours count]; i++) {
                            
                            NSArray *arr1 = [[hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                            
                            if ([FromArr containsObject:[arr1 objectAtIndex:0]]) {
                                
                                if (![arrBooked containsObject:[hours objectAtIndex:i]]) {
                                    
                                    [arrBooked addObject:[hours objectAtIndex:i]];
                                }
                            }
                        }
                        
                        for (int j=(int)[hours count]-1; j>=0; j--) {
                            
                            NSArray *arr1 = [[hours objectAtIndex:j] componentsSeparatedByString:@"-"];
                            
                            if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                
                                if (![arrBooked containsObject:[hours objectAtIndex:j]])
                                {
                                    [arrBooked addObject:[hours objectAtIndex:j]];
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
        [self.collectionViewTimes reloadData];
    }
    
}



-(BOOL)notEmptyChecking{
    
    if(_txtFieldAgenda.text.length<1){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Agenda cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        // [SVProgressHUD dismiss];
        
        [_txtFieldAgenda becomeFirstResponder];
        
        return NO;
        
    }else if([_txtDepartmentName.text isEqualToString:@"eg:any name"]){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Department cannot be empty."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        // [SVProgressHUD dismiss];
        //[_lblDepartmentName becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}


- (IBAction)btnAddContactDidTap:(id)sender {
    
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"9.0")) {
        
        contactVC = [[ContactsTableController alloc] init];
        
        contactVC.delegate = self;
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        
        [self presentViewController:contactVC animated:NO completion:nil];
    }
    else
    {
    
        VeeContactPickerViewController* veeContactPickerViewController = [[VeeContactPickerViewController alloc] initWithDefaultConfiguration];
        veeContactPickerViewController.contactPickerDelegate = self;
        [self presentViewController:veeContactPickerViewController animated:YES completion:nil];
    
    }
    
}
    
-(void)ContactsTableController:(ContactsTableController *)obj getName:(NSString *)name andphNo:(CNContact *)contact
{
    _txtDepartmentName.text = name;
    
    NSString *phoneStr;
    
    phone = [[[contact.phoneNumbers firstObject] value] stringValue];
    
    if ([phone length] > 0) {
        
        phoneStr = phone;
        
        department = @"";
    }
    
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *illegalCharacters = [digits invertedSet];
    NSArray *components = [phoneStr componentsSeparatedByCharactersInSet:illegalCharacters];
    
    phone = [components componentsJoinedByString:@""];
    
    [UIView animateWithDuration:0 animations:^{
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        if ([userType isEqualToString:@"Guest"]) {
            
            [self getEmployeeavailTimeforDate:fDateSel];
            
        } else {
            
            [self getUseravailTimeforDate:fDateSel];
        }
        
    } completion:^(BOOL finished) {
        //Do something after that...
        
    }];

}

-(void)ContactsTableController:(ContactsTableController *)obj getName:(NSString *)name withphNo:(NSString *)ph
{
    _txtDepartmentName.text = name;
    
    NSString *phoneStr;
    
    phoneStr = ph;
    
    department = @"";
    
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *illegalCharacters = [digits invertedSet];
    NSArray *components = [phoneStr componentsSeparatedByCharactersInSet:illegalCharacters];
    
    phone = [components componentsJoinedByString:@""];
    
    [UIView animateWithDuration:0 animations:^{
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        if ([userType isEqualToString:@"Guest"]) {
            
            [self getEmployeeavailTimeforDate:fDateSel];
            
        } else {
            
            [self getUseravailTimeforDate:fDateSel];
        }
        
    } completion:^(BOOL finished) {
        //Do something after that...
        
    }];
}

- (void)didSelectContact:(id<VeeContactProt>)veeContact
{
    //Do whatever you want with the selected veeContact!
    _txtDepartmentName.text = [veeContact displayName];

    NSString *phoneStr = [[veeContact phoneNumbers]objectAtIndex:0];
    
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *illegalCharacters = [digits invertedSet];
    NSArray *components = [phoneStr componentsSeparatedByCharactersInSet:illegalCharacters];
    
    phone = [components componentsJoinedByString:@""];
    
    [UIView animateWithDuration:0 animations:^{
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        if ([userType isEqualToString:@"Guest"]) {
            
            [self getEmployeeavailTimeforDate:fDateSel];
            
        } else {
            
            [self getUseravailTimeforDate:fDateSel];
        }
        
    } completion:^(BOOL finished) {
        //Do something after that...
        
    }];
    
}


- (void)didFailToAccessAddressBook
{
    //Show an error?
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please allow Phonebook access."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];

}

- (IBAction)btnSelectVenueDidTap:(id)sender {
    
    venueSelect = [[VenueSelectionView alloc] init];
    venueSelect.frame = self.view.bounds;
    venueSelect.backgroundColor = [UIColor clearColor];
    venueSelect.delegate = self;
    [self.view addSubview:venueSelect];
}

-(void)VenueSelectionView:(VenueSelectionView *)obj didTapOnTableViewIndex:(long)index{
    
    NSLog(@"index :%ld",index);
    _lblMeetingWith.text = [venues objectAtIndex:index];
    [venueSelect removeFromSuperview];
    
}

@end
