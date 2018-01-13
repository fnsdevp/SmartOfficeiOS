//
//  IndoorMapViewController.h
//  SmartOffice
//
//  Created by FNSPL on 30/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//


#import "HomeViewController.h"
#import "SystemServices.h"
#import "PanelViewController.h"
#import "NavigineSDK.h"
#import "popView.h"

#define SystemSharedServices [SystemServices sharedServices]

#define kColorFromHex(color)[UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0]

@class PHBridgeSelectionViewController;
@class PanelViewController;

@interface IndoorMapViewController : ViewController<CLLocationManagerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate, PHBridgeSelectionViewControllerDelegate, PHBridgePushLinkViewControllerDelegate,CAAnimationDelegate,NavigineCoreDelegate,NCBluetoothStateDelegate,popViewDelegate,CBCentralManagerDelegate>
{
    NCSublocation *sub;
    
    NCBeacon *beaconM;
    NCBeacon *beacon1;
    NCBeacon *beacon2;
    
    NSTimer *beconTimer;
    
    NSString *localIP;
    
    int startIndex;
    
    NSString *host_url;
    
    CLBeacon *foundBeacon;
    NSString *uuid;
    
    NSMutableArray *arrayName;
    
    NSMutableArray *arrBeconUUID;
    
    popView *pop;
    
    BOOL isON;
    
    BOOL isStarted;
    
    BOOL isDown;
    
    BOOL isPathAvailable;
    
    PanelViewController *panelVC;
    NSTimer *timerforApi;

}
@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (nonatomic, strong) UIImageView *current;
@property (nonatomic, strong) UILabel *distancelbl;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSArray *zoneArray;
@property (nonatomic, strong) NSString* currentZoneName;

- (IBAction)startNavigation:(id)sender;
- (IBAction)stopNavigation:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnStartNavigation;
@property (weak, nonatomic) IBOutlet UIButton *btnStopNavigation;

@property (weak, nonatomic) IBOutlet UIImageView *locationMarker;
@property (weak, nonatomic) IBOutlet UIImageView *floorMap;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *LocationManager;

@property (nonatomic, strong) NSDictionary *bridgesFound;


@property CMMotionManager *motionManager;
//@property (strong, nonatomic) CLBeaconRegion *receptionBeaconRegion1;
@property (weak, nonatomic) IBOutlet UIImageView *beaconDevBay;
@property (weak, nonatomic) IBOutlet UIImageView *beaconReception;
@property (weak, nonatomic) IBOutlet UIImageView *corridorEntryBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *devBayEntranceBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *devBayCorrMidBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *beaconRec2;
@property (weak, nonatomic) IBOutlet UIImageView *devBay2ndRowBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *devBay3rdRowBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *devBayExitBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *directorRoomBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *directorRoomEntranceBeacon;
@property (weak, nonatomic) IBOutlet UILabel *lblBeaconUUID;
@property (weak, nonatomic) IBOutlet UIImageView *conferenceEntranceBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *conferenceBeacon;
@property (weak, nonatomic) IBOutlet UILabel *lblMajorMinor;
@property (weak, nonatomic) IBOutlet UILabel *lblRSSI;
- (IBAction)btnOpenDoorDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblViewDestinations;
@property (weak, nonatomic) IBOutlet UIView *destinationsView;
@property (weak, nonatomic) IBOutlet UISwitch *btnOperateLight;
    
@property (weak, nonatomic) IBOutlet UIView *ctrlPanelVw;


- (IBAction)btnOperateLightDidTap:(id)sender;

- (IBAction)selectOtherBridge:(id)sender;

- (void)searchForBridgeLocal;

@end
