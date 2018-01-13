//
//  IndoorMapViewController.m
//  SmartOffice
//
//  Created by FNSPL on 30/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "IndoorMapViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#define MAX_HUE 65535

@import SOMotionDetector;

@interface IndoorMapViewController (){
    CLLocation *currentLocation;
    NSString *typeOfMotion;
    CMMotionManager *motionManager;
    long lineLength;

    NSArray *beaconArray;
    NSArray *minorArray;
    NSArray *majorArray;
    
    NSArray *uIdArray;
    long indexFound;
    
    NSArray *destinationsArray;
    long poiSelected;
    int Objindex;
    
    NSString *userId;
    
    UIStoryboard *beaconFlow;
    UIBezierPath   *uipath;
    CAShapeLayer   *routeLayer;
    
    NSMutableArray *arrPointNames;
    NSMutableArray *arrPointx;
    NSMutableArray *arrPointy;
    
}

@property (nonatomic, assign) BOOL isRouting;
@property (nonatomic, strong) UIBezierPath *routhPath;
@property (nonatomic, strong) PHLoadingViewController *loadingView;
@property (nonatomic, assign) CGPoint targetPoint;

@property (nonatomic, strong) UIAlertView *noConnectionAlert;
@property (nonatomic, strong) UIAlertView *noBridgeFoundAlert;
@property (nonatomic, strong) UIAlertView *authenticationFailedAlert;


@end


@implementation IndoorMapViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    _destinationsView.hidden = YES;
    
    [lightState setHue:[NSNumber numberWithInt:MAX_HUE]];
    
    _sv.frame = self.view.frame;
    _sv.delegate = self;
    _sv.pinchGestureRecognizer.enabled = YES;
    _sv.minimumZoomScale = 1.f;
    _sv.zoomScale = 1.f;
    _sv.maximumZoomScale = 2.f;
    
    [_sv addSubview:_floorMap];
    
    [NavigineCore defaultCore].userHash = @"0F17-DAE1-4D0A-1778";
    [NavigineCore defaultCore].delegate = self;
    
    arrPointNames = [[NSMutableArray alloc] initWithObjects:@"director room",@"j p lahiri room",@"conference room",@"toilet",@"director toilet",@"e publishing",@"reception",@"entry",@"developer bay",@"developer entry",@"corridor", nil];
    
    arrPointx = [[NSMutableArray alloc] initWithObjects:@"17.73",@"17.62",@"23.79",@"21.99",@"22.01",@"21.15",@"12.88",@"8.04",@"17.44",@"17.61",@"17.50", nil];
    
    arrPointy = [[NSMutableArray alloc] initWithObjects:@"7.30",@"14.72",@"21.19",@"29.94",@"23.94",@"42.15",@"37.05",@"39.58",@"22.26",@"27.74",@"35.21", nil];
    
    _current = [[UIImageView alloc] initWithFrame:CGRectMake(88, 206, 30, 30)];
    _current.image = [UIImage imageNamed:@"marker.png"];
    _current.layer.cornerRadius = _current.frame.size.height/2.f;
    
    [_floorMap addSubview:_current];
    
    _distancelbl = [[UILabel alloc] initWithFrame:CGRectMake(130, 206, 70, 30)];
    _distancelbl.backgroundColor = [UIColor yellowColor];
    _distancelbl.layer.cornerRadius = _current.frame.size.height/2.f;
    
    [_floorMap addSubview:_distancelbl];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(navigationTick:)
                                   userInfo:nil
                                    repeats:YES];
    
    _isRouting = NO;
    
//    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
//    tapPress.delaysTouchesBegan   = NO;
//    [_sv addGestureRecognizer:tapPress];
    
    [SVProgressHUD show];
    
    [[NavigineCore defaultCore] downloadLocationByName:@"Future Netwings"
                                           forceReload:NO
                                          processBlock:^(NSInteger loadProcess) {
                                              NSLog(@"%zd",loadProcess);
                                          } successBlock:^(NSDictionary *userInfo) {
                                              [self setupNavigine];
                                          } failBlock:^(NSError *error) {
                                              NSLog(@"%@",error);
                                          }];
    
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];

    [self noLocalConnection];

    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType motionType) {
        NSString *type = @"";
        switch (motionType) {
            case MotionTypeNotMoving:
                type = @"Not moving";
                break;
            case MotionTypeWalking:
                type = @"Walking";
                //  [self performSelector:@selector(moveMarker) withObject:self afterDelay:0.0];
                break;
            case MotionTypeRunning:
                type = @"Running";
                break;
            case MotionTypeAutomotive:
                type = @"Automotive";
                break;
        }
        
        typeOfMotion = type;
        
        // weakSelf.motionTypeLabel.text = type;
    };
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    if (self.motionManager.deviceMotionAvailable) {
        
        self.motionManager.deviceMotionUpdateInterval = 0.1;
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self.motionManager startDeviceMotionUpdatesToQueue:queue
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    
                                                    // Get the attitude of the device
                                                    CMAttitude *attitude = motion.attitude;
                                                    
                                                    // Get the pitch (in radians) and convert to degrees.
                                                    NSLog(@"%f", attitude.pitch * 180.0/M_PI);
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        // Update some UI
                                                        
                                                        
                                                        
                                                    });
                                                    
                                                }];
        
        NSLog(@"Device motion started");
    }
    else {
        NSLog(@"Device motion unavailable");
    }
    
    [self.btnStartNavigation setEnabled:NO];
    [self.btnStopNavigation setEnabled:NO];
    
    //NSLog(@"%@",core.location.name);
    
   // [self getUserLocation];
    
    self.btnStartNavigation.layer.borderColor = [UIColor blueColor].CGColor;
    self.btnStartNavigation.layer.borderWidth = 1.0;
    self.btnStartNavigation.layer.cornerRadius = 5.0;
    
    self.btnStopNavigation.layer.borderColor = [UIColor blueColor].CGColor;
    self.btnStopNavigation.layer.borderWidth = 1.0;
    self.btnStopNavigation.layer.cornerRadius = 5.0;
    
}


- (void)loadConnectedBridgeValues{
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        NSLog(@"%@",cache.bridgeConfiguration.ipaddress);
        
        NSLog(@"%@",cache.bridgeConfiguration.bridgeId);
        
        // Check if we are connected to the bridge right now
        if (APPDELEGATE.phHueSDK.localConnected) {
            
            NSLog(@"Connected...");
            
        } else {
            
            NSLog(@"Waiting...");
            
        }
    }
    
}


- (IBAction)selectOtherBridge:(id)sender{
    
    [self searchForBridgeLocal];
}


- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    //[self checkConnectionState];
}

-(void)viewWillAppear:(BOOL)animated{
    
    destinationsArray = @[@"Director's Room",@"Pantry",@"Toilet",@"Conference Room",@"Exit"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Beacons" ofType:@"plist"];
    beaconArray = [NSArray arrayWithContentsOfFile:path];
    
    for (NSDictionary *dictionary in beaconArray)
    {
        NSLog(@"checked value is: %@", dictionary);
    }
    
    [Userdefaults setBool:YES forKey:@"isMapOpen"];
    
    [Userdefaults synchronize];

    
    if([Userdefaults objectForKey:@"bridgeSelected"]){
        
       // NSLog(@"%@",[Userdefaults objectForKey:@"ip"]);
       // NSLog(@"%@",[Userdefaults objectForKey:@"selectedBridgeId"]);
        
        if ([Userdefaults objectForKey:@"ip"]!=nil) {
            
            [APPDELEGATE bridgeSelectedWithIpAddress:[Userdefaults objectForKey:@"ip"] andBridgeId:[Userdefaults objectForKey:@"selectedBridgeId"]];
        }
    }
    
    [self lightOnAndOff:NO];
    
    [self.btnOperateLight setOn:NO];
    
    timerforApi = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                   target:self
                                                 selector:@selector(apiforCMX)
                                                 userInfo:nil
                                                  repeats:YES];
    
    [timerforApi fire];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    _zoneArray = nil;
    [self getZone];
    [SVProgressHUD dismiss];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [Userdefaults setBool:NO forKey:@"isMapOpen"];
    
    [Userdefaults synchronize];
}


-(void)apiforCMX
{
    BOOL isConferenceArea = [Userdefaults boolForKey:@"isConferenceArea"];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    if (isConferenceArea) {
        
        [self performSelectorInBackground:@selector(getMacAddressByipAddress) withObject:nil];
    }
}



-(void)lightOnAndOff:(BOOL)status
{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        // PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setOnBool:isON];
        
        [lightState setHue:[NSNumber numberWithInt:33410]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            
            if (errors != nil) {
                
                 NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                 NSLog(@"Response: %@",message);
                
            }
            
        }];
    }
}


- (IBAction)openPanelAction:(id)sender
{
    UIStoryboard *storyboard2 = [UIStoryboard storyboardWithName:@"BeaconFlow" bundle:[NSBundle mainBundle]];
    
    panelVC = [storyboard2 instantiateViewControllerWithIdentifier:@"PanelViewController"];
    
    [self presentViewController:panelVC animated:YES completion:nil];
    
}


-(void)updatelocation
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.LocationManager)
        
        self.LocationManager = [[CLLocationManager alloc] init];
    
    self.LocationManager.delegate = self;
    self.LocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.LocationManager.activityType = CLActivityTypeOtherNavigation;
    
    // Set a movement threshold for new events.
    self.LocationManager.distanceFilter = 10; // meters
    
    [self.LocationManager startUpdatingLocation];
    
    [self.LocationManager requestAlwaysAuthorization];
    
    [self.LocationManager startMonitoringSignificantLocationChanges];
    
}


#pragma mark - Location Manager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
        [self.LocationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusDenied) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized" message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else
        
        NSLog(@"Wrong location status");
}


-(void)getZone{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *url = [NSString stringWithFormat:@"https://api.navigine.com/zone_segment/getAll?userHash=0F17-DAE1-4D0A-1778&sublocationId=3247"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        _zoneArray = [NSArray arrayWithArray:[dict objectForKey:@"zoneSegments"]];
        
       // NSLog(@"zoneArray: %@", _zoneArray);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        
    }];
    
}

-(void)buttonTapped:(UIButton *)sender{
    NSLog(@"Button Clicked");
}

- (IBAction)backPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startPressed:(id)sender {
    
    CGFloat xPoint = 17.73;
    CGFloat yPoint = 7.30;
    _targetPoint = CGPointMake(xPoint, yPoint);
    
    [self drawPathWithEndPoint:_targetPoint];
    
    isStarted = YES;
}


- (void) navigationTick: (NSTimer *)timer{
    
    NavigationResults res = [[NavigineCore defaultCore] getNavigationResults];
    
    if (res.ErrorCode == 0){
        
        //NSLog(@"RESULT: %lf %lf",res.X,res.Y);
        NSDictionary* dic = [self didEnterZoneWithPoint:CGPointMake(res.kX, res.kY)];
        
        if ([[dic allKeys] containsObject:@"name"]) {
            
            //            NSLog(@"zone detected:%@",dic);
            
            NSString* zoneName = [dic objectForKey:@"name"];
            
            if (!_currentZoneName) {
                
                _currentZoneName = zoneName;
                [self enterZoneWithZoneName:_currentZoneName];
                
            } else {
                
                if (![zoneName isEqualToString:_currentZoneName]) {
                    
                    [self exitZoneWithZoneName:_currentZoneName];
                    _currentZoneName = zoneName;
                    [self enterZoneWithZoneName:_currentZoneName];
                    
                } else {
                    
                }
            }
            
            
        } else {
            
            if (_currentZoneName) {
                
                [self exitZoneWithZoneName:_currentZoneName];
                _currentZoneName = nil;
                
            } else {
                
            }
            
        }
        
        _current.center = CGPointMake(((_floorMap.width / _sv.zoomScale * res.kX) + 10) ,
                                      _floorMap.height / _sv.zoomScale * (1. - res.kY));
        
        _distancelbl.center = CGPointMake((_floorMap.width / _sv.zoomScale * res.kX) + 60,
                                          _floorMap.height / _sv.zoomScale * (1. - res.kY));
        
    }
    else{
        
        NSLog(@"Error code:%zd",res.ErrorCode);
    }
    
    
    if (_isRouting){
        
        NSArray *path = [[NavigineCore defaultCore] routePaths].firstObject;
        NSNumber *distance = [[NavigineCore defaultCore] routeDistances].firstObject;
        
        _distancelbl.text = [NSString stringWithFormat:@"%.2f m",[distance floatValue]];
        
        if ([distance floatValue]>1.0) {
            
            isPathAvailable = YES;
        }
        else
        {
            isPathAvailable = NO;;
        }
        
        [self drawRouteWithPath:path andDistance:distance];
    }
}


-(void)enterZoneWithZoneName:(NSString *)zoneName {
    
    if (zoneName) {
        
        if ([zoneName isEqualToString:@"conference area"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
           
            [self lightOnAndOff:YES];
            
            [Userdefaults setBool:YES forKey:@"isConferenceArea"];
            
            [Userdefaults synchronize];
            
            if ([Userdefaults boolForKey:@"speechConference"]==0) {
                
                AVSpeechUtterance *conference = [AVSpeechUtterance
                                                 speechUtteranceWithString:@"You have entered into the conference room. While you be sitted, please order refreshment from our pantryman."];
                
                AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
                
                [synth speakUtterance:conference];
                
                [Userdefaults setBool:true forKey:@"speechConference"];
                
                [Userdefaults synchronize];
            }
            
            
        } else if ([zoneName isEqualToString:@"entry area"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            [self operateDoor];
            
            isDown = NO;
            
        }
        else if ([zoneName isEqualToString:@"developer bay"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            isDown = YES;
            
            AVSpeechUtterance *dev = [AVSpeechUtterance
                                            speechUtteranceWithString:@"You are on the developer bay."];
            
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            
            [synth speakUtterance:dev];
            
        }
        else if ([zoneName isEqualToString:@"developer entry"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            isDown = YES;
            
        }
        else if ([zoneName isEqualToString:@"coridor"]) {
            
            [Userdefaults setBool:YES forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
            isDown = YES;
            
            AVSpeechUtterance *dev = [AVSpeechUtterance
                                      speechUtteranceWithString:@"You are on the coridor."];
            
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            
            [synth speakUtterance:dev];
            
        }
        
    }
    
}


-(void)exitZoneWithZoneName:(NSString *)zoneName {
    
    if (zoneName) {
        
        if ([zoneName isEqualToString:@"conference area"]) {
            
            [self lightOnAndOff:NO];
            
            [Userdefaults setBool:false forKey:@"speechConference"];
            
            [Userdefaults setBool:NO forKey:@"isConferenceArea"];
            
            [Userdefaults synchronize];
            
        }
        else if ([zoneName isEqualToString:@"developer entry"]) {
            
            isDown = NO;
            
        }
        else if ([zoneName isEqualToString:@"entry area"])
        {
            [Userdefaults setBool:NO forKey:@"isPreEntry"];
            
            [Userdefaults setBool:NO forKey:@"inRange"];
            
            [Userdefaults synchronize];
            
        }
    }
}


-(void) drawRouteWithPath: (NSArray *)path
              andDistance: (NSNumber *)distance {
    
    //    // We check that we are close to the finish point of the route
    if (distance.doubleValue <= 0.8){
        
        if (isStarted) {
            
            if (isPathAvailable) {
                
                [self stopRoute];
            }
            
            isStarted = NO;
        }
        
    }
    else{
        
        if (!_routhPath || (_routhPath && [_routhPath containsPoint:_current.center])) {
            
            [routeLayer removeFromSuperlayer];
            
            [uipath removeAllPoints];
            
            uipath     = [[UIBezierPath alloc] init];
            routeLayer = [CAShapeLayer layer];
            
            for (int i = 0; i < path.count; i++ ){
                
                NCVertex *vertex = path[i];
                
                CGSize imageSizeInMeters = [[NavigineCore defaultCore] sizeForImageAtIndex:0 error:nil];
                
                CGFloat xPoint =  (vertex.x.doubleValue / imageSizeInMeters.width) * (_floorMap.width / _sv.zoomScale);
                
                CGFloat yPoint =  (1. - vertex.y.doubleValue / imageSizeInMeters.height)  * (_floorMap.height / _sv.zoomScale);
                
                if(i == 0) {
                    [uipath moveToPoint:CGPointMake(xPoint, yPoint)];
                }
                else
                {
                    [uipath addLineToPoint:CGPointMake(xPoint, yPoint)];
                }
            }
            
            if (_routhPath) {
                
                
            } else {
                
                _routhPath = uipath;
            }
            
            routeLayer.hidden = NO;
            routeLayer.path            = [uipath CGPath];
            routeLayer.strokeColor     = [kColorFromHex(0x4AADD4) CGColor];
            routeLayer.lineWidth       = 5.0;
            routeLayer.lineJoin        = kCALineJoinRound;
            routeLayer.fillColor       = [[UIColor clearColor] CGColor];
            
            [_floorMap.layer addSublayer:routeLayer];
            
            [_floorMap bringSubviewToFront:_current];
            
        } else {
            
            
            // [self stopRoute];
            
            _routhPath = nil;
            [self reRoutePath];
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
            //                                                        message:@"You are going to wrong route, please follow the navigation route in map."
            //                                                           delegate:nil
            //                                                  cancelButtonTitle:@"OK"
            //                                                  otherButtonTitles:nil];
            //
            //            [alert show];
            
        }
        
    }
    
}


- (void)reRoutePath {
    
    [self drawPathWithEndPoint:_targetPoint];
    
}


- (void)drawPathWithEndPoint:(CGPoint)endPoint
{
    NavigationResults res = [[NavigineCore defaultCore] getNavigationResults];
    //    CGSize imageSizeInMeters = [[NavigineCore defaultCore] sizeForImageAtIndex:0 error:nil];
    //    CGFloat xPoint = 7.44 /_imageView.width * imageSizeInMeters.width;
    //    CGFloat yPoint = (1. - 2.33 /_imageView.height) * imageSizeInMeters.height;
    
    CGFloat xPoint = endPoint.x;
    CGFloat yPoint = endPoint.y;
    
    NCVertex *vertex = [[NCVertex alloc] init];
    vertex.sublocationId = res.outSubLocation;
    vertex.x = @(xPoint);
    vertex.y = @(yPoint);
    
    [[NavigineCore defaultCore] addTatget:vertex];
    
    //    [_pressedPin.popUp removeFromSuperview];
    //    _pressedPin.popUp.hidden = YES;
    
    _isRouting = YES;
    
}

- (NSDictionary *)didEnterZoneWithPoint:(CGPoint)currentPoint {
    
    NSDictionary* zone = nil;
    
    if (_zoneArray) {
        
        for (NSInteger i = 0; i < [_zoneArray count]; i++) {
            
            NSDictionary* dicZone = [_zoneArray objectAtIndex:i];
            
            NSArray* coordinates = [dicZone objectForKey:@"coordinates"];
            
            if ([coordinates count]>0) {
                
                UIBezierPath* path = [[UIBezierPath alloc]init];
                
                for (NSInteger j=0; j < [coordinates count]; j++) {
                    
                    NSDictionary* dicCoordinate = [coordinates objectAtIndex:j];
                    
                    if ([[dicCoordinate allKeys] containsObject:@"kx"]) {
                        
                        float xPoint = [[dicCoordinate objectForKey:@"kx"] floatValue];
                        float yPoint = [[dicCoordinate objectForKey:@"ky"] floatValue];
                        
                        CGPoint point = CGPointMake(xPoint, yPoint);
                        
                        if (j == 0) {
                            
                            [path moveToPoint:point];
                            
                        } else {
                            
                            [path addLineToPoint:point];
                        }
                    }
                }
                
                [path closePath];
                
                if ([path containsPoint:currentPoint]) {
                    
                    zone = [NSDictionary dictionaryWithDictionary:dicZone];
                    
                    break;
                    
                } else {
                    
                    zone = nil;
                    
                }
            }
        }
        
    } else {
        
    }
    
    return zone;
}


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _floorMap;
}

#pragma mark NavigineCoreDelegate methods

- (void) didRangePushWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(NSString *)image
                            id:(NSInteger)id{
    // Your code
}

- (IBAction)chooseLocationPressed:(id)sender {
    
    [self stopRoute];
    
    if ([arrPointNames count]>0) {
        
        pop = [[popView alloc] init];
        
        pop.frame = self.view.bounds;
        pop.delegate = self;
        
        pop.arrayName = arrPointNames;
        
        [pop ResizeandReloadViews];
        
        [self.view addSubview:pop];
    }
}

-(void)popView:(popView *)obj didTapOnCell:(BOOL)isTap onIndex:(int)rowIndex
{
    if (isTap) {
        
        CGFloat xPoint = [[arrPointx objectAtIndex:rowIndex] floatValue];
        CGFloat yPoint = [[arrPointy objectAtIndex:rowIndex] floatValue];
        
        [self drawPathWithEndPoint:CGPointMake(xPoint, yPoint)];
        
        isStarted = YES;
        
        [pop removeFromSuperview];
    }
}

-(void)popView:(popView *)obj didTapOnBackground:(BOOL)isClose
{
    if (isClose) {
        
        [pop removeFromSuperview];
    }
}


- (IBAction)stopPressed:(id)sender {
  
    isStarted = NO;
    
    [self stopRoute];
}


-(void) setupNavigine{
    
    [[NavigineCore defaultCore] startNavigine];
    [[NavigineCore defaultCore] startPushManager];
    [[NavigineCore defaultCore] startVenueManager];
    
    NCLocation *location = [NavigineCore defaultCore].location;
    NCSublocation *sublocation = [location subLocationAtIndex:0];
    
    [SVProgressHUD dismiss];
    
    NSData *imageData = sublocation.pngImage;
    UIImage *image = [UIImage imageWithData:imageData];
    
    float scale = 1.f;
    if (image.size.width / image.size.height >
        self.view.frame.size.width / self.view.frame.size.height){
        scale = self.view.frame.size.height / image.size.height;
    }
    else{
        scale = self.view.frame.size.width / image.size.width;
    }
    _floorMap.frame = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
    _floorMap.image = image;
    _sv.contentSize = _floorMap.frame.size;
    
    [Userdefaults setBool:YES forKey:@"isFirst"];
    
    [Userdefaults synchronize];
    
}

- (void)stopRoute {
    
    _isRouting = NO;
    
    [routeLayer removeFromSuperlayer];
    routeLayer = nil;
    
    [uipath removeAllPoints];
    uipath = nil;
    
    [[NavigineCore defaultCore] cancelTargets];
    
    //    _routhPath = nil;`
    
}


/* ---------------------------------------------------------------------------------- */

#pragma mark NavigineCoreDelegate methods

- (void) didRangeBeacons:(NSArray *)beacons
{
    //NSLog(@"beacons:%@",beacons);
}


/* ---------------------------------------------------------------------------------- */

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

- (IBAction)btnOpenDoorDidTap:(id)sender {
    
    //_destinationsView.hidden = NO;
    [self operateDoor];

}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [destinationsArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [destinationsArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Destination Selected : %@",[destinationsArray objectAtIndex:indexPath.row]);
    //  poi = indexPath.row;
    [self loadPOIBeacons:indexPath.row];
    
    _destinationsView.hidden = YES;
    
}

    
-(void)loadPOIBeacons:(long)poi
{
    switch (poi) {
        
        case 0:
            NSLog(@"Destination Selected : %@",[destinationsArray objectAtIndex:poi]);
                break;
        case 1:
            NSLog(@"Destination Selected : %@",[destinationsArray objectAtIndex:poi]);       break;
        case 2:
            NSLog(@"Destination Selected : %@",[destinationsArray objectAtIndex:poi]);       break;
        case 3:
            NSLog(@"Destination Selected : %@",[destinationsArray objectAtIndex:poi]);       break;
        case 4:
            NSLog(@"Destination Selected : %@",[destinationsArray objectAtIndex:poi]);       break;
            
        default:
                break;
    }
}


- (IBAction)btnOperateLightDidTap:(id)sender {
    
    NSLog(@"%@",lightState);
    
    if([lightState.on boolValue]){
        
        NSLog(@"Switch is ON");
        
        isON = NO;
        
        [self lightOnAndOff:NO];
        
    } else{
        
        [self lightOnAndOff:YES];
        
        isON = YES;
        
        NSLog(@"Switch is OFF");
        
    }
}



- (IBAction)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Initiate Navigation"
                     image:nil
                    target:self
                    action:@selector(startPressed:)],
      
      [KxMenuItem menuItem:@"Select Meeting Location"
                     image:nil
                    target:self
                    action:@selector(chooseLocationPressed:)],
      
      [KxMenuItem menuItem:@"End Navigation"
                     image:nil
                    target:self
                    action:@selector(stopPressed:)],
      
      [KxMenuItem menuItem:@"Light ON/OFF"
                     image:nil
                    target:self
                    action:@selector(btnOperateLightDidTap:)],
      
      [KxMenuItem menuItem:@"Open Control Panel"
                     image:nil
                    target:self
                    action:@selector(openPanelAction:)],
      
      [KxMenuItem menuItem:@"Open door"
                     image:nil
                    target:self
                    action:@selector(btnOpenDoorDidTap:)],
      
      ];
    
    
    [KxMenu showMenuInView:self.view.window
                  fromRect:sender.frame
                 menuItems:menuItems];
    
}
    
-(void)getMacAddressByipAddress
{
    NSString *CurrentIPAddress = [NSString stringWithFormat:@"%@",[SystemSharedServices currentIPAddress]];
    
    NSLog(@"Current IP Address: %@",[SystemSharedServices currentIPAddress]);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    host_url = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_LOCAL,CurrentIPAddress];
    
//    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
//        
//        host_url = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_LOCAL,CurrentIPAddress];
//        
//    } else {
//        
//        host_url = [NSString stringWithFormat:@"%@api/location/v2/clients?ipAddress=%@",CMX_URL_GLOBAL,CurrentIPAddress];
//    }
    
    [manager GET:host_url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        [SVProgressHUD dismiss];
        
        NSArray *arr = responseObject;
        
        if ([arr count]>0) {
            
            NSDictionary *dict = [arr objectAtIndex:0];
            
            NSString *macaddress = [dict valueForKey:@"macAddress"];
            
            NSLog(@"macaddress: %@", macaddress);
            
            [self getDeviceByMacAddress:macaddress];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
        
    }];
    
}


    
-(void)getDeviceByMacAddress:(NSString *)macaddress{
    
    //NSLog(@"MAC address: %@",[self getGatewayIP]);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"admin" password:@"Fnspl@123456"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    host_url = [NSString stringWithFormat:@"%@api/location/v1/clients/count/byzone/detail?zoneId=112",CMX_URL_LOCAL];
    
//    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
//        
//        host_url = [NSString stringWithFormat:@"%@api/location/v1/clients/count/byzone/detail?zoneId=112",CMX_URL_LOCAL];
//        
//    } else {
//        
//        host_url = [NSString stringWithFormat:@"%@api/location/v1/clients/count/byzone/detail?zoneId=112",CMX_URL_GLOBAL];
//    }
    
    [manager GET:host_url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        [SVProgressHUD dismiss];
        
//        NSDictionary *dict = responseObject;
//        
//        NSArray *arr = [dict objectForKey:@"MacAddress"];
//        
//        if ([arr containsObject:macaddress]) {
//            
//            [self lightOnAndOff:YES];
//            
//            AVSpeechUtterance *conference = [AVSpeechUtterance
//                                             speechUtteranceWithString:@"You have entered into the conference room. While you be sitted, please order refreshment from our pantryman."];
//            
//            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
//            
//            [synth speakUtterance:conference];
//        }
//        else
//        {
//            [self lightOnAndOff:NO];
//            
////            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
////                                                                message:@"Device not found here."
////                                                               delegate:nil
////                                                      cancelButtonTitle:@"Ok"
////                                                      otherButtonTitles:nil];
////            [alertView show];
//
//        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
        
    }];
    
}



-(void)operateDoor{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId,@"doorstatus":@"0",@"firefrom":@"app"};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"http://eegrab.com/smartoffice/door_status.php"];
    
    [manager POST:host_url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        [SVProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


#pragma mark - Loading view

/**
 Shows an overlay over the whole screen with a black box with spinner and loading text in the middle
 @param text The text to display under the spinner
 */
- (void)showLoadingViewWithText:(NSString *)text {
    // First remove
    //[self removeLoadingView];
    
    // Then add new
    self.loadingView = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    self.loadingView.view.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.loadingView.view];
    self.loadingView.loadingLabel.text = text;
}

/**
 Removes the full screen loading overlay.
 */
- (void)removeLoadingView {
    if (self.loadingView != nil) {
        [self.loadingView.view removeFromSuperview];
        self.loadingView = nil;
    }
}


@end
