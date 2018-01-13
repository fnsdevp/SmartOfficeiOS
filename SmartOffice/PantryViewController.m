//
//  PantryViewController.m
//  SmartOffice
//
//  Created by FNSPL on 07/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "PantryViewController.h"

@interface PantryViewController ()

@end


@implementation PantryViewController
    

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    navView = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 260, self.navigationController.navigationBar.frame.size.height)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, navView.frame.size.width - 20, self.navigationController.navigationBar.frame.size.height)];
    
    
    NSString *text = [NSString stringWithFormat:@"Pantry Management"];
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: label.font
                              };
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    [attributedText addAttribute:NSForegroundColorAttributeName
                 value:[UIColor whiteColor]
                 range:NSMakeRange(0, 6)];
    
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithHexString:@"#008AD2"]
                           range:NSMakeRange(7, 10)];
    
    label.attributedText = attributedText;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    
    [navView addSubview:label];
    
    [self.navigationController.navigationBar addSubview:navView];
    
    orderFoodImgArr = [[NSArray alloc] initWithObjects:@"coffee", @"snacks", nil];
    
    
    [self.tblPantry registerNib:[UINib nibWithNibName:@"PantryTableCell" bundle:nil] forCellReuseIdentifier:@"PantryTableCell"];
    
    [self.tblPantry registerNib:[UINib nibWithNibName:@"ProductCell" bundle:nil] forCellReuseIdentifier:@"ProductCell"];
    
    
    CALayer *bottomBorder = [CALayer layer];
    
    bottomBorder.frame = CGRectMake(0.0f, (_headingVw.frame.origin.y+_headingVw.frame.size.height) - 1.0f, SCREENWIDTH, 1.0f);
    
    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    [_headingVw.layer addSublayer:bottomBorder];
    
    self.btnOrder.layer.cornerRadius = 5.0;
    
}
    

-(void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:YES];
    
   [self getOrderManu];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [navView removeFromSuperview];
}


- (IBAction)btnDrawerMenuDidTap:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
    
}


- (IBAction)btnOrderDidTap:(id)sender
{
    if ([arrFood count]>0) {
        
        for (int i=0; i<[arrFood count]; i++) {
            
            if ([strFood length]==0) {
                
                strFood = [NSString stringWithFormat:@"%d %@",(int)[Userdefaults integerForKey:[NSString stringWithFormat:@"%@",[arrFood objectAtIndex:i]]],[arrFood objectAtIndex:i]];
                
            } else {
                
                strFood = [NSString stringWithFormat:@"%@,%d %@",strFood,(int)[Userdefaults integerForKey:[NSString stringWithFormat:@"%@",[arrFood objectAtIndex:i]]],[arrFood objectAtIndex:i]];
            }
        }
    }
    
    NSString *orderStr = strFood;
    
    if ([orderStr length]>0) {
        
        [self sendPushforOrderFood:orderStr];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please choose your order."
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}


- (IBAction)btnSelectDidTap:(UIButton *)sender
{
    TypeTag = (int)sender.tag;
    
    if(isTypeClicked)
    {
        isTypeClicked = NO;
        
        itemList = [[NSMutableArray alloc] init];
        
        [self.tblPantry reloadData];
    }
    else
    {
        isTypeClicked = YES;
        
        NSDictionary *dict1 = [orderFoodArr objectAtIndex:(int)sender.tag];
        
        itemList  = [dict1 objectForKey:@"menuitems"];
        
        arrFood = [[NSMutableArray alloc] init];
        
        [self.tblPantry reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [typeList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 100;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderCellIdentifier = @"PantryTableCell";
    
    PantryTableCell *cell = (PantryTableCell *)[tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PantryTableCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.typeIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[orderFoodImgArr objectAtIndex:section]]];
    
    cell.typelbl.text = [typeList objectAtIndex:section];
    
    cell.btnSelect.tag = section;
    
    [cell.btnSelect addTarget:self action:@selector(btnSelectDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((isTypeClicked) && (section==TypeTag)) {
        
        if ([itemList count]>0) {
            
            return [itemList count];
        }
        else
        {
            return 0;
        }
        
    } else {
        
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bodyCellIdentifier = @"ProductCell";
    
    ProductCell *cell = (ProductCell *)[tableView dequeueReusableCellWithIdentifier:bodyCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductCell" owner:self options:nil];
        
        cell = [nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.btnAdd.tag = indexPath.row;
    cell.btnDel.tag = indexPath.row;
    
    cell.itemlbl.text = [[itemList objectAtIndex:indexPath.row] objectForKey:@"item"];
    
    [cell.btnAdd addTarget:self action:@selector(btnAddDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.btnDel addTarget:self action:@selector(btnDelDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select");
}

-(IBAction)btnAddDidTap:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:TypeTag];
    
    ProductCell* cell = (ProductCell *)[self.tblPantry cellForRowAtIndexPath:indexPath];
    
    int Count = (int)[cell.itemCount.text integerValue];
    
    [arrFood removeObject:cell.itemlbl.text];
    
    Count = Count+1;
    
    cell.itemCount.text = [NSString stringWithFormat:@"%d",Count];
    
    //NSLog(@"%@",cell.itemCount.text);
    
    [arrFood addObject:cell.itemlbl.text];
    
    
    [Userdefaults setInteger:Count forKey:[NSString stringWithFormat:@"%@",cell.itemlbl.text]];
    
    [Userdefaults synchronize];
    
}
    
-(IBAction)btnDelDidTap:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:TypeTag];
    
    ProductCell* cell = (ProductCell *)[self.tblPantry cellForRowAtIndexPath:indexPath];
    
    int Count = (int)[cell.itemCount.text integerValue];
    
    [arrFood removeObject:cell.itemlbl.text];
    
    if (Count>0) {
        
        Count = Count-1;
    }
    
    cell.itemCount.text = [NSString stringWithFormat:@"%d",Count];
    
    if (Count==0) {
    
        [arrFood removeObject:cell.itemlbl.text];
        
        [Userdefaults removeObjectForKey:[NSString stringWithFormat:@"%@",cell.itemlbl.text]];
        
        [Userdefaults synchronize];
        
    }
    else
    {
        [arrFood addObject:cell.itemlbl.text];
    
        [Userdefaults setInteger:Count forKey:[NSString stringWithFormat:@"%@",cell.itemlbl.text]];
        
        [Userdefaults synchronize];
    
    }
}

-(void)getOrderManu
{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    host_url = [NSString stringWithFormat:@"http://ws.eegrab.com/category_items.php?restaurantid=178"];
    
    
    [manager GET:host_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSString *success = [dict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            typeList = [[NSMutableArray alloc] init];
            
            orderFoodArr = [dict objectForKey:@"categories"];
            
            NSLog(@"orderFoodArr: %@", orderFoodArr);
            
            for (int i=0; i<[orderFoodArr count]; i++) {
                
                NSDictionary *dict1 = [orderFoodArr objectAtIndex:i];
                
                [typeList addObject:[dict1 objectForKey:@"categoryname"]];
            }
            
            [self.tblPantry reloadData];
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


-(void)sendPushforOrderFood:(NSString *)strFoodSelected{
    
    [SVProgressHUD show];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    NSString *user = [NSString stringWithFormat:@"%@ %@",[userDict objectForKey:@"fname"],[userDict objectForKey:@"lname"]];
    
    NSString *strOrder = [NSString stringWithFormat:@"%@ has requested %@",user,strFoodSelected];
    
    NSDictionary *params = @{@"userid":@"1",@"appid":@"0",@"body":strOrder};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    host_url = [NSString stringWithFormat:@"%@customepush_guest.php",BASE_URL];
    
    //    if ([[userDict objectForKey:@""] isEqualToString:@"Guest"]) {
    //
    //        host_url = [NSString stringWithFormat:@"%@customepush_guest.php",BASE_URL];
    //    }
    //    else
    //    {
    //        host_url = [NSString stringWithFormat:@"%@customepush_employee.php",BASE_URL];
    //    }
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        strFood = @"";
        
        NSDictionary *responseDict = responseObject;
        NSString *success = [responseDict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Your order will be served shortly."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            
            [alertView show];
            
            
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
        
        strFood = @"";
        
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
