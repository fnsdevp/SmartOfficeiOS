//
//  MessagesViewController.h
//  SmartOffice
//
//  Created by FNSPL on 11/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "Constants.h"
#import "Database.h"
#import "KxMenu.h"
#import "AFNetworking.h"
#import "DetailViewController.h"
#import "ShowMessageViewController.h"
#import "VCFloatingActionButton.h"

@interface MessagesViewController : UIViewController<DetailViewControllerDelegate,ShowMessageViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,VCFloatingDelegate>
{
    UIView *navView;
    NSString *userId;
    NSString *phone;
    NSString *title;
    NSString *message;
    
    NSString *name;
    NSString *email;
    NSString *phoneNo;
    
    BOOL isAll;
    BOOL isRead;
    BOOL isUnread;
    
    BOOL isInbox;
    
    NSArray *menuItems;
    
    NSMutableArray *inboxArr;
    NSMutableArray *outboxArr;
    NSMutableArray *readArr;
    NSMutableArray *unreadArr;
    NSMutableArray *allArr;
    
    NSMutableArray *messagesArr;
    
    DetailViewController *createVC;
    ShowMessageViewController *showVC;
}

@property (weak, nonatomic) IBOutlet UITableView *messagesTableView;
@property (weak, nonatomic) IBOutlet UIView *searchVw;
@property (weak, nonatomic) IBOutlet UIView *menuVw;
@property (weak, nonatomic) IBOutlet UISegmentedControl *msgType;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;

@property (strong, nonatomic) VCFloatingActionButton *addButton;

- (IBAction)btnDrawerMenuDidTap:(id)sender;

@end
