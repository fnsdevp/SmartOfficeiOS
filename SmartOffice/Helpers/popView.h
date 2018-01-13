//
//  popView.h
//  NavigineDemo
//
//  Created by FNSPL on 08/03/17.
//  Copyright © 2017 Navigine. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol popViewDelegate;
@class popView;

@protocol popViewDelegate <NSObject>

@optional

-(void)popView:(popView *)obj didTapOnCell:(BOOL)isTap onIndex:(int)rowIndex;
-(void)popView:(popView *)obj didTapOnBackground:(BOOL)isClose;


@end

@interface popView : UIView<UITableViewDelegate,UITableViewDataSource>
{
    int Row;
}

@property (nonatomic)id<popViewDelegate> delegate;
@property (nonatomic) NSMutableArray *arrayName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *backVw;

-(void)ResizeandReloadViews;

@end
