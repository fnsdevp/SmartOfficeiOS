//
//  DetailViewController.h
//
//  Created by Martin Juhasz on 24.06.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "ContactsTableController.h"
#import "VeeContactPickerViewController.h"

IB_DESIGNABLE

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@protocol DetailViewControllerDelegate;
@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>

@optional

-(void)DetailViewController:(DetailViewController *)obj didremove:(BOOL)isRemove relodeNeeded:(BOOL)isReloadNeed;

@end


@interface DetailViewController : UIViewController<ContactsTableControllerDelegate,VeeContactPickerDelegate,UITextViewDelegate>
{
    NSString *userId;
    NSString *phone;
    NSString *title;
    NSString *message;
    
    UILabel *placeholderLabel;
    
    UIToolbar* keyboardToolbar;
   
    ContactsTableController *contactVC;
}

@property (nonatomic)id<DetailViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UITextView *txtMessage;
@property (weak, nonatomic) IBOutlet UIView *vwMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblPh;
@property (weak, nonatomic) IBOutlet UITextField *txtPh;


@end
