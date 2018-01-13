//
//  PantryViewController.h
//  SmartOffice
//
//  Created by FNSPL on 07/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PantryTableCell.h"
#import "ProductCell.h"

@class ViewController;

@interface PantryViewController : ViewController<UITableViewDelegate,UITableViewDataSource>
{
    UIView *navView;
    NSString *strFood;
    NSMutableArray *arrFood;
    
    NSArray *orderFoodArr;
    NSArray *orderFoodImgArr;
    
    NSMutableArray *typeList;
    NSMutableArray *itemList;
    
    NSString *host_url;
    
    BOOL isTypeClicked;
    
    int TypeTag;
}

@property (weak, nonatomic) IBOutlet UITableView *tblPantry;

@property (weak, nonatomic) IBOutlet UIView *headingVw;
    
@property (weak, nonatomic) IBOutlet UIButton *btnOrder;

- (IBAction)btnOrderDidTap:(id)sender;


@end
