//
//  RightSideDrawerViewController.m
//  SmartOffice
//
//  Created by FNSPL on 09/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "RightSideDrawerViewController.h"

@interface RightSideDrawerViewController (){
    NSArray *options;

}

@end


@implementation RightSideDrawerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([Userdefaults objectForKey:@"ProfInfo"] !=nil) {
        
        userDict = [Userdefaults objectForKey:@"ProfInfo"];
        
        _lblUsername.text = [NSString stringWithFormat:@"You are logged in as %@ %@",[userDict objectForKey:@"fname"],[userDict objectForKey:@"lname"]];
        
        [_lblUsername sizeToFit];
        
    }
   
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"Home",@"title",@"home",@"image", nil];
    NSDictionary *dict1 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Manage Meetings",@"title",@"managemeeting",@"image", nil];
    NSDictionary *dict2 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Notification",@"title",@"warning.png",@"image", nil];
    
    NSDictionary *dict3 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Messages",@"title",@"communication_email.png",@"image", nil];
    
    NSDictionary *dict4 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Control Panel",@"title",@"Control.png",@"image", nil];
    NSDictionary *dict5 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Profile Management",@"title",@"profile_manage.png",@"image", nil];
    
    NSDictionary *dict6 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Set Availability",@"title",@"setAvailability.png",@"image", nil];
    
    NSDictionary *dict7 = [[NSDictionary alloc]initWithObjectsAndKeys:@"About Us",@"title",@"aboutUs.png",@"image", nil];
    
    NSDictionary *dict8 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Logout",@"title",@"logout.png",@"image", nil];
    
    
    NSString *userType = [userDict objectForKey:@"usertype"];
    
    if (![userType isEqualToString:@"Guest"]) {
        
        options = @[dict,dict1,dict2,dict3,dict4,dict5,dict6,dict7,dict8];
        
    }
    else
    {
        options = @[dict,dict1,dict2,dict3,dict4,dict5,dict7,dict8];
    }
    
    db = [Database sharedDB];
    
    userArr = [db getUser];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    DrawerTableViewCell *cell = (DrawerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DrawerTableViewCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    NSDictionary *dict =[options objectAtIndex:indexPath.row];
    
    cell.titlelbl.text = [dict objectForKey:@"title"];
    
    cell.icon.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict =[options objectAtIndex:indexPath.row];
    
    Index = (int)indexPath.row;
    
    NSString *strTitle = [dict objectForKey:@"title"];
    
    if ([strTitle isEqualToString:@"Notification"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    else if ([strTitle isEqualToString:@"Messages"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    else if ([strTitle isEqualToString:@"Control Panel"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    else if ([strTitle isEqualToString:@"Profile Management"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    else if ([strTitle isEqualToString:@"Set Availability"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    else if ([strTitle isEqualToString:@"About Us"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    else if ([strTitle isEqualToString:@"Logout"]) {
        
        Index = (int)(indexPath.row+1);
        
    }
    
    NSDictionary* userInfo = @{@"indexClickedOnDrawer": @(Index)};
    
    switch (Index) {
        
        case 0:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;
        case 3:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;
        case 4:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;
            
        case 5:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;
        case 6:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;

        case 7:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;
        
        case 8:
           [[NSNotificationCenter defaultCenter]
            postNotificationName:@"ClickedDrawerOption"
            object:self userInfo:userInfo];
           break;
            
        case 9:
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ClickedDrawerOption"
             object:self userInfo:userInfo];
            break;

        default:
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _tableViewMenu.frame = CGRectMake(_tableViewMenu.frame.origin.x, _tableViewMenu.frame.origin.y, _tableViewMenu.frame.size.width, _tableViewMenu.contentSize.height);
}
    

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnExitDrawerDidTap:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ExitDrawer"
     object:self];

}

@end
