//
//  ManageMeetingsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ManageMeetingsViewController.h"
#import "ManageMeetingsTableViewCell.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Constants.h"
#import <MessageUI/MessageUI.h>
#import "ManageMeetingsDetailsViewController.h"
#import "IndoorMapViewController.h"

@interface ManageMeetingsViewController (){
    UIView *view;
    NSArray *appointmentsArray;
    bool isAll;
    bool isPending;
    bool isConfirmed;
    
    int Row;
    NSString *userId;
    NSArray *finalAppointmentListing;
    NSMutableArray *pendingAppointmentListing;
    NSMutableArray *confirmedAppointmentListing;

    NSMutableArray *searchArray;
    NSDictionary *selectedAppointment;
}

@end


@implementation ManageMeetingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    isAll = YES;
    
    idArr = [[NSArray alloc] initWithObjects:@"15243",@"54663",@"23146",@"41213",@"56243", nil];
    PassArr = [[NSArray alloc] initWithObjects:@"2395",@"4128",@"3905",@"3617",@"5961", nil];
    
    db = [Database sharedDB];
    
    [SVProgressHUD dismiss];
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, view.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
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
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    
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
    
    [view addSubview:label];
    
    [self.navigationController.navigationBar addSubview:view];
    
    
    [self.scrollTopVw setContentSize:CGSizeMake(414, self.scrollTopVw.frame.size.height)];
    
    [self getAppointments];
    
    [_txtFieldSearch resignFirstResponder];
    
    [self.refreshControl removeFromSuperview];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blackColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableViewMeetings addSubview:self.refreshControl];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [view removeFromSuperview];
}


- (void)reloadData
{
    [self getAppointments];
}


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


- (IBAction)changeRequestType:(id)sender {
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
        
        isRequest = NO;
        
        [noMeetingLabel removeFromSuperview];
        
        [self getAppointments];
        
    } else if(_segmentedControl.selectedSegmentIndex == 1) {
        
        isRequest = YES;
        
        [noMeetingLabel removeFromSuperview];
        
        [self getAppointments];
        
    }
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (isSearch) {
        
        return [searchArray count];
        
    } else {
        
        return [finalAppointmentListing count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //return cellHeight;
    
    NSDictionary *dict;
    
    if (isSearch) {
        
        if ([searchArray count]>0) {
            
            dict = [searchArray objectAtIndex:indexPath.row];
        }
        
    } else {
        
        dict = [finalAppointmentListing objectAtIndex:indexPath.row];
    }

    NSString *status = [dict objectForKey:@"status"];
    
    if([status isEqualToString:@"confirm"])
    {
        return 131;
    }
    else
    {
        return 118;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ManageMeetingsTableViewCell";
    
    ManageMeetingsTableViewCell *cell = (ManageMeetingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ManageMeetingsTableViewCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dict;
    
    if (isSearch) {
        
       dict = [searchArray objectAtIndex:indexPath.row];
        
    } else {
        
       dict = [finalAppointmentListing objectAtIndex:indexPath.row];
    }
    
    NSDictionary *dictUserDetails = [dict objectForKey:@"userdetails"];
    
    cell.lblName.text = [dictUserDetails objectForKey:@"contact"];
    cell.lblEmail.text = [dictUserDetails objectForKey:@"email"];
    cell.lblPhone.text = [dictUserDetails objectForKey:@"phone"];
    cell.btnCall.hidden = NO;
    cell.imgPhone.hidden = NO;
    cell.btnMail_Message.hidden = NO;
    cell.imgMail_Message.hidden = NO;
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if ([userType isEqualToString:@"Guest"]) {
        
        if (isRequest) {
            
            cell.btnConfirm.hidden = NO;
        }
        else
        {
            cell.btnConfirm.hidden = YES;
        }
        
        cell.btnOpenDirections.hidden = NO;
        cell.imgDirection.hidden = NO;
        
    }
    else{
     
        if (isRequest) {
            
            cell.btnConfirm.hidden = NO;
            
        }
        else
        {
            cell.btnConfirm.hidden = YES;
        }
        
        cell.btnOpenDirections.hidden = NO;
        cell.imgDirection.hidden = NO;
        
    }
    
    NSString *status = [dict objectForKey:@"status"];
    
    if([status isEqualToString:@"pending"]){
        
        cell.statusImage.image = [UIImage imageNamed:@"pending.png"];
        cell.lblOTP.hidden = YES;
        cell.btnCancel.hidden = NO;
        cell.lblCancelled.hidden = YES;
        cell.lblConfirmed.hidden = YES;
        cell.communicationOptions.hidden = NO;
        cell.btnMail_Message.hidden = YES;
        cell.imgMail_Message.hidden = YES;
        
        cell.btnOpenDirections.hidden = YES;
        cell.imgDirection.hidden = YES;

    }else if([status isEqualToString:@"confirm"]){
        
        NSInteger randomIndex = arc4random()%[idArr count];
        NSString *IDstr = [idArr objectAtIndex:randomIndex];
        
        NSInteger randomIndex2 = arc4random()%[PassArr count];
        NSString *PassStr = [PassArr objectAtIndex:randomIndex2];
        
        cell.statusImage.image = [UIImage imageNamed:@"confirm.png"];
        cell.lblOTP.hidden = NO;
        cell.lblOTP.numberOfLines = 2;
        cell.lblOTP.lineBreakMode = NSLineBreakByWordWrapping;
        cell.lblOTP.text = [NSString stringWithFormat:@"Door id:%@\nDoor Pin:%@",IDstr,PassStr];
        cell.btnCancel.hidden = NO;
        cell.btnConfirm.hidden = YES;
        cell.lblCancelled.hidden = YES;
        cell.lblConfirmed.hidden = NO;
        cell.communicationOptions.hidden = NO;
        cell.btnMail_Message.hidden = YES;
        cell.imgMail_Message.hidden = YES;
        
        cell.btnOpenDirections.hidden = NO;
        cell.imgDirection.hidden = NO;

    }else if([status isEqualToString:@"cancel"]){
        
        cell.statusImage.image = [UIImage imageNamed:@"cancelMeeting"];
        cell.lblOTP.hidden = YES;
        cell.btnCancel.hidden = YES;
        cell.btnConfirm.hidden = YES;
        cell.lblCancelled.hidden = NO;
        cell.lblConfirmed.hidden = YES;
        cell.communicationOptions.hidden = NO;
        cell.btnCall.hidden = YES;
        cell.btnMail_Message.hidden = YES;
        cell.btnOpenDirections.hidden = YES;
        cell.imgDirection.hidden = YES;
        cell.imgPhone.hidden = YES;
        cell.imgMail_Message.hidden = YES;
        
        cell.btnOpenDirections.hidden = YES;
        cell.imgDirection.hidden = YES;
    }
    else if([status isEqualToString:@"end"]){
        
        cell.statusImage.image = [UIImage imageNamed:@"endMeeting"];
        cell.lblOTP.hidden = YES;
        cell.btnCancel.hidden = YES;
        cell.btnConfirm.hidden = YES;
        cell.lblCancelled.hidden = NO;
        [cell.lblCancelled setText:@"Ended"];
        cell.lblConfirmed.hidden = YES;
        cell.communicationOptions.hidden = NO;
        cell.btnCall.hidden = YES;
        cell.btnMail_Message.hidden = YES;
        cell.btnOpenDirections.hidden = YES;
        cell.imgDirection.hidden = YES;
        cell.imgPhone.hidden = YES;
        cell.imgMail_Message.hidden = YES;
        
        cell.btnOpenDirections.hidden = YES;
        cell.imgDirection.hidden = YES;
    }
    
    NSString *Date = [dict objectForKey:@"fdate"];
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

    cell.lblDay.text = day;
    cell.lblMonthYear.text = [NSString stringWithFormat:@"%@ %@",month,year];
    
    cell.lblTime.text = [NSString stringWithFormat:@"Timing: %@ - %@",[dict objectForKey:@"fromtime"],[dict objectForKey:@"totime"]];

    cell.btnCalender.tag = indexPath.row;
    [cell.btnCalender addTarget:self action:@selector(syncWithCalendar:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnCall.tag = indexPath.row;
    [cell.btnCall addTarget:self action:@selector(btnCallDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnCancel.tag = indexPath.row;
    [cell.btnCancel addTarget:self action:@selector(btnCancelDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnConfirm.tag = indexPath.row;
    [cell.btnConfirm addTarget:self action:@selector(btnConfirmDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnOpenDirections.tag = indexPath.row;
    [cell.btnOpenDirections addTarget:self action:@selector(btnOpenDirectionsDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnMail_Message.tag = indexPath.row;
    [cell.btnMail_Message addTarget:self action:@selector(btnMail_MessageDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnStatus.tag = indexPath.row;
    [cell.btnStatus addTarget:self action:@selector(btnStatusDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
    
    // If you are not using ARC:
    // return [[UIView new] autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict;
    
    if (isSearch) {
        
        dict = [searchArray objectAtIndex:indexPath.row];
        
    } else {
        
        dict = [finalAppointmentListing objectAtIndex:indexPath.row];
    }
    
    selectedAppointment = dict;
    //[self setMessageRead:[dict objectForKey:@"id"]];
    [self performSegueWithIdentifier:@"segueToManageMeetingsDetails" sender:self];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(CGRect)getNewFrame:(CGRect)originalFrame withHelpFrame:(CGRect)helpFrame
{
    CGRect frame = originalFrame;
    
    frame.origin = CGPointMake(originalFrame.origin.x, (2+helpFrame.origin.y+helpFrame.size.height));
    
    originalFrame = frame;
    
    return frame;
}


-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text{
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    return ceil(rect.size.height);
}


-(IBAction)btnOpenDirectionsDidTap:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"BeaconFlow" bundle:[NSBundle mainBundle]];
    
    IndoorMapViewController *indoorMap = [storyboard instantiateViewControllerWithIdentifier:@"IndoorMapViewController"];
    
    //NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
    //locationForMap = [dict objectForKey:@"venue"];
    
    //indoorMap.locationName = locationForMap;
    
    [self.navigationController pushViewController:indoorMap animated:YES];
}


-(IBAction)btnConfirmDidTap:(UIButton *)sender
{
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
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


-(void)roomSelect:(UIButton *)sender
{
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
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
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
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
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
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

-(void)btnCallDidTap:(UIButton *)sender{
    
    NSLog(@"sender.tag :%ld",sender.tag);
    
    NSDictionary *dict = [appointmentsArray objectAtIndex:sender.tag];
    
    NSDictionary *dictUserDetails = [dict objectForKey:@"userdetails"];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",[dictUserDetails objectForKey:@"phone"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        [[UIApplication sharedApplication] openURL:phoneUrl];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void)btnMail_MessageDidTap:(UIButton *)sender{
    
    NSLog(@"sender.tag :%ld",sender.tag);
    
    NSDictionary *dict = [appointmentsArray objectAtIndex:sender.tag];
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController * emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;
        
//        [emailController setSubject:subject];
//        [emailController setMessageBody:mailBody isHTML:YES];
        NSArray *recipients = @[[dict objectForKey:@"employee_email"]];
        [emailController setToRecipients:recipients];
        
        [self presentViewController:emailController animated:YES completion:nil];
        
    }
    // Show error if no mail account is active
    else {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must have a mail account in order to send an email" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)btnCancelDidTap:(UIButton *)sender{
    
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
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

- (IBAction)btnAdvancedSearchDidTap:(id)sender {
    
    
}

-(void)btnStatusDidTap:(UIButton *)sender{
    
    Row = (int)sender.tag;
    
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:Row];
    
    selectedAppointment = dict;
    
    [self performSegueWithIdentifier:@"segueToManageMeetingsDetails" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getAppointments{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url;
    
    if (isRequest) {
        
        host_url = [NSString stringWithFormat:@"%@all_request_appointments.php",BASE_URL];
        
    } else {
        
        host_url = [NSString stringWithFormat:@"%@all_appointments.php",BASE_URL];
    }
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        appointmentsArray = [[NSMutableArray alloc]init];
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            finalAppointmentListing = [[NSArray alloc] init];
            
            appointmentsArray = [responseDict objectForKey:@"apointments"];
            
            NSLog(@"appointmentsArray :%@",appointmentsArray);
                
            if ([appointmentsArray count]>0) {
                
                if(isAll){
                    
                    [_btnAllOutlet setTitleColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
                    _btnPendingOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                    _btnConfirmedMeetingsOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                    
                    finalAppointmentListing = appointmentsArray;
                    
                }else if(isPending){
                    
                    _btnAllOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                    _btnPendingOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                    [_btnConfirmedMeetingsOutlet setTitleColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
                    // _btnConfirmedMeetingsOutlet.titleLabel.textColor = [UIColor blueColor];
                    
                    pendingAppointmentListing = [[NSMutableArray alloc]init];
                    for (NSDictionary *dict in appointmentsArray) {
                        NSString *status = [dict objectForKey:@"status"];
                        if([status isEqualToString:@"pending"]){
                            [pendingAppointmentListing addObject:dict];
                        }
                    }
                    
                    finalAppointmentListing = pendingAppointmentListing;
                    
                }else if (isConfirmed){
                    
                    _btnAllOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                    _btnPendingOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
                    [_btnConfirmedMeetingsOutlet setTitleColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
                    // _btnConfirmedMeetingsOutlet.titleLabel.textColor = [UIColor blueColor];
                    
                    confirmedAppointmentListing = [[NSMutableArray alloc]init];
                    
                    for (NSDictionary *dict in appointmentsArray) {
                        
                        NSString *readStatus = [dict objectForKey:@"status"];
                        
                        if([readStatus isEqualToString:@"pending"]){
                            
                            NSLog(@"Not confirmed");
                            
                        }else{
                            
                            [confirmedAppointmentListing addObject:dict];
                            
                        }
                    }
                    
                    finalAppointmentListing = confirmedAppointmentListing;
                    
                }
                
                [_tableViewMeetings reloadData];
                
                [self.refreshControl endRefreshing];
                
            } else {
                
                [_tableViewMeetings reloadData];
                
                [self.refreshControl endRefreshing];
                
                [noMeetingLabel removeFromSuperview];
                
                noMeetingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.tableViewMeetings.frame.origin.y - 30), SCREENWIDTH, self.tableViewMeetings.frame.size.height/2)];
                
                noMeetingLabel.text = @"No meetings found";
                noMeetingLabel.font = [UIFont systemFontOfSize:26];
                noMeetingLabel.numberOfLines = 4;
                noMeetingLabel.baselineAdjustment = YES;
                noMeetingLabel.clipsToBounds = YES;
                noMeetingLabel.backgroundColor = [UIColor clearColor];
                noMeetingLabel.textColor = [UIColor whiteColor];
                noMeetingLabel.textAlignment = NSTextAlignmentCenter;
                
                [self.tableViewMeetings addSubview:noMeetingLabel];
            }
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No appointments found."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            finalAppointmentListing = [[NSArray alloc] init];
            
            [_tableViewMeetings reloadData];
            
            [SVProgressHUD dismiss];
            
            [self.refreshControl endRefreshing];
            
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"segueToManageMeetingsDetails"]){
        
        ManageMeetingsDetailsViewController *meetingDetails = segue.destinationViewController;
        
        meetingDetails.isRequest = isRequest;
        
        meetingDetails.meetingDetailsDictionary = selectedAppointment;
    }
}


-(IBAction)syncWithCalendar:(UIButton *)sender {
    
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
    NSDictionary *dictDetails = [dict objectForKey:@"userdetails"];
        
    NSString *status = [dict objectForKey:@"status"];
    
    NSString *getdate = [dict objectForKey:@"fdate"];
    NSArray *split = [getdate componentsSeparatedByString:@"-"];
    NSLog(@"split :%@",split);
    
    NSString *day = [split objectAtIndex:2];
    NSLog(@"day :%@",day);
    
    NSUInteger characterCount = [day length];
    
    if (characterCount == 1) {
        
        day = [NSString stringWithFormat:@"0%@",day];
    }
    
    NSString *month = [split objectAtIndex:1];
    NSLog(@"month :%@",month);
    
    NSString *year = [split objectAtIndex:0];
    NSLog(@"year :%@",year);
    
    NSString *dateTimestr = [NSString stringWithFormat:@"%@-%@-%@ %@",day, month, year,[dict objectForKey:@"time"]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm a"];
    
    NSDate *calenderDate = [dateFormatter dateFromString:dateTimestr];
    
    NSDate *minusthirtyMin = [calenderDate dateByAddingTimeInterval:-30*60];
    
    if ([status isEqualToString:@"confirm"]) {
        
        [SVProgressHUD show];
        
        EKEventStore *store = [EKEventStore new];
        
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            if (granted)
            {
                NSString *appointmentID = [dict objectForKey:@"id"];
                
                NSMutableArray *arrMeeting = [db getMeetingsById:appointmentID];
                
                if ([arrMeeting count]>0) {
                    
                    savedEventId = [NSString stringWithFormat:@"%@",[[arrMeeting objectAtIndex:0] objectForKey:@"appointmentId"]];
                    
                    if ([savedEventId length]>0) {
                        
                        EKEvent *event = [store eventWithIdentifier:savedEventId];
                        
                        if (event) {
                            
                            event.title = [NSString stringWithFormat:@"You have seduled an appointement with %@ today.",[dictDetails objectForKey:@"contact"]];
                            
                            event.startDate = minusthirtyMin;
                            
                            event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
                            
                            event.calendar = [store defaultCalendarForNewEvents];
                            
                            NSError *err = nil;
                            
                            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                            
                            [db UpdateMeetingTableWithAppointmentId:[dict objectForKey:@"id"] andEventId:savedEventId];
                        }
                        
                    } else {
                        
                        EKEvent *event = [EKEvent eventWithEventStore:store];
                        
                        event.title = [NSString stringWithFormat:@"You have seduled an appointement with %@ today.",[dictDetails objectForKey:@"contact"]];
                        
                        event.startDate = minusthirtyMin;
                        
                        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
                        
                        event.calendar = [store defaultCalendarForNewEvents];
                        
                        NSError *err = nil;
                        
                        savedEventId = event.eventIdentifier;
                        
                        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                        
                        [db UpdateMeetingTableWithAppointmentId:[dict objectForKey:@"id"] andEventId:savedEventId];
                    }
                    
                } else {
                    
                    EKEvent *event = [EKEvent eventWithEventStore:store];
                    
                    event.title = [NSString stringWithFormat:@"You have seduled an appointement with %@ today.",[dictDetails objectForKey:@"contact"]];
                    
                    event.startDate = minusthirtyMin;
                    
                    event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
                    
                    event.calendar = [store defaultCalendarForNewEvents];
                    
                    NSError *err = nil;
                    
                    savedEventId = event.eventIdentifier;
                    
                    [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                    
                    [db UpdateMeetingTableWithAppointmentId:[dict objectForKey:@"id"] andEventId:savedEventId];
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    [SVProgressHUD dismiss];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Meeting saved to calendar successfully."
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                        
                        [alertView show];
                        
                    });
                    
                });
                
            }
            else
            {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User has not granted permission for saving in calender."
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                
                [alertView show];
                
            }
            
        }];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This appointment is not confirmed."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    
}


- (IBAction)btnAllDidTap:(id)sender {
    
    isAll = YES;
    isPending = NO;
    isConfirmed = NO;
    
    //_btnAllOutlet.titleLabel.textColor = [UIColor blueColor];
    [_btnAllOutlet setTitleColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
    _btnPendingOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    _btnConfirmedMeetingsOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    finalAppointmentListing = appointmentsArray;
    
    if ([finalAppointmentListing count]==0) {
        
        [noMeetingLabel removeFromSuperview];
        
        noMeetingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.tableViewMeetings.frame.origin.y - 30), SCREENWIDTH, self.tableViewMeetings.frame.size.height/2)];
        
        noMeetingLabel.text = @"No meetings found";
        noMeetingLabel.font = [UIFont systemFontOfSize:26];
        noMeetingLabel.numberOfLines = 4;
        noMeetingLabel.baselineAdjustment = YES;
        noMeetingLabel.clipsToBounds = YES;
        noMeetingLabel.backgroundColor = [UIColor clearColor];
        noMeetingLabel.textColor = [UIColor whiteColor];
        noMeetingLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.tableViewMeetings addSubview:noMeetingLabel];
    }
    else
    {
        [noMeetingLabel removeFromSuperview];
    }
    
    [_tableViewMeetings reloadData];
}


- (IBAction)btnPendingDidTap:(id)sender {
    
    isAll = NO;
    isPending = YES;
    isConfirmed = NO;
    
    _btnAllOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [_btnPendingOutlet setTitleColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
    //_btnReadOutlet.titleLabel.textColor = [UIColor blueColor];
    _btnConfirmedMeetingsOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];

    
    pendingAppointmentListing = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in appointmentsArray) {
        NSString *status = [dict objectForKey:@"status"];
        if([status isEqualToString:@"pending"]){
            [pendingAppointmentListing addObject:dict];

        }
    }
    
    finalAppointmentListing = pendingAppointmentListing;
    
    if ([finalAppointmentListing count]==0) {
        
        [noMeetingLabel removeFromSuperview];
        
        noMeetingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.tableViewMeetings.frame.origin.y - 30), SCREENWIDTH, self.tableViewMeetings.frame.size.height/2)];
        
        noMeetingLabel.text = @"No meetings found";
        noMeetingLabel.font = [UIFont systemFontOfSize:26];
        noMeetingLabel.numberOfLines = 4;
        noMeetingLabel.baselineAdjustment = YES;
        noMeetingLabel.clipsToBounds = YES;
        noMeetingLabel.backgroundColor = [UIColor clearColor];
        noMeetingLabel.textColor = [UIColor whiteColor];
        noMeetingLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.tableViewMeetings addSubview:noMeetingLabel];
    }
    else
    {
        [noMeetingLabel removeFromSuperview];
    }
    
    [_tableViewMeetings reloadData];
}


- (IBAction)btnConfirmedMeetingsDidTap:(id)sender {
    
    isAll = NO;
    isPending = NO;
    isConfirmed = YES;
    
    _btnAllOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    _btnPendingOutlet.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    [_btnConfirmedMeetingsOutlet setTitleColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] forState:UIControlStateNormal];
    
   // _btnConfirmedMeetingsOutlet.titleLabel.textColor = [UIColor blueColor];
    
    confirmedAppointmentListing = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in appointmentsArray) {
        
        NSString *status = [dict objectForKey:@"status"];
        
        if([status isEqualToString:@"confirm"]){
            
            [confirmedAppointmentListing addObject:dict];
        }
    }
    
    finalAppointmentListing = confirmedAppointmentListing;
    
    if ([finalAppointmentListing count]==0) {
        
        [noMeetingLabel removeFromSuperview];
        
        noMeetingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.tableViewMeetings.frame.origin.y - 30), SCREENWIDTH, self.tableViewMeetings.frame.size.height/2)];
        
        noMeetingLabel.text = @"No meetings found";
        noMeetingLabel.font = [UIFont systemFontOfSize:26];
        noMeetingLabel.numberOfLines = 4;
        noMeetingLabel.baselineAdjustment = YES;
        noMeetingLabel.clipsToBounds = YES;
        noMeetingLabel.backgroundColor = [UIColor clearColor];
        noMeetingLabel.textColor = [UIColor whiteColor];
        noMeetingLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.tableViewMeetings addSubview:noMeetingLabel];
    }
    else
    {
        [noMeetingLabel removeFromSuperview];
    }
    
    [_tableViewMeetings reloadData];

}


-(void)confirmAppointment:(NSString *)appointmentId withSender:(UIButton *)sender{
    
    [SVProgressHUD show];
    
    NSDictionary *params;
    
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
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
            
            if ([[responseDict allKeys] containsObject:@"message"]) {
                
                NSString *message = [responseDict objectForKey:@"message"];
                
                if ([message isEqualToString:@"This time slot already booked, please reshedule your meeting."]) {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                    
                } else {
                    
                    [self getAppointments];
                }
            }
            else
            {
                [self getAppointments];
            }
            
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
            
            [self getAppointments];
            
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

-(void)setMessageRead:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    NSDictionary *params = @{@"appid":appointmentId};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *host_url = [NSString stringWithFormat:@"%@set_read.php",BASE_URL];
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            [SVProgressHUD dismiss];
            [self getAppointments];
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

- (IBAction)searchTextFieldTextDidChange:(id)sender {
    
    if(_txtFieldSearch.text.length>0){
        
        searchArray = [[NSMutableArray alloc]init];
        
        NSPredicate *filter;
        NSString *strName;
        NSMutableArray *emp_Names = [[NSMutableArray alloc] init];
        
        for (id object in finalAppointmentListing) {
            
            NSDictionary *dict = object;
            
            NSDictionary *dictUserDetails = [dict objectForKey:@"userdetails"];
            
            strName = [dictUserDetails objectForKey:@"contact"];
            
            filter = [NSPredicate predicateWithFormat:@"self contains[cd] %@", _txtFieldSearch.text];
            
            [emp_Names addObject:strName];
            
        }
        
        //NSLog(@"filter :%@",filter);
        
        NSArray *filteredArray = [emp_Names filteredArrayUsingPredicate:filter];
        
        for (NSDictionary *dict in finalAppointmentListing) {
            
            NSString *name;
            
            NSDictionary *dictUserDetails = [dict objectForKey:@"userdetails"];
            
            name = [dictUserDetails objectForKey:@"contact"];
            
            for (NSString *empName in filteredArray) {
                
                if([empName isEqualToString:name]){
                    
                    [searchArray addObject:dict];
                }
            }
        }
        
        //NSLog(@"searchArray :%@",searchArray);
        
        isSearch = YES;
        
        [_tableViewMeetings reloadData];
        
    }
    else
    {
        isSearch = NO;
        
        [_tableViewMeetings reloadData];
    }
    
}

    
-(IBAction)btnCancelSearchAction:(UIButton *)sender
{
    _txtFieldSearch.text = @"";
        
    [_txtFieldSearch resignFirstResponder];
    
    isSearch = NO;
    
    [_tableViewMeetings reloadData];
}

    
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (textField.text.length==0) {
//        
//        isSearch = NO;
//        
//        [_tableViewMeetings reloadData];
//    }
    
    [textField resignFirstResponder];
    
    return YES;
}


@end
