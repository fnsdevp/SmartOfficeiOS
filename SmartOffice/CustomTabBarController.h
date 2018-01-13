//
//  CustomTabBarController.h
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightSideDrawerViewController.h"
#import "CtrlViewController.h"

@class CtrlViewController;

@interface CustomTabBarController : UITabBarController
{
    RightSideDrawerViewController *drawer;
    CtrlViewController *ctrlVC;
    
    NSDictionary *userDict;
}
@property UIDynamicAnimator *animator;

@end
