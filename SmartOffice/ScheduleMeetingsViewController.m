//
//  ScheduleMeetingsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ScheduleMeetingsViewController.h"
#import "CustomNavController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "FlexibleMeetingFormViewController.h"
#import "MeetingFormViewController.h"


@interface ScheduleMeetingsViewController (){
    UIView *view;
    NSArray *departmentsArr;
}

@end

@implementation ScheduleMeetingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    CustomNavController *custNav = [[CustomNavController alloc]init];
//    custNav.

}

-(void)viewWillAppear:(BOOL)animated{
    
    [self getDepartments];
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, view.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
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
    [view addSubview:label];
    
    [self.navigationController.navigationBar addSubview:view];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
//    if([segue.identifier isEqualToString:@"segueToFlexibleMeeting"]){
//        
//        FlexibleMeetingFormViewController *flexibleMeeting = segue.destinationViewController;
//        flexibleMeeting.departmentsArr = departmentsArr;
//    }
    
//    if([segue.identifier isEqualToString:@"segueToMeetingForm"]){
//        
//        FlexibleMeetingFormViewController *flexibleMeeting = segue.destinationViewController;
//        flexibleMeeting.departmentsArr = departmentsArr;
//    }
    
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


- (IBAction)btnBookNowFlexDidTap:(id)sender {
    
   // [self performSegueWithIdentifier:@"segueToFlexibleMeeting" sender:self];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FlexibleMeetingFormViewController" bundle:[NSBundle mainBundle]];
    
    FlexibleMeetingFormViewController *flexibleMeeting = [storyboard instantiateViewControllerWithIdentifier:@"FlexibleMeetingFormViewController"];
    
    flexibleMeeting.departmentsArr = departmentsArr;
    
    [self.navigationController pushViewController:flexibleMeeting animated:YES];
    
}


- (IBAction)btnBookNowFixedDidTap:(id)sender {
    
   // [self performSegueWithIdentifier:@"segueToMeetingForm" sender:self];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MeetingFormViewController" bundle:[NSBundle mainBundle]];
    
    MeetingFormViewController *meetingForm = [storyboard instantiateViewControllerWithIdentifier:@"MeetingFormViewController"];
    
    meetingForm.departmentsArr = departmentsArr;
    
    [self.navigationController pushViewController:meetingForm animated:YES];

}


-(void)getDepartments{
    
    //if([self notEmptyChecking] == NO){return;}
    
    [SVProgressHUD show];
    
   // NSDictionary *params = @{@"userid":userID};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSString *host_url = [NSString stringWithFormat:@"%@all_departments.php",BASE_URL];
    [manager POST:host_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *responseDict = responseObject;
        NSString *success = [responseDict objectForKey:@"status"];
        if ([success isEqualToString:@"success"]) {
            [SVProgressHUD dismiss];
            departmentsArr = [responseDict objectForKey:@"departments"];
            NSLog(@"departmentsArr : %@",departmentsArr);
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

@end
