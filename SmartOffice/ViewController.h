//
//  ViewController.h
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//


#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController : UIViewController<CLLocationManagerDelegate,PHBridgeSelectionViewControllerDelegate, PHBridgePushLinkViewControllerDelegate,UIScrollViewDelegate>
{
    PHLightState *lightState;
    
    NSString *strAddress;
    BOOL isLocalFire;
    
    BOOL addressFetch;
    
    NSString *distance;
    NSString *duration;
    
    NSDictionary *userinfo;
    NSString *UserId;
    NSArray *meetingsArr;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) CLLocation *cLoc;

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

- (void)findNewBridgeButtonAction;

@end

