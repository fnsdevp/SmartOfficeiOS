//
//  SetAvailabilityViewController.h
//  SmartOffice
//
//  Created by FNSPL on 10/07/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetAvailabilityTableViewCell.h"
#import "Database.h"

@class ViewController;

@interface SetAvailabilityViewController : ViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIView *navView;
    UIDatePicker *timePicker;
    UIToolbar *toolbar;
    
    Database *db;
    
    NSDate *nextday;
    
    BOOL isFormDate;
    
    BOOL isON;
    
    NSString *userId;
    NSString *fromdate;
    NSString *todate;
    
    NSString *userID;
    NSString *date;
    NSString *day;
    NSString *from;
    NSString *to;
    NSString *status;
    
    NSMutableArray *userAvailArr;
}

@property (nonatomic, strong) IBOutlet UITableView *tblAvailability;

@end
