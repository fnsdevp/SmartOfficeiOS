//
//  CtrlViewController.m
//  SmartOffice
//
//  Created by FNSPL on 15/05/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "CtrlViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

#define MAX_HUE 65535

@interface CtrlViewController ()
{
    HomeViewController *home;
}
    
@end


@implementation CtrlViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.backVw.frame = self.view.bounds;
    
    self.panelVw.layer.cornerRadius = 5.0;
    
    lightState = [[PHLightState alloc] init];
    
    [SVProgressHUD show];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    [self noLocalConnection];
    
    if([Userdefaults objectForKey:@"bridgeSelected"]){
        
        // NSLog(@"%@",[Userdefaults objectForKey:@"ip"]);
        // NSLog(@"%@",[Userdefaults objectForKey:@"selectedBridgeId"]);
        
        if ([Userdefaults objectForKey:@"ip"]!=nil) {
            
            [APPDELEGATE bridgeSelectedWithIpAddress:[Userdefaults objectForKey:@"ip"] andBridgeId:[Userdefaults objectForKey:@"selectedBridgeId"]];
        }
    }
    
    [self lightOnAndOff:YES];
    [self.lightSwitch setOn:true animated:YES];
    
    //    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    //
    //    tapPress.delaysTouchesBegan = NO;
    //    tapPress.cancelsTouchesInView = NO;
    //
    //    [self.view addGestureRecognizer:tapPress];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    lightState = [[PHLightState alloc] init];
    
    _scrollView.contentSize = CGSizeMake(SCREENWIDTH, (_panelVw.frame.origin.y+_panelVw.frame.size.height+15));
    
    [SVProgressHUD dismiss];
    
}

//- (void)tapPress:(UITapGestureRecognizer *)gesture {
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (IBAction)closeBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (unsigned int)intFromHexString:(NSString *) hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt/ 255.0;
}

- (void)imageView:(DTColorPickerImageView *)imageView didPickColorWithColor:(UIColor *)color
{
    [self.colorPreviewView setBackgroundColor:color];
    
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    NSLog(@"Picked Color Components: %.0f, %.0f, %.0f", red * 255.0f, green * 255.0f, blue * 255.0f);
    
    NSString *hexString = [self hexStringFromColor:color];
    
    unsigned int num = [self intFromHexString:hexString];
    
    NSLog(@"%u",num);
    
    [self randomLight:num];
    
}


- (NSString *)hexStringFromColor:(UIColor *)color {
    
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}


- (IBAction)openDoorBtnPressed:(id)sender
{
    [self operateDoor];
}

- (IBAction)openMap:(id)sender
{
    UIStoryboard *storyboard2 = [UIStoryboard storyboardWithName:@"BeaconFlow" bundle:[NSBundle mainBundle]];
    
    IndoorMapViewController *indoorMap = [storyboard2 instantiateViewControllerWithIdentifier:@"IndoorMapViewController"];
    
    [self.navigationController pushViewController:indoorMap animated:YES];
}

- (void)randomLight:(int)HueColorCode
{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        // PHLightState *lightState = [[PHLightState alloc] init];
        
        // [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        
        [lightState setHue:[NSNumber numberWithInt:HueColorCode]];
        [lightState setBrightness:[NSNumber numberWithInt:_hueSlider.value]];
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


- (IBAction)hueBrightSlide:(id)sender
{
    // PHLightState *lightState = [[PHLightState alloc] init];
    
    NSLog(@"%@",lightState);
    
    NSLog(@"%f",_hueSlider.value);
    
    [lightState setBrightness:[NSNumber numberWithInt:_hueSlider.value]];
    [lightState setSaturation:[NSNumber numberWithInt:254]];
    
}


- (IBAction)setState:(id)sender
{
    NSLog(@"%@",lightState);
    
    if ([lightState.on boolValue])
    {
        [self lightOnAndOff:NO];
    }
    else
    {
        [self lightOnAndOff:YES];
    }
}


-(void)lightOnAndOff:(BOOL)isON
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
                
                // NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                // NSLog(@"Response: %@",message);
                
                [self.lightSwitch setOn:!isON animated:YES];
            }
            else
            {
                // NSLog(@"lightState: %@",lightState);
                
                [self.lightSwitch setOn:isON animated:YES];
            }
            
        }];
    }
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
    
    [APPDELEGATE searchForBridgeLocal];
}


- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}


- (void)noLocalConnection {
    // Check current connection state
    // [self checkConnectionState];
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


-(void)operateDoor{
    
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":@"37",@"doorstatus":@"0",@"firefrom":@"app"};
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

