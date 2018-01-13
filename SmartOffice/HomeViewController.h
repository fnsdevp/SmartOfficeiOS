//
//  HomeViewController.h
//  SmartOffice
//
//  Created by FNSPL on 04/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "IndoorMapViewController.h"
#import "CtrlViewController.h"
#import "NavigineSDK.h"
#import "Reachability.h"
#import "PantryViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@class CtrlViewController;

@interface HomeViewController :ViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CLLocationManagerDelegate,NavigineCoreDelegate>
{
    NSMutableArray *arrPointNames;
    NSMutableArray *arrPointx;
    NSMutableArray *arrPointy;
    
    UIBezierPath   *uipath;
    CAShapeLayer   *routeLayer;
    
    NSTimer *stopTimer;
//    NSTimer *timerforApi;
    NSTimer *locationApi;
    BOOL running;
    
    int secondsLeft;
    
    //BOOL isLocalFire;
    
    float total;
    
    float millisecond,second;
    
    bool isON;
    
    BOOL State;
    
    int count;
    
    CMMotionManager *motionManager;
    
    double Lastlatitude;
    double Lastlongitude;
    
    Database *db;
    
    CtrlViewController *ctrlVC;
    
    NSString *toastMsg;
    
    int unreadMsgCount;
}
@property (nonatomic) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) NSString* currentZoneName;
@property (nonatomic, strong) UIBezierPath *routhPath;
@property (nonatomic, assign) BOOL isRouting;
@property (nonatomic, assign) CGPoint targetPoint;
@property (atomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) UIScrollView *sv;
@property (nonatomic, strong) NSArray *zoneArray;
@property (weak, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UILabel *distancelbl;
@property (nonatomic, strong) UIImageView *current;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewOptions;
@property (weak, nonatomic) IBOutlet UIView *midView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewUpcoming;
    
- (IBAction)btnDrawerMenuDidTap:(id)sender;
    
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property(nonatomic, readwrite) CGAffineTransform transform;
    
@property (weak, nonatomic) IBOutlet UIView *PopupView;
@property (strong,nonatomic) IBOutlet UILabel *lblSpeeach;
    
@property (strong,nonatomic) IBOutlet UILabel *lblTimer;
    
@property (strong,nonatomic) IBOutlet UIButton *btnOpenDoor;
@property (strong,nonatomic) IBOutlet UIButton *btnClose;
@property (strong,nonatomic) IBOutlet UIButton *btnOpenMap;
    
@end
