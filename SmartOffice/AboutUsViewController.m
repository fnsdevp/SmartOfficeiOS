//
//  AboutUsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 28/03/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    
    navView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [navView addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, navView.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    // NSString *blueText = @"Schedule";
    NSString *whiteText = @"About Us";
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
    
    
    NSString *strText = @"Headquartered in Kolkata, Future Netwings has made its place among the best Network Services and Support Organizations of India. With a ISO 9001:2008 certified Quality Management System and a motto to provide Service & Support exceeding global standards, our operations are spread across India and Singapore.\n\n As a customer centric organization we maintain a huge stock of spares for quick service turnaround. Additionally, when the industry mostly relies on outsourced resources to carry out the services requiring specialized equipments, the availability of such critical resources inhouse has always been an unique advantage with us. No wonder the prestigious clientele we retain with conceit refer us willingly as their favored solutions partner.\n\n Our diverse projects include extensive WAN infrastructures, Datacenter Setup, Indoor & Outdoor Secure WiMax & Wi-Fi, Video Conferencing, IP Telephony, Campus LANs, Intra City Fiber Optic Connectivity as well as Advanced Server and Desktop Level OS and Application Configuration. Behind every project our objective has been International Quality and Standards Adherence.";
    
    [_aboutUsVw setText:strText];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [navView removeFromSuperview];
}

- (IBAction)btnDrawerMenuDidTap:(id)sender {
   
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
    
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
