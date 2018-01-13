//
//  AppDelegate.h
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "PHBridgeSelectionViewController.h"
#import "PHBridgePushLinkViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <HueSDK_iOS/HueSDK.h>
#import "Database.h"
#import "AFNetworking.h"
#import "Constants.h"
#import "ManageMeetingsDetailsViewController.h"
#import "CtrlViewController.h"
#import <Fabric/Fabric.h>
#import <MessageUI/MessageUI.h>
#import <Crashlytics/Crashlytics.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@class ViewController;
@class PHHueSDK;
@class ManageMeetingsDetailsViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate, UIAlertViewDelegate,PHBridgeSelectionViewControllerDelegate, PHBridgePushLinkViewControllerDelegate,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate>
{
    Database *db;
    NSDictionary *userinfo;
    NSDictionary *userDict;
    NSString *userId;
    NSArray *meetingsArr;
    ManageMeetingsDetailsViewController *manageDetails;
    
    BOOL addressFetch;
    double Dist;
    NSString *distance;
    NSString *duration;
    NSString *strAddress;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) PHHueSDK *phHueSDK;

@property (nonatomic, strong) NSDictionary *bridgesFound;

@property CLLocationManager *locationManager;
@property (weak, nonatomic) CLLocation *cLoc;


#pragma mark - HueSDK

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
