//
//  RescheduleView.m
//  SmartOffice
//
//  Created by FNSPL on 08/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "RescheduleView.h"

@implementation RescheduleView


-(RescheduleView *) init{
    
    RescheduleView *result = nil;
    
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options: nil];
    
    for (id anObject in elements)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            result = anObject;
            
            break;
        }
    }
    
    return result;
}


- (void)drawRect:(CGRect)rect {
    
    arrTimes = [[NSMutableArray alloc] init];
    
    arrBooked = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
    
    self.backVw.frame = self.bounds;
    
    self.frontVw.layer.cornerRadius = 5.0;
    self.frontVw.layer.borderColor = [UIColor whiteColor].CGColor;
    self.frontVw.layer.borderWidth = 2.0;
    
    self.btnDone.layer.cornerRadius = 8.0;
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    NSDictionary *dict = _dictdetails;
    
    fromTime = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromtime"]];
    
    toTime = [NSString stringWithFormat:@"%@",[dict objectForKey:@"totime"]];
    
    NSDictionary *userdetails = [dict objectForKey:@"userdetails"];
    
    Phone = [userdetails objectForKey:@"phone"];
    
    [dt setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *CDate = [dt dateFromString:self.fDateSel];
    
    NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
    
    NSDate *currentWeekDate = [NSDate dateWithTimeInterval:(24*60*60*7) sinceDate:currentDate];
    
    NSComparisonResult compare2 = [currentWeekDate compare:CDate];
    
    if ((compare2==NSOrderedDescending)||(compare2==NSOrderedSame)){
        
        isCurrentWeek = YES;
    }
    
    NSString *currentDateStr = [dt stringFromDate:self.initialDate];
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if ([userType isEqualToString:@"Guest"]) {
        
        if ([Phone length]>0) {
            
            [self getEmployeeavailTimeforDate:currentDateStr];
        }
        
    } else {
        
        [self getUseravailTimeforDate:currentDateStr];
    }
    
    [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    NSString *fulldate1 = [NSString stringWithFormat:@"%@ %@",self.fdate,fromTime];
    
    NSDate* date1 = [dt dateFromString:fulldate1];
    
    NSString *fulldate2 = [NSString stringWithFormat:@"%@ %@",self.fdate,toTime];
    
    NSDate* date2 = [dt dateFromString:fulldate2];
    
    
    NSCalendar *c = [NSCalendar currentCalendar];
    
    
    NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:date1 toDate:date2 options:0];
    
    NSInteger diff = components.hour;
    
    duration = [NSString stringWithFormat:@"%d",(int)diff];
    
    
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    
    tapPress.delaysTouchesBegan = NO;
    tapPress.cancelsTouchesInView = NO;
    
    [self.backVw addGestureRecognizer:tapPress];
    
}


- (void)tapPress:(UITapGestureRecognizer *)gesture {
    
    [self.delegate RescheduleView:self didTapOnBackground:YES];
}


-(IBAction)cencelBtnPress:(id)sender
{
    [self.delegate RescheduleView:self didTapOnBackground:YES];
}


-(IBAction)okBtnPress:(id)sender
{
    [self.delegate RescheduleView:self fromTime:fromTime toTime:toTime duration:duration fDateSel:self.fdate okPressed:YES];
}


#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(collectionView == self.collectionViewDates){
        
        return 8;
        
    }else{
        
        return [self.hours count];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == self.collectionViewTimes){
        
        CGSize sizes = CGSizeMake(self.collectionViewTimes.frame.size.width/2, 40 * (SCREENHEIGHT/480));
        
        return sizes;
    }
    else
    {
        return CGSizeMake(58, 61);
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == self.collectionViewDates){
        
        static NSString *identifier = @"RescheduleDateCell";
        
        RescheduleDateCell *cell1 = (RescheduleDateCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        cell1.tag = indexPath.item;
        cell1.btnDate.tag = indexPath.item;
        cell1.delegate = self;
        
        if (isSelectedDate) {
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            [df setDateFormat:@"yyyy-MM-dd"];
            
            if (indexPath.item==0) {
                
                nextday = [df dateFromString:[df stringFromDate:self.initialDate]];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                
            }
            else
            {
                nextday = [df dateFromString:[df stringFromDate:self.initialDate]];
                nextday = [NSDate dateWithTimeInterval:((indexPath.item)*(24*60*60)) sinceDate:nextday];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
            }
            
            NSLog(@"%@",nextday);
            NSLog(@"%d",(int)cell1.tag);
            
            [cell1.btnDate setSelected:NO];
            
            [df setDateFormat:@"EEE"];
            
            day = [df stringFromDate:nextday];
            
            cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
            
            [df setDateFormat:@"d"];
            
            date = [df stringFromDate:nextday];
            
            cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
            
            [df setDateFormat:@"MMM"];
            
            month = [df stringFromDate:nextday];
            
            cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
            
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            
            BOOL isWeekEnd = [calendar isDateInWeekend:nextday];
            
            if (isWeekEnd) {
                
                [cell1.imgBg setHidden:NO];
                
                cell1.imgBg.image = [UIImage imageNamed:@"holidayImg"];
                
                cell1.lblday.textColor = [UIColor redColor];
                cell1.lblDate.textColor = [UIColor redColor];
                cell1.lblMonth.textColor = [UIColor redColor];
                
                cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                cell1.alpha = 1.0;
                
            }
            else
            {
                cell1.lblday.textColor = [UIColor whiteColor];
                cell1.lblDate.textColor = [UIColor whiteColor];
                cell1.lblMonth.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                [cell1.imgBg setHidden:YES];
                cell1.alpha = 0.4;
            }
            
            if (indexPath.row==seletedTag) {
                
                [cell1.btnDate  setSelected:YES];
                
                [cell1.imgBg setHidden:NO];
                
                cell1.imgBg.image = [UIImage imageNamed:@"currentDateImg"];
                
                cell1.lblday.textColor = [UIColor whiteColor];
                cell1.lblDate.textColor = [UIColor whiteColor];
                cell1.lblMonth.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                cell1.alpha = 1.0;
            }
            
            if (indexPath.row==7) {
                
                //nextday = [NSDate date];
                
                [cell1.imgBg setHidden:YES];
                
                cell1.lblday.text = [NSString stringWithFormat:@""];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
                cell1.lblDate.text = [NSString stringWithFormat:@"More"];
                
                cell1.lblMonth.text = [NSString stringWithFormat:@""];
                
                cell1.lblDate.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                [cell1.imgBg setHidden:YES];
                cell1.alpha = 0.4;
            }
            
        } else {
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            [df setDateFormat:@"yyyy-MM-dd"];
            
            if (indexPath.row == 0) {
                
                nextday = [df dateFromString:[df stringFromDate:self.initialDate]];
                
            } else {
                
                nextday = [df dateFromString:[df stringFromDate:self.initialDate]];
                nextday = [NSDate dateWithTimeInterval:((indexPath.item)*(24*60*60)) sinceDate:nextday];
            }
            
            
            NSString *strDateTime = [df stringFromDate:self.initialDate];
            
            NSDate *FirstDate = [df dateFromString:strDateTime];
            
            NSComparisonResult compare = [nextday compare:FirstDate];
            
            if (compare==NSOrderedSame) {
                
                [cell1.btnDate setSelected:YES];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                
                [df setDateFormat:@"EEE"];
                
                day = [df stringFromDate:nextday];
                
                cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
                
                [df setDateFormat:@"d"];
                
                date = [df stringFromDate:nextday];
                
                cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
                
                [df setDateFormat:@"MMM"];
                
                month = [df stringFromDate:nextday];
                
                cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
                
                [cell1.imgBg setHidden:NO];
                
                cell1.imgBg.image = [UIImage imageNamed:@"currentDateImg"];
                
                cell1.lblday.textColor = [UIColor whiteColor];
                cell1.lblDate.textColor = [UIColor whiteColor];
                cell1.lblMonth.textColor = [UIColor whiteColor];
                
                cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                
                cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                
                cell1.alpha = 1.0;
                
            } else {
                
                [cell1.btnDate setSelected:NO];
                
                cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0];
                
                [df setDateFormat:@"EEE"];
                
                day = [df stringFromDate:nextday];
                
                cell1.lblday.text = [NSString stringWithFormat:@"%@",day];
                
                [df setDateFormat:@"d"];
                
                date = [df stringFromDate:nextday];
                
                cell1.lblDate.text = [NSString stringWithFormat:@"%@",date];
                
                [df setDateFormat:@"MMM"];
                
                month = [df stringFromDate:nextday];
                
                cell1.lblMonth.text = [NSString stringWithFormat:@"%@",month];
                
                NSCalendar *Calendar3 = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                BOOL isWeekEnd3 = [Calendar3 isDateInWeekend:nextday];
                
                if (isWeekEnd3) {
                    
                    cell1.imgBg.image = [UIImage imageNamed:@"holidayImg"];
                    
                    cell1.lblday.textColor = [UIColor redColor];
                    cell1.lblDate.textColor = [UIColor redColor];
                    cell1.lblMonth.textColor = [UIColor redColor];
                    
                    cell1.contentView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1.0];
                    cell1.imgBg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
                    cell1.alpha = 1.0;
                    
                }
                else
                {
                    cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                    cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                    [cell1.imgBg setHidden:YES];
                    cell1.alpha = 0.4;
                }
                
                if (indexPath.item==7) {
                    
                    //nextday = [NSDate date];
                    
                    [cell1.imgBg setHidden:YES];
                    
                    cell1.lblday.text = [NSString stringWithFormat:@""];
                    
                    cell1.lblDate.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
                    cell1.lblDate.text = [NSString stringWithFormat:@"More"];
                    
                    cell1.lblMonth.text = [NSString stringWithFormat:@""];
                    
                    cell1.lblDate.textColor = [UIColor whiteColor];
                    
                    cell1.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
                    cell1.imgBg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55];
                    [cell1.imgBg setHidden:YES];
                    cell1.alpha = 0.4;
                }
            }
            
        }
        
        return cell1;
    }
    else
    {
        static NSString *identifier = @"RescheduleTimeCell";
        
        RescheduleTimeCell *cell2 = (RescheduleTimeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        NSString *userType = [userDict objectForKey:@"usertype"];
        
        if ([userType isEqualToString:@"Guest"]) {
            
            cell2.tag = indexPath.item;
            cell2.btnTime.tag = indexPath.item;
            cell2.delegate = self;
            
            if ([Phone length]>0) {
                
                [self timeSlotSettings:cell2 withIndexPath:indexPath];
                
            } else {
                
                [cell2.btnTime setTitle:[NSString stringWithFormat:@"%@",[self.hours objectAtIndex:indexPath.item]] forState:UIControlStateNormal];
                
                [cell2.btnTime setSelected:NO];
                [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                [cell2.btnTime setEnabled:NO];
                
                cell2.btnTime.alpha = 0.4;
            }
            
        } else {
            
            cell2.tag = indexPath.item;
            cell2.btnTime.tag = indexPath.item;
            cell2.delegate = self;
            
            [self timeSlotSettings:cell2 withIndexPath:indexPath];
        }
        
        return cell2;
    }
    
}


-(void)timeSlotSettings:(RescheduleTimeCell *)cell2 withIndexPath:(NSIndexPath *)indexPath
{
    [cell2.btnTime setTitle:[NSString stringWithFormat:@"%@",[self.hours objectAtIndex:indexPath.item]] forState:UIControlStateNormal];
    
    if (isSelectedTime) {
        
        NSArray *arr1 = [[self.hours objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"];
        
        NSString *firstTime = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        
        NSString *strDateTime = [NSString stringWithFormat:@"%@ %@",self.fdate,firstTime];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
        
        NSDate *FirstDate = [dt dateFromString:strDateTime];
        
        NSDate *currentDate = [NSDate date];
        
        NSComparisonResult compare = [currentDate compare:FirstDate];
        
        
        if((compare==NSOrderedAscending)||(compare==NSOrderedSame))
        {
            if (![arrBooked containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                
                if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                    
                    [cell2.btnTime setSelected:YES];
                    [cell2.btnTime setEnabled:YES];
                    [cell2.btnTime setBackgroundColor:[UIColor blackColor]];
                    [cell2.btnTime setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                    
                    UIColor *color = [UIColor whiteColor];
                    cell2.btnTime.layer.shadowColor = [color CGColor];
                    cell2.btnTime.layer.shadowRadius = 5.0f;
                    cell2.btnTime.layer.shadowOpacity = .9;
                    cell2.btnTime.layer.shadowOffset = CGSizeZero;
                    cell2.btnTime.layer.masksToBounds = NO;
                    
                    [arrTimes addObject:[self.hours objectAtIndex:indexPath.item]];
                    
                }
                else
                {
                    [cell2.btnTime setSelected:NO];
                    [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                    [cell2.btnTime setEnabled:YES];
                    
                    if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                        
                        [arrTimes removeObject:[self.hours objectAtIndex:indexPath.item]];
                    }
                }
                
                cell2.btnTime.alpha = 1.0;
                
            } else {
                
                [cell2.btnTime setSelected:NO];
                [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                [cell2.btnTime setEnabled:NO];
                
                cell2.btnTime.alpha = 0.4;
                
                if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                    
                    [arrTimes removeObject:[self.hours objectAtIndex:indexPath.item]];
                }
            }
            
        }
        else if (compare==NSOrderedDescending)
        {
            [cell2.btnTime setSelected:NO];
            [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
            [cell2.btnTime setEnabled:NO];
            
            cell2.btnTime.alpha = 0.4;
            
            if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                
                [arrTimes removeObject:[self.hours objectAtIndex:indexPath.item]];
            }
        }
        
        
    } else {
        
        NSArray *arr1 = [[self.hours objectAtIndex:indexPath.item] componentsSeparatedByString:@"-"];
        
        NSString *firstTime = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        
        NSString *strDateTime = [NSString stringWithFormat:@"%@ %@",self.fdate,firstTime];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dt setLocale:locale];
        
        [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
        
        NSDate *FirstDate = [dt dateFromString:strDateTime];
        
        NSDate *currentDate = [NSDate date];
        
        NSComparisonResult compare = [currentDate compare:FirstDate];
        
        
        if((compare==NSOrderedAscending)||(compare==NSOrderedSame))
        {
            if (![arrBooked containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                
//                if ([arrTimes count]==0) {
//                    
//                    [cell2.btnTime setSelected:YES];
//                    [cell2.btnTime setEnabled:YES];
//                    [cell2.btnTime setBackgroundColor:[UIColor blackColor]];
//                    [cell2.btnTime setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//                    
//                    UIColor *color = [UIColor whiteColor];
//                    cell2.btnTime.layer.shadowColor = [color CGColor];
//                    cell2.btnTime.layer.shadowRadius = 5.0f;
//                    cell2.btnTime.layer.shadowOpacity = .9;
//                    cell2.btnTime.layer.shadowOffset = CGSizeZero;
//                    cell2.btnTime.layer.masksToBounds = NO;
//                    
//                    [arrTimes addObject:[self.hours objectAtIndex:indexPath.item]];
//                    
//                    NSArray *arr1 = [[self.hours objectAtIndex:indexPath.item] componentsSeparatedByString:@"-"];
//                    
//                    fromTime = [arr1 objectAtIndex:0];
//                    
//                    toTime = [arr1 objectAtIndex:1];
//                    
//                }
//                else
//                {
                
                    [cell2.btnTime setSelected:NO];
                    [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                    [cell2.btnTime setEnabled:YES];
                    
                    if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                        
                        [arrTimes removeObject:[self.hours objectAtIndex:indexPath.item]];
                    }
//                }
                
                cell2.btnTime.alpha = 1.0;
                
            } else {
                
                [cell2.btnTime setSelected:NO];
                [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
                [cell2.btnTime setEnabled:NO];
                
                cell2.btnTime.alpha = 0.4;
                
                if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                    
                    [arrTimes removeObject:[self.hours objectAtIndex:indexPath.item]];
                }
            }
            
        }
        else if (compare==NSOrderedDescending)
        {
            [cell2.btnTime setSelected:NO];
            [cell2.btnTime setBackgroundColor:[UIColor whiteColor]];
            [cell2.btnTime setEnabled:NO];
            
            cell2.btnTime.alpha = 0.4;
            
            if ([arrTimes containsObject:[self.hours objectAtIndex:indexPath.item]]) {
                
                [arrTimes removeObject:[self.hours objectAtIndex:indexPath.item]];
            }
        }
        
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionViewDates){
        
        RescheduleDateCell *cell1 = (RescheduleDateCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell1.delegate = self;
        
    }else{
        
        RescheduleTimeCell *cell2 = (RescheduleTimeCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell2.delegate = self;
    }
}


#pragma Mark - MeetingTimeCollectionViewCellDelegate

- (void)cellTap:(id)sender {
    
    RescheduleTimeCell* cell = (RescheduleTimeCell *)sender;
    
    UIButton* btn = cell.btnTime;
    
    isSelectedTime = YES;
    
    if ([btn isSelected]) {
        
        NSLog(@"btn.tag: %d",(int)btn.tag);
        NSLog(@"([hours count]-1): %d",(int)([self.hours count]-1));
        
        if ([arrTimes count]==1) {
            
            btnTag = (int)btn.tag;
            
            UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Alert"
                                                                          message:@"You have to select atleast one date to schedule an meeting."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action)
                                       {
                                           
                                           [self.delegate RescheduleView:self didShowAlert:YES];
                                           
                                       }];
            
            [alert addAction:okButton];
            
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
            
            [self removeFromSuperview];
            
        }
        else
        {
            [btn setSelected:NO];
            [btn setBackgroundColor:[UIColor whiteColor]];
            
            [arrTimes removeObject:[self.hours objectAtIndex:(int)btn.tag]];
            
            [self deselectAutoDates:btn.tag];
        }
        
    } else {
        
        if ([arrTimes count]>=1) {
            
            arrIndex = [[NSMutableArray alloc] init];
            
            for (int i=0; i<[arrTimes count]; i++) {
                
                [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[self.hours indexOfObject:[arrTimes objectAtIndex:i]]]];
                
                // NSLog(@"works");
                
            }
            
            NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
            
            int minInt = (int)[copyArr[0] integerValue];
            int maxInt = (int)btn.tag;
            
            for (int j=maxInt; j>(minInt-1); j--) {
                
                if ([arrBooked containsObject:[self.hours objectAtIndex:j]]) {
                    
                    for (int m=maxInt; m>(j-1); m--) {
                        
                        [arrTimes removeObject:[self.hours objectAtIndex:m]];
                    }
            
                    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Error"
                                                                                  message:@"You cannot include a schedule in reschedule meeting which is already booked."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction * action)
                                               {
                                                   
                                                   [self.delegate RescheduleView:self didShowAlert:YES];
                                                   
                                               }];
                    
                    [alert addAction:okButton];
                    
                    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                    
                    [self removeFromSuperview];
                    
                }
                else
                {
                    [btn setSelected:YES];
                    [btn setBackgroundColor:[UIColor blackColor]];
                    
                    UIColor *color = [UIColor whiteColor];
                    btn.layer.shadowColor = [color CGColor];
                    btn.layer.shadowRadius = 5.0f;
                    btn.layer.shadowOpacity = .7;
                    btn.layer.shadowOffset = CGSizeZero;
                    btn.layer.masksToBounds = NO;
                    
                    [arrTimes addObject:[self.hours objectAtIndex:(int)btn.tag]];
                    
                    [self selectAutoDates];
                }
            }
        }
        else
        {
            [btn setSelected:YES];
            [btn setBackgroundColor:[UIColor blackColor]];
            
            UIColor *color = [UIColor whiteColor];
            btn.layer.shadowColor = [color CGColor];
            btn.layer.shadowRadius = 5.0f;
            btn.layer.shadowOpacity = .7;
            btn.layer.shadowOffset = CGSizeZero;
            btn.layer.masksToBounds = NO;
            
            [arrTimes addObject:[self.hours objectAtIndex:(int)btn.tag]];
        }
        
    }
    
    [self.collectionViewTimes reloadData];
    
    [self makeTimes];
}


#pragma Mark - MeetingFormCollectionViewCellDelegate

- (void)dateCellTap:(id)sender {
    
    RescheduleDateCell* cell = (RescheduleDateCell *)sender;
    
    UIButton* btn = cell.btnDate;
    
    if (btn.tag<7) {
        
        [btn setSelected:YES];
        
        seletedTag = (int)btn.tag;
        
        isSelectedDate = YES;
        
        arrTimes = [[NSMutableArray alloc] init];
        
        NSString *strDate = [NSString stringWithFormat:@"%@ %@, 2017",cell.lblDate.text,cell.lblMonth.text];
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"d MMM, yyyy"];
        
        NSDate *currentdate = [dt dateFromString:strDate];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSString *currentDateStr = [dt stringFromDate:currentdate];
        
        self.fdate = currentDateStr;
        
        self.selectedDate = currentDateStr;
        
        //[self getTodaysMeetings:currentDateStr];
        
        NSDate *CDate = [dt dateFromString:self.fdate];
        
        NSDate *currentDate = [dt dateFromString:[dt stringFromDate:[NSDate date]]];
        
        NSDate *currentWeekDate = [NSDate dateWithTimeInterval:(24*60*60*7) sinceDate:currentDate];
        
        //[arrTimes addObject:[self.hours objectAtIndex:0]];
        
        [UIView animateWithDuration:0 animations:^{
            
            NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
            
            NSString *userType = [userDict objectForKey:@"usertype"];
            
            NSComparisonResult compare2 = [currentWeekDate compare:CDate];
            
            if ((compare2==NSOrderedDescending)||(compare2==NSOrderedSame)){
                
                isCurrentWeek = YES;
                
                if ([userType isEqualToString:@"Guest"]) {
                    
                    if ([Phone length]>0) {
                        
                        [self getEmployeeavailTimeforDate:self.fdate];
                    }
                    
                } else {
                    
                    [self getUseravailTimeforDate:currentDateStr];
                }
            }
            else
            {
                isCurrentWeek = NO;
                
                if ([userType isEqualToString:@"Guest"]) {
                    
                    if ([Phone length]>0) {
                        
                        [self getEmployeeavailTimeforDate:self.fdate];
                    }
                    
                } else {
                    
                    [self getUseravailTimeforDate:currentDateStr];
                }
            }
            
        } completion:^(BOOL finished) {
            //Do something after that...
            
            [self.collectionViewDates reloadData];
            
        }];
    }
    else
    {
        [self.delegate RescheduleView:self didTapOnCalender:YES];
    }
    
}


-(void)deselectAutoDates:(NSInteger)BtnTag
{
    if ([arrTimes count]>1) {
        
        arrIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrTimes count]; i++) {
            
            [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[self.hours indexOfObject:[arrTimes objectAtIndex:i]]]];
            
            // NSLog(@"works");
            
        }
        
        NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
        
        int minInt = (int)BtnTag;
        int maxInt = (int)[[copyArr lastObject] integerValue];
        
        arrTimes = [[NSMutableArray alloc] init];
        
        for (int j=maxInt; j>minInt; j--) {
            
            [arrTimes addObject:[self.hours objectAtIndex:j]];
        }
        
    }
}


-(void)selectAutoDates
{
    if ([arrTimes count]>1) {
        
        arrIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrTimes count]; i++) {
            
            [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[self.hours indexOfObject:[arrTimes objectAtIndex:i]]]];
            
            // NSLog(@"works");
            
        }
        
        NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
        
        int minInt = (int)[copyArr[0] integerValue];
        int maxInt = (int)[[copyArr lastObject] integerValue];
        
        arrTimes = [[NSMutableArray alloc] init];
        
        for (int j=maxInt; j>(minInt-1); j--) {
            
            [arrTimes addObject:[self.hours objectAtIndex:j]];
        }
    }
    
}


-(void)makeTimes
{
    if ([arrTimes count]>0) {
        
        arrIndex = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrTimes count]; i++) {
            
            [arrIndex addObject:[NSString stringWithFormat:@"%d",(int)[self.hours indexOfObject:[arrTimes objectAtIndex:i]]]];
            
            // NSLog(@"works");
            
        }
        
        NSArray *copyArr = [arrIndex sortedArrayUsingSelector:@selector(compare:)];
        
        int minInt = (int)[copyArr[0] integerValue];
        int maxInt = (int)[[copyArr lastObject] integerValue];
        
        NSArray *arr1 = [[self.hours objectAtIndex:minInt] componentsSeparatedByString:@"-"];
        
        fromTime = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        
        NSArray *arr2 = [[self.hours objectAtIndex:maxInt] componentsSeparatedByString:@"-"];
        
        toTime = [NSString stringWithFormat:@"%@",[arr2 objectAtIndex:1]];
        
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd hh:mm a"];
        
        NSString *fulldate1 = [NSString stringWithFormat:@"%@ %@",self.fdate,fromTime];
        
        NSDate* date1 = [dt dateFromString:fulldate1];
        
        NSString *fulldate2 = [NSString stringWithFormat:@"%@ %@",self.fdate,toTime];
        
        NSDate* date2 = [dt dateFromString:fulldate2];
        
        
        NSCalendar *c = [NSCalendar currentCalendar];
        
        
        NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:date1 toDate:date2 options:0];
        
        NSInteger diff = components.hour;
        
        duration = [NSString stringWithFormat:@"%d",(int)diff];
        
    }
}
    
    
-(void)showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You cannot select previous date to schedule a meeting."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    
    [alertView show];
}


-(void)getTodaysMeetings:(NSString *)currentDate
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId,@"date":currentDate};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_todaysMeetings.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            NSString *msg = [responseDict objectForKey:@"message"];
            
            if ([msg isEqualToString:@"Today this user doesn't avaialable"]) {
                
                arrBooked = [[NSMutableArray alloc] initWithArray:self.hours];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This user is not avaialable on selected date."
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                
                [alertView show];
                
            } else {
                
                [self getRoomsAvailableonDate:currentDate];
            }
            
            
            
            [SVProgressHUD dismiss];
            
            //            NSMutableArray *meetingsArr = [responseDict objectForKey:@"apointments"];
            //
            //            //NSLog(@"meetingsArr: %@", meetingsArr);
            //
            //            if ([meetingsArr count]>0) {
            //
            //                for (NSDictionary *dict in meetingsArr) {
            //
            //                    NSString *appointmentId = [dict objectForKey:@"id"];
            //
            //                    NSMutableArray *arrMeetings = [db getMeetingsById:appointmentId];
            //
            //                    if ([arrMeetings count]==0) {
            //
            //
            //                    }
            //                }
            //            }
            
        }else{
            
            NSString *msg = [responseDict objectForKey:@"message"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
            [SVProgressHUD dismiss];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getRoomsAvailableonDate:(NSString *)currentDate
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"date":currentDate};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@RoomsAvailable.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
        }else{
            
            NSString *msg = [responseDict objectForKey:@"message"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
            [SVProgressHUD dismiss];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getUseravailTimeforDate:(NSString *)Date
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId,@"date":Date};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_time_by_dateNuserid.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseDict allKeys] containsObject:@"timing"]) {
                
                arrTiming = [responseDict objectForKey:@"timing"];
                
                arrBooked = [[NSMutableArray alloc] init];
                
                if (isCurrentWeek) {
                    
                    [self checkAvailability:arrTiming];
                    
                } else {
                    
                    [self checkAvailableTime:arrTiming];
                }
                
            } else {
                
                if (isCurrentWeek) {
                    
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSString *msg = [responseDict objectForKey:@"message"];
                    
                    if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                    {
                        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                        
                        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                        
                        [dt setDateFormat:@"yyyy-MM-dd"];
                        
                        NSDate *currentDate = [dt dateFromString:Date];
                        
                        BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                        
                        if (isWeekEnd) {
                            
                            for (int i=0; i<[self.hours count]; i++) {
                                
                                if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                                {
                                    [arrBooked addObject:[self.hours objectAtIndex:i]];
                                }
                            }
                        }
                        
                    } else {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                        
                        [alertView show];
                    }
                    
                    [self.collectionViewTimes reloadData];
                    
                }
                else
                {
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[self.hours count]; i++) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                    [self.collectionViewTimes reloadData];
                }
                
            }
            
            
        }else{
            
            if (isCurrentWeek) {
                
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                [SVProgressHUD dismiss];
                
                NSString *msg = [responseDict objectForKey:@"message"];
                
                if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                {
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[self.hours count]; i++) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                } else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                }
                
                
                [self.collectionViewTimes reloadData];
                
            }
            else
            {
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                
                [dt setDateFormat:@"yyyy-MM-dd"];
                
                NSDate *currentDate = [dt dateFromString:Date];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                    
                    for (int i=0; i<[self.hours count]; i++) {
                        
                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                        }
                    }
                }
                
                [self.collectionViewTimes reloadData];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)getEmployeeavailTimeforDate:(NSString *)Date
{
    [SVProgressHUD show];
    
    if ([Phone length]==0) {
        
        Phone = @"";
    }
    
    NSDictionary *params = @{@"phone":Phone,@"date":Date};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableSet *jsonAcceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
    [jsonAcceptableContentTypes addObject:@"text/plain"];
    jsonResponseSerializer.acceptableContentTypes = jsonAcceptableContentTypes;
    
    manager.responseSerializer = jsonResponseSerializer;
    
    NSString *host_url = [NSString stringWithFormat:@"%@get_time_by_numberNdate.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            if ([[responseDict allKeys] containsObject:@"timing"]) {
                
                arrTiming = [responseDict objectForKey:@"timing"];
                
                arrBooked = [[NSMutableArray alloc] init];
                
                if (isCurrentWeek) {
                    
                    [self checkAvailability:arrTiming];
                    
                } else {
                    
                    [self checkAvailableTime:arrTiming];
                }
                
            } else {
                
                if (isCurrentWeek) {
                    
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSString *msg = [responseDict objectForKey:@"message"];
                    
                    if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                    {
                        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                        
                        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                        
                        [dt setDateFormat:@"yyyy-MM-dd"];
                        
                        NSDate *currentDate = [dt dateFromString:Date];
                        
                        BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                        
                        if (isWeekEnd) {
                            
                            for (int i=0; i<[self.hours count]; i++) {
                                
                                if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                                {
                                    [arrBooked addObject:[self.hours objectAtIndex:i]];
                                }
                            }
                        }

                        
                        
                        [self.collectionViewTimes reloadData];} else {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                        
                        [alertView show];
                    }
                    
                    [self.collectionViewTimes reloadData];
                    
                }
                else
                {
                    arrBooked = [[NSMutableArray alloc] init];
                    arrTimes = [[NSMutableArray alloc] init];
                    
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[self.hours count]; i++) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                    [self.collectionViewTimes reloadData];
                }
                
            }
            
            
        }else{
            
            if (isCurrentWeek) {
                
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                [SVProgressHUD dismiss];
                
                NSString *msg = [responseDict objectForKey:@"message"];
                
                if ([msg isEqualToString:@"Sorry This user doesn't set any availability."])
                {
                    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    
                    NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                    
                    [dt setDateFormat:@"yyyy-MM-dd"];
                    
                    NSDate *currentDate = [dt dateFromString:Date];
                    
                    BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                    
                    if (isWeekEnd) {
                        
                        for (int i=0; i<[self.hours count]; i++) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                            {
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                } else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                }
                
                [self.collectionViewTimes reloadData];
                
            }
            else
            {
                arrBooked = [[NSMutableArray alloc] init];
                arrTimes = [[NSMutableArray alloc] init];
                
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateFormatter *dt = [[NSDateFormatter alloc] init];
                
                [dt setDateFormat:@"yyyy-MM-dd"];
                
                NSDate *currentDate = [dt dateFromString:Date];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                    
                    for (int i=0; i<[self.hours count]; i++) {
                        
                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                        }
                    }
                }
                
                [self.collectionViewTimes reloadData];
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please check your internet connection."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}


-(void)checkAvailability:(NSArray *)arr
{
    for (NSDictionary *dict in arr) {
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *currentDate = [dt dateFromString:self.selectedDate];
        
        NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]]];
        
        NSComparisonResult compare = [currentDate compare:fromDate];
        
        if (compare==NSOrderedSame) {
            
            NSString *statusStr = [dict objectForKey:@"status"];
            
            if (([statusStr isEqual:[NSNull null]] )|| (statusStr==nil) || ([statusStr isEqualToString:@"<null>"]) || ([statusStr isEqualToString:@"(null)"]) || (statusStr.length==0 )|| ([statusStr isEqualToString:@""])|| (statusStr==NULL)||(statusStr == (NSString *)[NSNull null])||[statusStr isKindOfClass:[NSNull class]]|| (statusStr == (id)[NSNull null])) {
                
                statusStr = @"";
            }
            
            if ([statusStr isEqualToString:@"Y"])
            {
                NSString *givenFromTime = [dict objectForKey:@"from"];
                
                NSString *givenToTime = [dict objectForKey:@"to"];
                
                BOOL dontAddForm = false;
                BOOL dontAddTo = false;
                
                for (int i=0; i<[self.hours count]; i++) {
                    
                    NSArray *arr1 = [[self.hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                    
                    NSString *firstTime = [arr1 objectAtIndex:0];
                    
                    if (![firstTime isEqualToString:givenFromTime]) {
                        
                        if (dontAddForm==false) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                        }
                    }
                    else if ([firstTime isEqualToString:givenFromTime])
                    {
                        dontAddForm = true;
                    }
                    
                    if (dontAddForm) {
                        
                        if ([firstTime isEqualToString:givenToTime]) {
                            
                            dontAddTo = true;
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                            
                        }
                    }
                    
                    if (dontAddTo) {
                        
                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                            
                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                        }
                    }
                }
                
                
                NSArray *arrMettings = [dict objectForKey:@"meetings"];
                
                NSMutableArray *FromArr = [[NSMutableArray alloc] init];
                NSMutableArray *ToArr = [[NSMutableArray alloc] init];
                
                if (([arrMettings isEqual:[NSNull null]] )||(arrMettings==nil)||(arrMettings==NULL)||(arrMettings == (NSArray *)[NSNull null])||[arrMettings isKindOfClass:[NSNull class]]|| (arrMettings == (id)[NSNull null])) {
                    
                    arrMettings = @[];
                    
                }
                
                if ([arrMettings count]>0) {
                    
                    for (NSDictionary *dict1 in arrMettings) {
                        
                        BOOL dontAddFormArr = false;
                        BOOL dontAddToArr = false;
                        
                        if ([[dict1 allKeys] containsObject:@"from"]) {
                            
                            [FromArr addObject:[dict1 objectForKey:@"from"]];
                            
                        }
                        
                        if ([[dict1 allKeys] containsObject:@"to"]){
                            
                            [ToArr addObject:[dict1 objectForKey:@"to"]];
                        }
                        
                        if ([FromArr count]>0) {
                            
                            for (int i=0; i<[self.hours count]; i++) {
                                
                                NSArray *arr1 = [[self.hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                                
                                if (dontAddFormArr) {
                                    
                                    if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                        
                                        dontAddToArr = true;
                                        
                                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                            
                                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                                        }
                                    }
                                    else
                                    {
                                        if (dontAddToArr==0) {
                                            
                                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                                
                                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                                            }
                                        }
                                    }
                                    
                                }
                                else
                                {
                                    if ([FromArr containsObject:[arr1 objectAtIndex:0]]) {
                                        
                                        dontAddFormArr = true;
                                        
                                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                            
                                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                                        }
                                        
                                        if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                            
                                            dontAddToArr = true;
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                
            }
            else if ([statusStr isEqualToString:@"N"])
            {
                for (int i=0; i<[self.hours count]; i++) {
                    
                    if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                    {
                        [arrBooked addObject:[self.hours objectAtIndex:i]];
                    }
                }
                
            }
            else
            {
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                    
                    for (int i=0; i<[self.hours count]; i++) {
                        
                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                        }
                    }
                }
                else
                {
                    NSArray *arrMettings = [dict objectForKey:@"meetings"];
                    
                    NSMutableArray *FromArr = [[NSMutableArray alloc] init];
                    NSMutableArray *ToArr = [[NSMutableArray alloc] init];
                    
                    if (([arrMettings isEqual:[NSNull null]] )||(arrMettings==nil)||(arrMettings==NULL)||(arrMettings == (NSArray *)[NSNull null])||[arrMettings isKindOfClass:[NSNull class]]|| (arrMettings == (id)[NSNull null])) {
                        
                        arrMettings = @[];
                        
                    }
                    
                    
                    if ([arrMettings count]>0) {
                        
                        for (NSDictionary *dict1 in arrMettings) {
                            
                            BOOL dontAddFormArr = false;
                            BOOL dontAddToArr = false;
                            
                            if ([[dict1 allKeys] containsObject:@"from"]) {
                                
                                [FromArr addObject:[dict1 objectForKey:@"from"]];
                                
                            }
                            
                            if ([[dict1 allKeys] containsObject:@"to"]){
                                
                                [ToArr addObject:[dict1 objectForKey:@"to"]];
                            }
                            
                            if ([FromArr count]>0) {
                                
                                for (int i=0; i<[self.hours count]; i++) {
                                    
                                    NSArray *arr1 = [[self.hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                                    
                                    if (dontAddFormArr) {
                                        
                                        if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                            
                                            dontAddToArr = true;
                                            
                                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                                
                                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                                            }
                                        }
                                        else
                                        {
                                            if (dontAddToArr==0) {
                                                
                                                if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                                    
                                                    [arrBooked addObject:[self.hours objectAtIndex:i]];
                                                }
                                            }
                                        }
                                        
                                    }
                                    else
                                    {
                                        if ([FromArr containsObject:[arr1 objectAtIndex:0]]) {
                                            
                                            dontAddFormArr = true;
                                            
                                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                                
                                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                                            }
                                            
                                            if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                                                
                                                dontAddToArr = true;
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        [self.collectionViewTimes reloadData];
        
    }
    
}


-(void)checkAvailableTime:(NSArray *)arr
{
    for (NSDictionary *dict in arr) {
        
        NSDateFormatter *dt = [[NSDateFormatter alloc] init];
        
        [dt setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *currentDate = [dt dateFromString:self.selectedDate];
        
        NSDate *fromDate = [dt dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]]];
        
        NSComparisonResult compare = [currentDate compare:fromDate];
        
        if (compare==NSOrderedSame) {
            
            NSArray *arrMettings = [dict objectForKey:@"meetings"];
            
            NSMutableArray *FromArr = [[NSMutableArray alloc] init];
            NSMutableArray *ToArr = [[NSMutableArray alloc] init];
            
            if (([arrMettings isEqual:[NSNull null]] )||(arrMettings==nil)||(arrMettings==NULL)||(arrMettings == (NSArray *)[NSNull null])||[arrMettings isKindOfClass:[NSNull class]]|| (arrMettings == (id)[NSNull null])) {
                
                arrMettings = @[];
                
            }
            
            if ([arrMettings count]>0) {
                
                for (NSDictionary *dict1 in arrMettings) {
                    
                    if ([[dict1 allKeys] containsObject:@"from"]) {
                        
                        [FromArr addObject:[dict1 objectForKey:@"from"]];
                        
                    }
                    
                    if ([[dict1 allKeys] containsObject:@"to"]){
                        
                        [ToArr addObject:[dict1 objectForKey:@"to"]];
                    }
                }
                
                if ([FromArr count]>0) {
                    
                    for (int i=0; i<[self.hours count]; i++) {
                        
                        NSArray *arr1 = [[self.hours objectAtIndex:i] componentsSeparatedByString:@"-"];
                        
                        if ([FromArr containsObject:[arr1 objectAtIndex:0]]) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:i]]) {
                                
                                [arrBooked addObject:[self.hours objectAtIndex:i]];
                            }
                        }
                    }
                    
                    for (int j=(int)[self.hours count]-1; j>=0; j--) {
                        
                        NSArray *arr1 = [[self.hours objectAtIndex:j] componentsSeparatedByString:@"-"];
                        
                        if ([ToArr containsObject:[arr1 objectAtIndex:1]]) {
                            
                            if (![arrBooked containsObject:[self.hours objectAtIndex:j]])
                            {
                                [arrBooked addObject:[self.hours objectAtIndex:j]];
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            else
            {
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                
                BOOL isWeekEnd = [calendar isDateInWeekend:currentDate];
                
                if (isWeekEnd) {
                    
                    for (int i=0; i<[self.hours count]; i++) {
                        
                        if (![arrBooked containsObject:[self.hours objectAtIndex:i]])
                        {
                            [arrBooked addObject:[self.hours objectAtIndex:i]];
                        }
                    }
                }
                else
                {
                    arrTiming = [[NSMutableArray alloc] init];
                    
                    arrBooked = [[NSMutableArray alloc] init];
                }
            }
            
        }
        
        [self.collectionViewTimes reloadData];
    }
    
}


@end
