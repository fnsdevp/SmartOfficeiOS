//
//  RightSideDrawerViewController.h
//  SmartOffice
//
//  Created by FNSPL on 09/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutUsViewController.h"
#import "Constants.h"
#import "Database.h"
#import "DrawerTableViewCell.h"

@interface RightSideDrawerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    Database *db;
    NSMutableArray *userArr;
    
    int Index;
    
    NSDictionary *userDict;
}

- (IBAction)btnExitDrawerDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;

@end
