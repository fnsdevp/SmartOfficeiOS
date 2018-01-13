//
//  ShowMessageViewController.h
//  SmartOffice
//
//  Created by FNSPL on 17/04/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "Constants.h"
#import "AFNetworking.h"

IB_DESIGNABLE

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@protocol ShowMessageViewControllerDelegate;
@class ShowMessageViewController;

@protocol ShowMessageViewControllerDelegate <NSObject>

@optional

-(void)ShowMessageViewController:(ShowMessageViewController *)obj didremove:(BOOL)isRemove relodeNeeded:(BOOL)isReloadNeed;

@end


@interface ShowMessageViewController : UIViewController
{
    NSString *userId;
    NSString *phone;
    NSString *title;
    NSString *message;
    
    UILabel *placeholderLabel;
    
}

@property (nonatomic)id<ShowMessageViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblname;
@property (weak, nonatomic) IBOutlet UILabel *lblemail;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UITextView *txtMessage;

@property (weak, nonatomic) NSString *nameStr;
@property (weak, nonatomic) NSString *emailStr;
@property (weak, nonatomic) NSString *phoneStr;
@property (weak, nonatomic) NSString *titleStr;
@property (weak, nonatomic) NSString *messageStr;
@property (weak, nonatomic) NSString *msgID;

@end
