//
//  DetailViewController.m
//
//  Created by Martin Juhasz on 24.06.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [NSString stringWithFormat:@"%d",(int)[[userDict objectForKey:@"id"] integerValue]];
    
    phone = @"";
    
    
    [_txtTitle setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_txtPh setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSDictionary *userDict = [Userdefaults objectForKey:@"ProfInfo"];
    
    userId = [userDict objectForKey:@"id"];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, _txtMessage.frame.size.width - 20.0, 30.0)];
    
    [placeholderLabel setText:@"Enter Message"];
    [placeholderLabel setFont:_txtMessage.font];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    
    [_txtMessage addSubview:placeholderLabel];
    
    _txtMessage.layer.borderColor = [UIColor whiteColor].CGColor;
    _txtMessage.layer.cornerRadius = 5.0;
    _txtMessage.layer.borderWidth = 1.0;
    
    _vwMessage.layer.cornerRadius = 5.0;
    
    if ([phone length]>0) {
        
        [_btnPhone setTitle:@"Change" forState:UIControlStateNormal];
        
    } else {
        
        [_btnPhone setTitle:@"Choose" forState:UIControlStateNormal];
    }
    
    if (![_txtMessage hasText]) {
        
        placeholderLabel.hidden = NO;
    }
    else
    {
        placeholderLabel.hidden = YES;
    }

    
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    
    tapPress.delaysTouchesBegan = NO;
    tapPress.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapPress];
}


- (void)tapPress:(UITapGestureRecognizer *)gesture {
    
    [self.view endEditing:YES];
}


- (IBAction)btnAddContactDidTap:(id)sender {
    
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"9.0")) {
        
        contactVC = [[ContactsTableController alloc] init];
        
        contactVC.delegate = self;
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        
        [self presentViewController:contactVC animated:NO completion:nil];
    }
    else
    {
        
        VeeContactPickerViewController* veeContactPickerViewController = [[VeeContactPickerViewController alloc] initWithDefaultConfiguration];
        veeContactPickerViewController.contactPickerDelegate = self;
        [self presentViewController:veeContactPickerViewController animated:YES completion:nil];
        
    }
    
}

-(void)ContactsTableController:(ContactsTableController *)obj getName:(NSString *)name andphNo:(CNContact *)contact
{
    NSString *phoneStr;
    
    phone = [[[contact.phoneNumbers firstObject] value] stringValue];
    
    if ([phone length] > 0) {
        
        phoneStr = phone;
    }
    
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *illegalCharacters = [digits invertedSet];
    NSArray *components = [phoneStr componentsSeparatedByCharactersInSet:illegalCharacters];
    
    phone = [components componentsJoinedByString:@""];
    
    _txtPh.text = [NSString stringWithFormat:@"%@",name];
    
    if ([phone length]>0) {
        
        [_btnPhone setTitle:@"Change" forState:UIControlStateNormal];
        
    } else {
        
        [_btnPhone setTitle:@"Choose" forState:UIControlStateNormal];
    }
    
}

-(void)ContactsTableController:(ContactsTableController *)obj getName:(NSString *)name withphNo:(NSString *)ph
{
    NSString *phoneStr;
    
    phoneStr = ph;
    
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *illegalCharacters = [digits invertedSet];
    NSArray *components = [phoneStr componentsSeparatedByCharactersInSet:illegalCharacters];
    
    phone = [components componentsJoinedByString:@""];
    
    _txtPh.text = [NSString stringWithFormat:@"%@",phone];
    
    if ([phone length]>0) {
        
        [_btnPhone setTitle:@"Change" forState:UIControlStateNormal];
        
    } else {
        
        [_btnPhone setTitle:@"Choose" forState:UIControlStateNormal];
    }
}

- (void)didSelectContact:(id<VeeContactProt>)veeContact
{
    //Do whatever you want with the selected veeContact!
    //_txtDepartmentName.text = [veeContact displayName];
    
    NSString *phoneStr = [[veeContact phoneNumbers]objectAtIndex:0];
    
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *illegalCharacters = [digits invertedSet];
    NSArray *components = [phoneStr componentsSeparatedByCharactersInSet:illegalCharacters];
    
    phone = [components componentsJoinedByString:@""];
    
    _txtPh.text = [NSString stringWithFormat:@"%@",phone];
    
    
    if ([phone length]>0) {
        
        [_btnPhone setTitle:@"Change Phone Number" forState:UIControlStateNormal];
        
    } else {
        
        [_btnPhone setTitle:@"Choose Phone Number" forState:UIControlStateNormal];
    }
    
}

- (IBAction)btnSubmitDidTap:(id)sender {
    
    if (([_txtTitle hasText]) && ([_txtMessage.text length]>0) &&(phone.length>0)) {
        
        [self createMessage];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Please enter title,message & ph no."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (IBAction)btnCancelDidTap:(id)sender {
    
    [self.delegate DetailViewController:self didremove:YES relodeNeeded:NO];
}


- (IBAction)btnCrossDidTap:(id)sender {
    
    [self.delegate DetailViewController:self didremove:YES relodeNeeded:NO];
}

-(IBAction)done:(id)sender
{
    self.view.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    
    [_txtMessage resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    
    [_txtTitle resignFirstResponder];
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    keyboardToolbar = [[UIToolbar alloc] init];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(done:)];
    
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    [keyboardToolbar sizeToFit];
    
    [_txtMessage setDelegate:self];
    
    [_txtMessage setInputAccessoryView:keyboardToolbar];

    
    return YES;
}


- (void) textViewDidChange:(UITextView *)theTextView
{
    if(![_txtMessage hasText]) {
        
        placeholderLabel.hidden = NO;
        
    } else if([_txtMessage hasText]){
        
        placeholderLabel.hidden = YES;
    }
}


- (void)textViewDidEndEditing:(UITextView *)theTextView
{
    if (![_txtMessage hasText]) {
        
         placeholderLabel.hidden = NO;
    }
    else
    {
        placeholderLabel.hidden = YES;
    }
}


-(void)createMessage
{
    [SVProgressHUD show];
    
    title = _txtTitle.text;
    
    message = _txtMessage.text;
    
    NSDictionary *params = @{@"userid":userId,@"phone":phone,@"title":title,@"message":message};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSString *host_url = [NSString stringWithFormat:@"%@createMsg.php",BASE_URL];
    
    [manager POST:host_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *dict = responseObject;
        
        NSString *success = [dict objectForKey:@"status"];
        
        NSString *msgStr = [dict objectForKey:@"message"];
        
        if ([success isEqualToString:@"success"]) {
            
            if ([msgStr isEqualToString:@"Message Sent"]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:[dict objectForKey:@"message"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                [SVProgressHUD dismiss];
                
                [self.delegate DetailViewController:self didremove:YES relodeNeeded:YES];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:[dict objectForKey:@"message"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                [SVProgressHUD dismiss];
                
            }
            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Problem to send message, please check your internet connection & restart the app."
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


@end
