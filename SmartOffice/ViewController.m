//
//  ViewController.m
//  SmartOffice
//
//  Created by FNSPL on 03/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
//#import "APSSIDInfoObserver.h"

#define MAX_HUE 65535

@interface ViewController ()

//@property (nonatomic, strong) APSSIDInfoObserver *observer;

@property (weak, nonatomic) NSString *networkName;

@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //_observer = [APSSIDInfoObserver new];
    
    lightState = [[PHLightState alloc] init];
    
    //[SVProgressHUD show];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    [self noLocalConnection];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        UserId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    }
    
    //[self GetCurrentWifiHotSpotName];
    
    [self getUpcomingMeetings];
    
}


//-(void)GetCurrentWifiHotSpotName
//{
//    __weak __typeof(self) weakSelf = self;
//    
//    [self.observer setSSIDChangedBlock:^(APSSIDModel *model){
//        
//        if (model) {
//            
//            weakSelf.networkName = [NSString stringWithFormat:@"%@", model.ssid];
//            
//        } else {
//            
//           weakSelf.networkName = @"Cannot find wifi network";
//        }
//        
//        NSLog(@"%@",weakSelf.networkName);
//        
//    }];
//    
//    [self.observer startObserving];
//}



//-(IBAction)startLocalNotification:(NSString *)str {
//    
//    NSString *str1 = str;
//    
//    AVSpeechUtterance *utterance = [AVSpeechUtterance
//                                    speechUtteranceWithString:str1];
//    
//    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
//    
//    [synth speakUtterance:utterance];
//    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    
//    notification.alertBody = str1;
//    notification.timeZone = [NSTimeZone localTimeZone];
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.applicationIconBadgeNumber = 1;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    
//}


-(void)getUpcomingMeetings{
    
    if ([UserId length]>0) {
        
        NSDictionary *params = @{@"userid":UserId};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        NSString *host_url = [NSString stringWithFormat:@"%@upcoming_appointments.php",BASE_URL];
        
        [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *responseDict = responseObject;
            NSString *success = [responseDict objectForKey:@"status"];
            
            if ([success isEqualToString:@"success"]) {
                
                meetingsArr = [responseDict objectForKey:@"apointments"];
                
                //[self IsMeetingToday:self.cLoc];
                
                //NSLog(@"meetingsArr: %@", meetingsArr);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
        }];
        
    }
}


- (void)findNewBridgeButtonAction{
    
    [APPDELEGATE searchForBridgeLocal];
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
            
            //[SVProgressHUD dismiss];
            
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
