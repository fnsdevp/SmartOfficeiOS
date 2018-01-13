//
//  RescheduleView.h
//  SmartOffice
//
//  Created by FNSPL on 08/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingFormCollectionViewCell.h"
#import "RescheduleDateCell.h"
#import "RescheduleTimeCell.h"
#import "Constants.h"

@protocol RescheduleViewDelegate;
@class RescheduleView;

@protocol RescheduleViewDelegate <NSObject>

@optional

-(void)RescheduleView:(RescheduleView *)obj fromTime:(NSString *)FromTime toTime:(NSString *)ToTime duration:(NSString *)Duration fDateSel:(NSString *)FDateSel okPressed:(BOOL)isTapped;
    
-(void)RescheduleView:(RescheduleView *)obj didTapOnBackground:(BOOL)isClose;
    
-(void)RescheduleView:(RescheduleView *)obj didTapOnCalender:(BOOL)isTapped;

-(void)RescheduleView:(RescheduleView *)obj didShowAlert:(BOOL)isShow;

@end

@interface RescheduleView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,RescheduleDateCellDelegate,RescheduleTimeCellDelegate>
{
    int Item;

    NSDate *nextday;
    NSString *month;
    NSString *date;
    NSString *day;
    
    int btnTag;
    
    BOOL isSelectedDate;
    BOOL isSelectedTime;
    
    int seletedTag;
    
    BOOL indexZeroDisable;

    NSString *userId;
    NSString *department;
    NSString *designation;
    NSString *fromTime;
    NSString *toTime;
    NSString *duration;
    NSString *agenda;
    NSString *sdate;
    
    NSString *sDateSel;
    
    NSString *Phone;
  
    int startIndex;
    int endIndex;
    
    BOOL isCurrentWeek;
    
    NSArray *arrTiming;
    
    NSMutableArray *arrTimes;
    NSMutableArray *arrIndex;
    
    NSMutableArray *arrBooked;
}

@property (nonatomic)id<RescheduleViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewDates;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewTimes;

@property (nonatomic, strong) IBOutlet UIView *backVw;
@property (nonatomic, strong) IBOutlet UIView *frontVw;
    
@property (nonatomic, strong) NSString *fdate;
@property (nonatomic, strong) NSString *fDateSel;
@property (nonatomic, strong) NSDate *initialDate;
@property (nonatomic, strong) NSString *selectedDate;
    
@property (nonatomic, strong) NSDictionary *dictdetails;
@property (nonatomic, strong) IBOutlet UIButton *btnDone;

@property (nonatomic, strong) NSArray *hours;

-(RescheduleView *) init;

@end
