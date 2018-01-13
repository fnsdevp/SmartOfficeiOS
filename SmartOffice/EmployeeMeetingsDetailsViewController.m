//
//  EmployeeMeetingsDetailsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "EmployeeMeetingsDetailsViewController.h"

@interface EmployeeMeetingsDetailsViewController (){
    UIView *navView;

}

@end

@implementation EmployeeMeetingsDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"_meetingDetailsDictionary :%@",_meetingDetailsDictionary);
}
-(void)viewWillAppear:(BOOL)animated{
    _lblAgenda.text = [_meetingDetailsDictionary objectForKey:@"agenda"];
    _lblAgenda.numberOfLines = 0;
    _lblAgenda.lineBreakMode = NSLineBreakByWordWrapping;
    [_lblAgenda sizeToFit];
    
    NSString *date = [_meetingDetailsDictionary objectForKey:@"fdate"];
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
    
    _lblDate.text = day;
    _lblMonthYear.text = [NSString stringWithFormat:@"%@ %@",month,year];
    
    
    _lblName.text = [[_meetingDetailsDictionary objectForKey:@"guest"] objectForKey:@"contact"];
    _lblEmail.text = [_meetingDetailsDictionary objectForKey:@"employee_email"];
    _lblPhoneNumber.text = [_meetingDetailsDictionary objectForKey:@"employee_phone"];
    
    _lblMeetingType.text = [NSString stringWithFormat:@"Meeting Type: %@",[_meetingDetailsDictionary objectForKey:@"appointmentType"]];
    
    //    NSString *date1 = [_meetingDetailsDictionary objectForKey:@"fdate"];
    //    NSArray *split1 = [date1 componentsSeparatedByString:@"-"];
    //    NSLog(@"split1 :%@",split1);
    //
    //    NSString *day1 = [split1 objectAtIndex:2];
    //    NSLog(@"day1 :%@",day1);
    //
    //
    //    NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
    //    [dateFormatter1 setDateFormat:@"MM"];
    //    NSDate* myDate1 = [dateFormatter1 dateFromString:[split1 objectAtIndex:1]];
    //
    //    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    //    [formatter1 setDateFormat:@"MMM"];
    //    NSString *stringFromDate1 = [formatter1 stringFromDate:myDate1];
    //
    //    NSLog(@"%@", stringFromDate1);
    //    NSString *month1 = stringFromDate1;
    //    NSLog(@"month1 :%@",month1);
    //
    //    NSString *year1 = [split objectAtIndex:0];
    //    NSLog(@"year :%@",year1);
    //
    
    
    if ([_lblMeetingType.text isEqualToString:@"flexible"]) {
        _lblMeetingDate.text = [NSString stringWithFormat:@"Meeting Date: %@ to %@",[_meetingDetailsDictionary objectForKey:@"fdate"],[_meetingDetailsDictionary objectForKey:@"sdate"]];
    }else{
        
        _lblMeetingDate.text = [NSString stringWithFormat:@"Meeting Date: %@",[_meetingDetailsDictionary objectForKey:@"fdate"]];
    }
    _lblTiming.text = [NSString stringWithFormat:@"Timing: %@",[_meetingDetailsDictionary objectForKey:@"time"]];
    
    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, _lblAgenda.frame.origin.y+_lblAgenda.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height);
    
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
    
}

-(void)viewDidAppear:(BOOL)animated{
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _bottomView.frame.origin.y+_bottomView.frame.size.height);
}
-(void)viewWillDisappear:(BOOL)animated{
    [navView removeFromSuperview];
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

- (IBAction)btnMenuDidTap:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
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
