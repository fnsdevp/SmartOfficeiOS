//
//  CustomNavController.m
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "CustomNavController.h"

@interface CustomNavController (){
    UIView *view;
}

@end

@implementation CustomNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, self.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, view.frame.size.width-imgView.frame.size.width, self.navigationBar.frame.size.height)];
    NSString *blueText = @"E";
    NSString *whiteText = @"ZAAP";
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
    
    [self.navigationBar addSubview:view];
}

-(void)viewWillDisappear:(BOOL)animated{
    [view removeFromSuperview];
}
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"ViewControllerLoaded %@:",self.navigationController.visibleViewController);

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
