//
//  NotificationsViewController.h
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Database.h"
#import "Popup.h"
#import "ManageMeetingsDetailsViewController.h"

@interface NotificationsViewController : ViewController<UITableViewDataSource,UITableViewDelegate,PopupDelegate,UITextViewDelegate>
{
    Database *db;
    ManageMeetingsDetailsViewController *manageDetails;
    NSMutableArray *arrayNotif;
    
    PopupBackGroundBlurType blurType;
    PopupIncomingTransitionType incomingType;
    PopupOutgoingTransitionType outgoingType;
    
    Popup *popper;
    
    BOOL hasRoundedCorners;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotification;

- (IBAction)btnDrawerMenuDidTap:(id)sender;

@end
