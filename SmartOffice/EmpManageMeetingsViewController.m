//
//  EmpManageMeetingsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "EmpManageMeetingsViewController.h"
#import "EmployeeManageMeetingsTableViewCell.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Constants.h"
#import <MessageUI/MessageUI.h>
#import "EmployeeMeetingsDetailsViewController.h"
@interface EmpManageMeetingsViewController (){
    UIView *view;
    NSArray *appointmentsArray;
    bool isAll;
    bool isPending;
    bool isConfirmed;
    
    int Row;
    
    NSArray *venues;
    
    NSArray *finalAppointmentListing;
    NSMutableArray *pendingAppointmentListing;
    NSMutableArray *confirmedAppointmentListing;
    
    NSMutableArray *searchArray;
    NSDictionary *selectedAppointment;

}

@end

@implementation EmpManageMeetingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isAll = YES;
    
    self.tableViewMeetings.delegate = self;
    self.tableViewMeetings.dataSource = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    venues = @[@"Conference Room",@"Director's Room"];
    
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
    [self getAppointments];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [view removeFromSuperview];
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


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [finalAppointmentListing count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 101;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"EmployeeManageMeetingsTableViewCell";
    
    EmployeeManageMeetingsTableViewCell *cell = (EmployeeManageMeetingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EmployeeManageMeetingsTableViewCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:indexPath.row];
    cell.lblName.text = [[dict objectForKey:@"guest"] objectForKey:@"contact"];
    cell.lblEmail.text = [dict objectForKey:@"employee_email"];
    cell.lblPhone.text = [dict objectForKey:@"employee_phone"];
    
    //  cell.lblEmail.text = [dict objectForKey:@"employee_email"];
    
    NSString *status = [dict objectForKey:@"status"];
    
    if([status isEqualToString:@"pending"]){
        cell.statusImage.image = [UIImage imageNamed:@"pending.png"];
        cell.btnCancel.hidden = NO;
        cell.lblCancelled.hidden = YES;
        cell.confirm_cancel_View.hidden = YES;
        cell.pendingView.hidden = NO;

    }else if([status isEqualToString:@"confirm"]){
        cell.statusImage.image = [UIImage imageNamed:@"confirm.png"];
        cell.btnCancel.hidden = NO;
        cell.lblCancelled.hidden = YES;
        cell.confirm_cancel_View.hidden = NO;
        cell.pendingView.hidden = YES;
        
    }else if([status isEqualToString:@"cancel"]){
        cell.statusImage.image = [UIImage imageNamed:@"pending.png"];
        cell.btnCancel.hidden = YES;
        cell.lblCancelled.hidden = NO;
        cell.confirm_cancel_View.hidden = YES;
        cell.pendingView.hidden = YES;

    }
    
    //    cell.nameLabel.text = [tableData objectAtIndex:indexPath.row];
    //    cell.thumbnailImageView.image = [UIImage imageNamed:[thumbnails objectAtIndex:indexPath.row]];
    //    cell.prepTimeLabel.text = [prepTime objectAtIndex:indexPath.row];
    
    NSString *date = [dict objectForKey:@"fdate"];
    NSArray *split = [date componentsSeparatedByString:@"-"];
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
    
    cell.btnCall.tag = indexPath.row;
    [cell.btnCall addTarget:self action:@selector(btnCallDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnCancel.tag = indexPath.row;
    [cell.btnCancel addTarget:self action:@selector(btnCancelDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.btnConfirmDidTap.tag = indexPath.row;
    [cell.btnConfirmDidTap addTarget:self action:@selector(btnConfirmedMeetings:) forControlEvents:UIControlEventTouchUpInside];
    
//    cell.btnOpenDirections.tag = indexPath.row;
//    [cell.btnOpenDirections addTarget:self action:@selector(btnOpenDirectionsDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
//    NSDictionary *dict = [finalAppointmentListing objectAtIndex:indexPath.row];
//    selectedAppointment = dict;
    //[self setMessageRead:[dict objectForKey:@"id"]];
   // [self performSegueWithIdentifier:@"segueToManageMeetingsDetails" sender:self];
    
}
-(void)btnCallDidTap:(UIButton *)sender{
    NSLog(@"sender.tag :%ld",sender.tag);
    NSDictionary *dict = [appointmentsArray objectAtIndex:sender.tag];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel:%@",[dict objectForKey:@"employee_phone"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)btnConfirmedMeetings:(UIButton *)sender{
    
    NSDictionary *dict = [finalAppointmentListing objectAtIndex:sender.tag];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Info"
                                  message:@"Do you want to confirm this appointment?"
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


-(void)btnOpenDirectionsDidTap:(UIButton *)sender{
    
    
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
                             [self confirmAppointment:[dict objectForKey:@"id"]];
                             
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
    
    NSString *userID = [NSString stringWithFormat:@"%d",(int)[[Userdefaults objectForKey:@"ProfInfo"] objectForKey:@"id"]];
    
    NSDictionary *params = @{@"userid":userID};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *host_url = [NSString stringWithFormat:@"%@all_appointments.php",BASE_URL];
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            [SVProgressHUD dismiss];
            appointmentsArray = [responseDict objectForKey:@"apointments"];
            NSLog(@"appointmentsArray :%@",appointmentsArray);
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"segueToManageMeetingsDetails"]){
        
        EmployeeMeetingsDetailsViewController *meetingDetails = segue.destinationViewController;
        
        meetingDetails.meetingDetailsDictionary = selectedAppointment;
        
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
    [_tableViewMeetings reloadData];
    
    
}

-(void)cancelAppointment:(NSString *)appointmentId{
    [SVProgressHUD show];
    NSDictionary *params = @{@"appid":appointmentId,@"status":@"cancel"};
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

-(void)confirmAppointment:(NSString *)appointmentId{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"appid":appointmentId,@"status":@"confirm",@"location":@""};
    
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
    
    if(_txtFieldSearch.text.length>2){
        searchArray = [[NSMutableArray alloc]init];
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", _txtFieldSearch.text];
        
        NSArray *emp_Names = [finalAppointmentListing valueForKey:@"employee_name"];
        
        NSArray *filteredArray = [[emp_Names filteredArrayUsingPredicate:filter] mutableCopy];
        for (NSDictionary *dict in finalAppointmentListing) {
            NSString *name = [dict objectForKey:@"employee_name"];
            for (NSString *empName in filteredArray) {
                if([empName isEqualToString:name]){
                    [searchArray addObject:dict];
                }
            }
        }
        NSLog(@"searchArray :%@",searchArray);
    }
    
    //  NSArray *emp_Names = [finalAppointmentListing valueForKey:@"employee_name"];
    
    //    if (!_txtFieldSearch.text || _txtFieldSearch.text.length == 0) {
    //
    //        // searchArray = [_contactArray mutableCopy];
    //        _contactTableView.hidden = YES;
    //
    //        // self.txt_ContactName.text=@"";
    //        self.lbl_managerName.text=@"Manager Name";
    //        self.lbl_PhoneNo.text=@"Phone no";
    //        self.lbl_managerEmail.text=@"Manager Email";
    //        self.lbl_APEmail.text=@"APEmail";
    //        self.lbl_ManagerCoInfo.text=@"ManagerCoInfo";
    //        self.lbl_Codes.text=@"Codes";
    //
    //        self.lbl_PhoneNo.font = [UIFont boldSystemFontOfSize:16];
    //        self.lbl_managerEmail.font = [UIFont boldSystemFontOfSize:16];
    //
    //        _btnPhone.userInteractionEnabled = YES;
    //        _btnEmail.userInteractionEnabled = YES;
    //
    //
    //    } else if(searchArray.count == 0) {
    //        NSLog(@"No data From Search");
    //        _contactTableView.hidden = YES;
    //        //self.txt_ContactName.text=@"";
    //        self.lbl_managerName.text=@"Manager Name";
    //        self.lbl_PhoneNo.text=@"Phone Number";
    //        self.lbl_managerEmail.text=@"Manager Email";
    //        //self.lbl_APEmail.text=@"APEmail";
    //        self.lbl_ManagerCoInfo.text=@"Manager Company Info";
    //        self.lbl_Codes.text=@"Notes";
    //        _btnPhone.userInteractionEnabled = NO;
    //        _btnEmail.userInteractionEnabled = NO;
    //        
    //        
    //    }
    // }
    //    if(searchArray.count>0){
    //        _contactTableView.hidden = NO;
    //        
    //    }
    //    
    //    [_contactTableView reloadData];
    //    
    
}

@end
