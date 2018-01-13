//
//  CustomTabBarController.m
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "CustomTabBarController.h"
#import "DynamicUIAnimation.h"
#import "MessagesViewController.h"
#import "SplashViewController.h"
#import "ProfileViewController.h"
#import "SetAvailabilityViewController.h"
#import "CtrlViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
@interface CustomTabBarController (){
    UIButton* button;
    UIButton* button2;
    bool isButtonSelected;
    MessagesViewController *inbox;
    SplashViewController *splash;

}

@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SplashScreen" bundle:[NSBundle mainBundle]];
//    splash = [storyboard instantiateViewControllerWithIdentifier:@"splash"];
////    [[APPDELEGATE window] addSubview:splash.view];
////    [[APPDELEGATE window] bringSubviewToFront:splash.view];
//    [self.navigationController.navigationBar addSubview:splash.view];
    //[self performSelector:@selector(removeSplash) withObject:self afterDelay:3.0];
    
    
    UIImage *buttonImage = [UIImage imageNamed:@"schedulemeetings.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"schedulemeetings_highlight.png"];
    UIImage *selectedImage = [UIImage imageNamed:@"schedulemeetings_selected.png"];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:0 animations:^{
        
        button.frame = CGRectMake(0.0, -10.0, buttonImage.size.width/1.35, buttonImage.size.height/1.35);
        
    }
                     completion:^(BOOL finished) {
                         
                         self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
                         
                         DynamicUIAnimation *bouncyBehavior = [[DynamicUIAnimation alloc] initWithItems:@[button]];
                         [self.animator addBehavior:bouncyBehavior];
                         
                     }];
    
    button.frame = CGRectMake(0.0, -10.0, buttonImage.size.width/1.35, buttonImage.size.height/1.35);
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(scheduleMeetingsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    
    if (heightDifference < 0)
    {
        button.center = self.tabBar.center;
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
    
    CGFloat Width = self.tabBar.frame.size.width/5.2;
    
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button2.frame = CGRectMake((self.tabBar.frame.size.width - Width), 0.0, Width, self.tabBar.frame.size.height);
    
    [button2 setBackgroundColor:[UIColor clearColor]];
    [button2 addTarget:self action:@selector(MoreTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:button2];
    
    
    if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
        
        userDict = [Userdefaults objectForKey:@"ProfInfo"];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChangeTabNotification:)
                                                 name:@"ChangeTab"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNewVCNotification:)
                                                 name:@"PushNewVC"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNewVCNotification:)
                                                 name:@"OpenControlVC"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNewVCNotification:)
                                                 name:@"PushToProfileVC"
                                               object:nil];
    
    
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if (![userType isEqualToString:@"Guest"]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivePushNewVCNotification:)
                                                     name:@"PushToSetAvailabilityVC"
                                                   object:nil];

        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePushNewVCNotification:)
                                                 name:@"PushToAboutVC"
                                               object:nil];
    
    
}


-(void)MoreTapped:(id)sender{
    
    [sender setSelected:true];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
}


-(void)removeSplash{
    
    [splash.view removeFromSuperview];
}


-(void)scheduleMeetingsTapped:(id)sender{
    
    [sender setSelected:true];
    
    [self setSelectedIndex:2];
    [self.tabBarController setSelectedIndex:2];
    
}


- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item {
    
    NSUInteger indexOfTab = [[theTabBar items] indexOfObject:item];
    NSLog(@"Tab index = %lu", (unsigned long)indexOfTab);
    
    if (indexOfTab == 0) {
        [button setSelected:false];
    }
    else if (indexOfTab == 1) {
        [button setSelected:false];
    }
    else if (indexOfTab == 3) {
        [button setSelected:false];
    }
//    else if (indexOfTab == 4) {
//        [button setSelected:false];
//    }
}


- (void) receiveChangeTabNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"ChangeTab"]){
        NSLog (@"Successfully received the ChangeTab notification!");
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        self.selectedIndex = index.intValue;
        //        self.window.rootViewController.view.frame = CGRectMake(-self.window.rootViewController.view.frame.size.width/2,self.window.rootViewController.view.frame.size.height/6 ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height/2);
        //        [UIView animateWithDuration:0.3 animations:^{
        //
        //            self.window.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        //            self.window.rootViewController.view.frame = CGRectMake(0,self.window.rootViewController.view.frame.origin.y ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height);
        //            [UIView animateWithDuration:0.1 animations:^{
        //                [drawer.view removeFromSuperview];
        //            }];
        //        }];
        
        //self.tabBar
    }
    
}


- (void) receivePushNewVCNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"PushNewVC"]){
        //        NSLog (@"Successfully received the ChangeTab notification!");
        //        NSDictionary* userInfo = notification.userInfo;
        //        NSLog(@"userInfo %@",userInfo);
        //        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        //        self.selectedIndex = index.intValue;
        //        self.window.rootViewController.view.frame = CGRectMake(-self.window.rootViewController.view.frame.size.width/2,self.window.rootViewController.view.frame.size.height/6 ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height/2);
        //        [UIView animateWithDuration:0.3 animations:^{
        //
        //            self.window.rootViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        //            self.window.rootViewController.view.frame = CGRectMake(0,self.window.rootViewController.view.frame.origin.y ,self.window.rootViewController.view.frame.size.width, self.window.rootViewController.view.frame.size.height);
        //            [UIView animateWithDuration:0.1 animations:^{
        //                [drawer.view removeFromSuperview];
        //            }];
        //        }];
        
        //self.tabBar
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Messages" bundle:[NSBundle mainBundle]];
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        //self.selectedIndex = index.intValue;
        switch (index.intValue) {
            case 4:
                if(self){
                    
                    inbox = [storyboard instantiateViewControllerWithIdentifier:@"inbox"];
                    [self.selectedViewController pushViewController:inbox animated:YES];
                }
                break;
                
            default:
                break;
        }
    }
    else if(([[notification name] isEqualToString:@"OpenControlVC"]))
    {
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        switch (index.intValue) {
            case 5:
                if(self)
                {
                    ctrlVC = [[CtrlViewController alloc] initWithNibName:@"CtrlViewController" bundle:nil];
                    
                    [self.selectedViewController pushViewController:ctrlVC animated:YES];
                }
                break;
                
            default:
                break;
        }
        
        
    }
    else if(([[notification name] isEqualToString:@"PushToProfileVC"]))
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        switch (index.intValue) {
            case 6:
                if(self)
                {
                    ProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                    [self.selectedViewController pushViewController:profileVC animated:YES];
                }
                break;
                
            default:
                break;
        }
        
        
    }
    else if(([[notification name] isEqualToString:@"PushToSetAvailabilityVC"]))
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SetAvailability" bundle:nil];
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        switch (index.intValue) {
            case 7:
                if(self)
                {
                    SetAvailabilityViewController *setAvailVC = [storyboard instantiateViewControllerWithIdentifier:@"SetAvailabilityViewController"];
                    [self.selectedViewController pushViewController:setAvailVC animated:YES];
                }
                break;
                
            default:
                break;
        }
        
        
    }
    else if(([[notification name] isEqualToString:@"PushToAboutVC"]))
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AboutUs" bundle:nil];
        NSDictionary* userInfo = notification.userInfo;
        NSLog(@"userInfo %@",userInfo);
        NSNumber* index = (NSNumber*)userInfo[@"indexClickedOnDrawer"];
        
        if (index.intValue==8) {
            
            AboutUsViewController *aboutVC = [storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
            [self.selectedViewController pushViewController:aboutVC animated:YES];
       
        } else {
            
            AboutUsViewController *aboutVC = [storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
            [self.selectedViewController pushViewController:aboutVC animated:YES];
            
        }
        
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
