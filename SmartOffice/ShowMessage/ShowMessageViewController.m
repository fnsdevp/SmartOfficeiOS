//
//  ShowMessageViewController.m
//  SmartOffice
//
//  Created by FNSPL on 17/04/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ShowMessageViewController.h"

@interface ShowMessageViewController ()

@end

@implementation ShowMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    _lblname.text = [NSString stringWithFormat:@"Name : %@",_nameStr];
    _lblemail.text = [NSString stringWithFormat:@"Email : %@",_emailStr];
    _lblPhone.text = [NSString stringWithFormat:@"Phone : %@",_phoneStr];
    _lblTitle.text =  [NSString stringWithFormat:@"Title : %@",_titleStr];
    _txtMessage.text = _messageStr;
    
    [self updateStatus];
    
}


- (IBAction)btnCancelDidTap:(id)sender {
    
    [self.delegate ShowMessageViewController:self didremove:YES relodeNeeded:NO];
}


- (IBAction)btnCrossDidTap:(id)sender {
    
    [self.delegate ShowMessageViewController:self didremove:YES relodeNeeded:NO];
}


-(void)updateStatus
{
    [SVProgressHUD show];
    
    NSDictionary *params = @{@"userid":userId,@"id":self.msgID,@"status":@"read"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@set_read.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSString *success = [dict objectForKey:@"status"];
        
        if ([success isEqualToString:@"success"]) {
            
            [SVProgressHUD dismiss];
            
        }else{
            
            NSLog(@"Error updating status");
            
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
