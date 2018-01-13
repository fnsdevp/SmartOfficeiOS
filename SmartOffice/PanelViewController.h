//
//  PanelViewController.h
//  SmartOffice
//
//  Created by FNSPL on 09/06/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "IndoorMapViewController.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>
#import "PHLoadingViewController.h"
#import "DTColorPickerImageView.h"
#import "SVProgressHUD.h"
#import "ViewController.h"

@class ViewController;

@interface PanelViewController : ViewController<PHBridgeSelectionViewControllerDelegate, PHBridgePushLinkViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate,DTColorPickerImageViewDelegate>
{
    UIColor *_color;
    
    int brightness;
}

@property (weak, nonatomic) IBOutlet UIView *colorPreviewView;
@property (nonatomic, strong) IBOutlet UIView *backVw;
@property (nonatomic, strong) IBOutlet UIView *panelVw;

@property (nonatomic, strong) IBOutlet UISwitch *lightSwitch;

@property (nonatomic, weak) IBOutlet UISlider *hueSlider;

@property (nonatomic, strong) PHLoadingViewController *loadingView;

@property (nonatomic, strong) UIAlertView *noConnectionAlert;
@property (nonatomic, strong) UIAlertView *noBridgeFoundAlert;
@property (nonatomic, strong) UIAlertView *authenticationFailedAlert;

/**
 Starts the local heartbeat
 */
- (void)enableLocalHeartbeat;

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat;

/**
 Starts a search for a bridge
 */
- (void)searchForBridgeLocal;

@end
