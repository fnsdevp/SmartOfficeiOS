//
//  SplashViewController.m
//  SmartOffice
//
//  Created by FNSPL on 11/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "SplashViewController.h"
#import "LNBRippleEffect.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "EmpHomeViewController.h"

@interface SplashViewController (){
    CATransition *animation;
    LoginViewController *login;
    HomeViewController *home;
    EmpHomeViewController *empHome;

    NSString *isLoggedIn;
}

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(void)viewDidAppear:(BOOL)animated{
    LNBRippleEffect *rippleEffect = [[LNBRippleEffect alloc]initWithImage:[UIImage imageNamed:@""] Frame:CGRectMake(_imgViewLogo.frame.origin.x, _imgViewLogo.frame.origin.y, _imgViewLogo.frame.size.width, _imgViewLogo.frame.size.height) Color:[UIColor colorWithRed:(28.0/255.0) green:(212.0/255.0) blue:(255.0/255.0) alpha:1] Target:@selector(buttonTapped:) ID:self];
    rippleEffect.layer.borderColor = [[UIColor clearColor] CGColor];
    [rippleEffect setRippleColor:[UIColor colorWithRed:(28.0/255.0) green:(212.0/255.0) blue:(255.0/255.0) alpha:1]];
    [rippleEffect setRippleTrailColor:[UIColor clearColor]];
    [self.view addSubview:rippleEffect];
    
    [self performSelector:@selector(loadMainStoryboard) withObject:self afterDelay:5.0f];
}

-(void)buttonTapped:(UIButton *)sender{
    NSLog(@"Button Clicked");
}

-(void)loadMainStoryboard{
    
    isLoggedIn = [Userdefaults objectForKey:@"isLoggedIn"];
    
    if([isLoggedIn isEqualToString:@"YES"]){
        
        //NSString *userType = [Userdefaults objectForKey:@"userType"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        home = [storyboard instantiateInitialViewController];
        
        [self.navigationController pushViewController:home animated:YES];

        
//        if ([userType isEqualToString:@"Guest"]) {
//            
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//            home = [storyboard instantiateInitialViewController];
//            [self.navigationController pushViewController:home animated:YES];
//            
//        }else{
//            
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EmployeeStoryboard" bundle:[NSBundle mainBundle]];
//            empHome = [storyboard instantiateInitialViewController];
//            [self.navigationController pushViewController:empHome animated:YES];
//        }
    
    }else{
    
       UIStoryboard *storyboard1 = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:[NSBundle mainBundle]];
        
       login = [storyboard1 instantiateViewControllerWithIdentifier:@"loginPage"];
        
       [self.navigationController pushViewController:login animated:YES];
        
   }
    
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
