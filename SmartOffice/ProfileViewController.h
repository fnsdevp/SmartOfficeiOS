//
//  ProfileViewController.h
//  SmartOffice
//
//  Created by FNSPL on 09/05/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "SystemServices.h"
#import "ChangePasswordViewController.h"

#define SystemSharedServices [SystemServices sharedServices]

@interface ProfileViewController : UIViewController<UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,ChangePasswordViewControllerDelegate>
{
    UIView *navView;
    NSString *userId;
    NSString *title;
    NSString *host_url;
    
    ChangePasswordViewController *newPassVC;
}

@property (weak, nonatomic) IBOutlet UIImageView *profPicImg;
@property (weak, nonatomic) IBOutlet UIImageView *imgRing;

@property (weak, nonatomic) IBOutlet UIScrollView *innerScrollVw;
@property (weak, nonatomic) IBOutlet UIButton *profPicBtn;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateDeviceInfoBtn;
    
@property (weak, nonatomic) IBOutlet UIView *dateNotifVw;
    
@property (nonatomic, strong) IBOutlet UISwitch *dateNotifSwitch;

@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGesture;

@property (weak, nonatomic) IBOutlet UILabel *userTypelbl;
@property (weak, nonatomic) IBOutlet UILabel *fnamelbl;
@property (weak, nonatomic) IBOutlet UILabel *lnamelbl;
@property (weak, nonatomic) IBOutlet UILabel *departmentlbl;
@property (weak, nonatomic) IBOutlet UILabel *designationlbl;
@property (weak, nonatomic) IBOutlet UILabel *companylbl;
@property (weak, nonatomic) IBOutlet UILabel *phonelbl;
@property (weak, nonatomic) IBOutlet UILabel *emaillbl;

@end
