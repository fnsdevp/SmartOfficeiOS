//
//  MessagesViewController.m
//  SmartOffice
//
//  Created by FNSPL on 11/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessagesTableViewCell.h"

@interface MessagesViewController ()

@end


@implementation MessagesViewController

@synthesize addButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _timeView.frame.origin.y+_timeView.frame.size.height + 60);
    
    CGRect floatFrame = CGRectMake(self.messagesTableView.bounds.size.width - (44 + 20), self.messagesTableView.bounds.size.height - (94 + 20), 44, 44);
    
    [addButton removeFromSuperview];
    
    addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"floatingBtnNew"] andPressedImage:[UIImage imageNamed:@"floatingBtnNew"] withScrollview:_messagesTableView];
    
    addButton.hideWhileScrolling = YES;
    addButton.delegate = self;
    
    [self.messagesTableView addSubview:addButton];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    navView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [navView addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, navView.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    // NSString *blueText = @"Schedule";
    NSString *whiteText = @"Inbox";
    NSString *text = [NSString stringWithFormat:@"%@",
                      whiteText];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: label.font
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    self.messagesTableView.tableFooterView = [UIView new];
    
    //    UIColor *blueColor = [UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1.0];
    //    NSRange blueTextRange = [text rangeOfString:blueText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    //
    //    [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor}
    //                            range:blueTextRange];
    
    UIColor *whiteColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    NSRange whiteTextRange = [text rangeOfString:whiteText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    [attributedText setAttributes:@{NSForegroundColorAttributeName:whiteColor}
                            range:whiteTextRange];
    label.attributedText = attributedText;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    [navView addSubview:label];
    
    [self.navigationController.navigationBar addSubview:navView];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"isInboxVisible"];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    isInbox = YES;
    
    [self.msgType setSelectedSegmentIndex:0];
    
    [self getAllMessages];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [navView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setObject:@"No" forKey:@"isInboxVisible"];

}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [messagesArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MessagesTableViewCell";
    
    MessagesTableViewCell *cell = (MessagesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessagesTableViewCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dict = [messagesArr objectAtIndex:indexPath.row];
    
    NSString *status = [dict objectForKey:@"status"];
    
    if([status isEqualToString:@"unread"]){
        
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
        cell.descLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    }
    else
    {
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        cell.descLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    }
    
    cell.nameVw.layer.cornerRadius = cell.nameVw.frame.size.width/2;


    if (isInbox) {
        
        NSString *strName = [[dict objectForKey:@"from"] objectForKey:@"Name"];
        
        NSArray *subArr = [strName componentsSeparatedByString:@" "];
        
        if ([subArr count]>1) {
            
            NSString *letter1 = [subArr objectAtIndex:0];
            NSString *letter2 = [subArr objectAtIndex:1];
            
            NSString * firstLetter;
            NSString * secondLetter;
            
            if ([letter1 length] > 0) {
                
                firstLetter = [[letter1 substringWithRange:[letter1 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
            }
            
            if ([letter2 length] > 0) {
                
                secondLetter = [[letter2 substringWithRange:[letter2 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
            }
            
            //NSLog(@"%@",[NSString stringWithFormat:@"%@%@",firstLetter,secondLetter]);
            
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",firstLetter,secondLetter];
        }
        else
        {
            NSString *letter1 = [subArr objectAtIndex:0];
            
            NSString * firstLetter;
            
            if ([letter1 length] > 0) {
                
                firstLetter = [[letter1 substringWithRange:[letter1 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
            }
            
            cell.nameLabel.text = [NSString stringWithFormat:@"%@",firstLetter];
        }
        
        cell.titleLabel.text = [dict objectForKey:@"title"];
        cell.descLabel.text = [dict objectForKey:@"msg"];
        
    } else {
        
        NSString *strName = [[dict objectForKey:@"to"] objectForKey:@"Name"];
        
        NSArray *subArr = [strName componentsSeparatedByString:@" "];
        
        if ([subArr count]>1) {
            
            NSString *letter1 = [subArr objectAtIndex:0];
            NSString *letter2 = [subArr objectAtIndex:2];
            
            NSString * firstLetter;
            NSString * secondLetter;
            
            if ([letter1 length] > 0) {
                
                firstLetter = [[letter1 substringWithRange:[letter1 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
            }
            
            if ([letter2 length] > 0) {
                
                secondLetter = [[letter2 substringWithRange:[letter2 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
            }
            
            //NSLog(@"%@",[NSString stringWithFormat:@"%@%@",firstLetter,secondLetter]);
            
            cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",firstLetter,secondLetter];
        }
        else
        {
            NSString *letter1 = [subArr objectAtIndex:0];
            
            NSString * firstLetter;
            
            if ([letter1 length] > 0) {
                
                firstLetter = [[letter1 substringWithRange:[letter1 rangeOfComposedCharacterSequenceAtIndex:0]] uppercaseString];
            }
            
            cell.nameLabel.text = [NSString stringWithFormat:@"%@",firstLetter];
        }
        
        cell.titleLabel.text = [dict objectForKey:@"title"];
        cell.descLabel.text = [dict objectForKey:@"msg"];
    }
    
    NSString *date = [dict objectForKey:@"time"];
    NSArray *split = [date componentsSeparatedByString:@"-"];
    NSLog(@"split :%@",split);
    
    NSString *dayPart = [split objectAtIndex:2];
    
    NSArray *dayArr = [dayPart componentsSeparatedByString:@" "];
    
    NSString *day = [dayArr objectAtIndex:0];
    
    NSLog(@"day :%@",day);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSDate* myDate = [dateFormatter dateFromString:[split objectAtIndex:1]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM"];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    
    NSLog(@"%@", stringFromDate);
    NSString *month = stringFromDate;
    NSLog(@"month :%@",month);
    
    NSString *year = [split objectAtIndex:0];
    NSLog(@"year :%@",year);
    
    cell.dateLabel.text = day;
    cell.monthYrLabel.text = [NSString stringWithFormat:@"%@ %@",month,year];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    showVC = [[ShowMessageViewController alloc] init];
    
    showVC.delegate = self;
    
    NSDictionary *dict = [messagesArr objectAtIndex:indexPath.row];
    
    showVC.msgID = [dict objectForKey:@"id"];
    
    showVC.titleStr = [dict objectForKey:@"title"];
    
    showVC.messageStr = [dict objectForKey:@"msg"];
    
    if (isInbox)
    {
      name = [[dict objectForKey:@"from"] objectForKey:@"Name"];
        
      email = [[dict objectForKey:@"from"] objectForKey:@"Email"];
        
      phoneNo = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"from"] objectForKey:@"Phone"]];
    }
    else
    {
      name = [[dict objectForKey:@"to"] objectForKey:@"Name"];
        
      email = [[dict objectForKey:@"to"] objectForKey:@"Email"];
        
      phoneNo = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"to"] objectForKey:@"Phone"]];
    }
    
    showVC.nameStr = name;
    showVC.emailStr = email;
    showVC.phoneStr = phoneNo;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self presentViewController:showVC animated:NO completion:nil];
}

- (IBAction)btnDrawerMenuDidTap:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
    
}

- (IBAction)btnAllDidTap:(id)sender {
    
    isAll = YES;
    isRead = NO;
    isUnread = NO;
    
    [KxMenu setTintColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] ofMenu:[menuItems objectAtIndex:0]];
    [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:1]];
    [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:2]];
    
    if (isInbox) {
        
        messagesArr = inboxArr;
        
    } else {
        
        messagesArr = outboxArr;
    }
    
    [_messagesTableView reloadData];
}

- (IBAction)btnReadDidTap:(id)sender {
    
    isAll = NO;
    isRead = YES;
    isUnread = NO;
    
    [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:0]];
    [KxMenu setTintColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] ofMenu:[menuItems objectAtIndex:1]];
    [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:2]];
    
    readArr = [[NSMutableArray alloc]init];
    
    if (isInbox) {
        
        for (NSDictionary *dict in inboxArr) {
            
            NSString *status = [dict objectForKey:@"status"];
            
            if([status isEqualToString:@"read"]){
                
                [readArr addObject:dict];
            }
        }
        
    } else {
        
        for (NSDictionary *dict in outboxArr) {
            
            NSString *status = [dict objectForKey:@"status"];
            
            if([status isEqualToString:@"read"]){
                
                [readArr addObject:dict];
            }
        }
    }
    
    messagesArr = readArr;
    
    [_messagesTableView reloadData];
}

- (IBAction)btnUnreadDidTap:(id)sender {
    
    isAll = NO;
    isRead = NO;
    isUnread = YES;
    
    [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:0]];
    [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:1]];
    [KxMenu setTintColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] ofMenu:[menuItems objectAtIndex:2]];
    
    unreadArr = [[NSMutableArray alloc]init];
    
    if (isInbox) {
        
        for (NSDictionary *dict in inboxArr) {
            
            NSString *status = [dict objectForKey:@"status"];
            
            if([status isEqualToString:@"unread"]){
                
                [unreadArr addObject:dict];
            }
        }
        
    } else {
        
        for (NSDictionary *dict in outboxArr) {
            
            NSString *status = [dict objectForKey:@"status"];
            
            if([status isEqualToString:@"unread"]){
                
                [unreadArr addObject:dict];
            }
        }
    }
    
    messagesArr = unreadArr;
    
    [_messagesTableView reloadData];
    
}

-(void)didremove:(BOOL)isRemove
{
    createVC = [[DetailViewController alloc] init];
    
    createVC.delegate = self;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self presentViewController:createVC animated:NO completion:nil];
}

- (IBAction)btnCreateMessage:(id)sender {
    
    createVC = [[DetailViewController alloc] init];
    
    createVC.delegate = self;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self presentViewController:createVC animated:NO completion:nil];
    
}

-(void)DetailViewController:(DetailViewController *)obj didremove:(BOOL)isRemove relodeNeeded:(BOOL)isReloadNeed
{
    
    if (isRemove) {
        
        if(isReloadNeed)
        {
            [self getAllMessages];
        }
        
        [self dismissViewControllerAnimated:obj completion:nil];
    }
}

-(void)ShowMessageViewController:(ShowMessageViewController *)obj didremove:(BOOL)isRemove relodeNeeded:(BOOL)isReloadNeed
{
    [self dismissViewControllerAnimated:obj completion:nil];
}

-(void)getAllMessages
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@all_messages.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSString *success = [dict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            inboxArr = [dict objectForKey:@"inbox"];
            outboxArr = [dict objectForKey:@"outbox"];
            
            [self performSelector:@selector(btnAllDidTap:) withObject:nil afterDelay:0.0];
            
            [_messagesTableView reloadData];
    
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Problem to get messages, please check your internet connection & restart the app."
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


- (IBAction)changeType:(id)sender
{
    if (_msgType.selectedSegmentIndex == 0) {
        
        isInbox = YES;
        
        [self performSelector:@selector(btnAllDidTap:) withObject:nil afterDelay:0.0];
        
    } else if(_msgType.selectedSegmentIndex == 1) {
        
        isInbox = NO;
        
        [self performSelector:@selector(btnAllDidTap:) withObject:nil afterDelay:0.0];
    }
    
}


- (IBAction)showMenu:(UIButton *)sender
{
    menuItems =
    @[
      
      [KxMenuItem menuItem:@"All"
                     image:nil
                    target:self
                    action:@selector(btnAllDidTap:)],
      
      [KxMenuItem menuItem:@"Read"
                     image:nil
                    target:self
                    action:@selector(btnReadDidTap:)],
      
      [KxMenuItem menuItem:@"Unread"
                     image:nil
                    target:self
                    action:@selector(btnUnreadDidTap:)],
      
      [KxMenuItem menuItem:@"CREATE MESSAGE"
                     image:nil
                    target:self
                    action:@selector(btnCreateMessage:)],
      ];
    
    if (isAll) {
        
        [KxMenu setTintColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] ofMenu:[menuItems objectAtIndex:0]];
        [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:1]];
        [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:2]];
    }
    else if (isRead) {
        
        [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:0]];
        [KxMenu setTintColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] ofMenu:[menuItems objectAtIndex:1]];
        [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:2]];
    }
    else if (isUnread) {
        
        [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:0]];
        [KxMenu setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2] ofMenu:[menuItems objectAtIndex:1]];
        [KxMenu setTintColor:[UIColor colorWithRed:10/255.0 green:107/255.0 blue:219/255.0 alpha:1.0] ofMenu:[menuItems objectAtIndex:2]];
    }
    
    CGRect newFrame = sender.frame;
    
    newFrame = CGRectMake(sender.frame.origin.x, sender.frame.origin.y+sender.frame.size.height+15, sender.frame.size.width, sender.frame.size.height);
    
    [KxMenu showMenuInView:self.view
                  fromRect:newFrame
                 menuItems:menuItems];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
