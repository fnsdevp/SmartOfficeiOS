//
//  NotificationsViewController.m
//  SmartOffice
//
//  Created by FNSPL on 05/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationsTableViewCell.h"

@interface NotificationsViewController (){
    
    UIView *view;
}

@end


@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    db = [Database sharedDB];
    
    self.tableViewNotification.tableFooterView = [UIView new];
    
    arrayNotif = [db getNotifications];
    
    NSLog(@"%@",arrayNotif);
    
    //arrayNotif = [self getSortedArrayofArray:arrayNotif];
}

//-(NSMutableArray *)getSortedArrayofArray:(NSMutableArray *)myArray
//{
//    [myArray sortUsingSelector:@selector(compare:options:)];
//    
//    NSString *temp;
//    int i,j;
//    
//    i=0;
//    
//    j=(int)[myArray count];
//    
//    for(i=0;i<([myArray count]-1);i++)
//    {
//        temp=[myArray objectAtIndex:i];
//        [myArray replaceObjectAtIndex:i withObject:[myArray objectAtIndex:j]];
//        [myArray replaceObjectAtIndex:j withObject:temp];
//        
//        j--;
//    }
//    
//    NSLog(@"New array is:%@",myArray);
//    
//    return myArray;
//}

-(void)viewWillAppear:(BOOL)animated{
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, view.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    NSString *blueText = @"Notifications";
    //NSString *whiteText = @"Meetings";
    NSString *text = [NSString stringWithFormat:@"%@",
                      blueText];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: label.font
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    
    UIColor *blueColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    NSRange blueTextRange = [text rangeOfString:blueText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    
    [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor}
                            range:blueTextRange];
    
    label.attributedText = attributedText;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    [view addSubview:label];
    
    [self.navigationController.navigationBar addSubview:view];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [view removeFromSuperview];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [arrayNotif count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 101;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"NotificationsTableViewCell";
    
    NotificationsTableViewCell *cell = (NotificationsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationsTableViewCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titlelbl.text = @"Notification";
    cell.detailslbl.text = [[arrayNotif objectAtIndex:indexPath.row] objectForKey:@"details"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationsTableViewCell *cell = (NotificationsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.titlelbl.text = @"Notification";
    cell.detailslbl.text = [[arrayNotif objectAtIndex:indexPath.row] objectForKey:@"details"];
    
    popper = [[Popup alloc] initWithTitle:cell.titlelbl.text subTitle:cell.detailslbl.text cancelTitle:@"CANCEL" successTitle:nil];
    
    hasRoundedCorners = YES;
    
    [popper setDelegate:self];
    [popper setBackgroundBlurType:blurType];
    [popper setIncomingTransition:incomingType];
    [popper setOutgoingTransition:outgoingType];
    [popper setRoundedCorners:hasRoundedCorners];
    [popper showPopup];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *index = [[arrayNotif objectAtIndex:indexPath.row] objectForKey:@"notificationid"];
        
        [db deleteNotificationwithID:[NSString stringWithFormat:@"%@",index]];
        
        arrayNotif = [db getNotifications];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
        
    }
}

- (IBAction)clearAll:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Do you want to clear all notifications?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [db deleteAllNotifications];
        
        arrayNotif = [db getNotifications];
        
        [self.tableViewNotification reloadData];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)btnDrawerMenuDidTap:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
    
}

- (void)popupWillAppear:(Popup *)popup {
}

- (void)popupDidAppear:(Popup *)popup {
}

- (void)popupWilldisappear:(Popup *)popup buttonType:(PopupButtonType)buttonType {
}

- (void)popupDidDisappear:(Popup *)popup buttonType:(PopupButtonType)buttonType {
}

- (void)popupPressButton:(Popup *)popup buttonType:(PopupButtonType)buttonType {
    
    if (buttonType == PopupButtonCancel) {
        NSLog(@"popupPressButton - PopupButtonCancel");
    }
    else if (buttonType == PopupButtonSuccess) {
        NSLog(@"popupPressButton - PopupButtonSuccess");
    }
    
}

- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray {
    
    NSLog(@"Dictionary from textfields: %@", dictionary);
    NSLog(@"Array from textfields: %@", stringArray);
    
    //NSString *textFromBox1 = [stringArray objectAtIndex:0];
    //NSString *textFromBox2 = [stringArray objectAtIndex:1];
    //NSString *textFromBox3 = [stringArray objectAtIndex:2];
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
