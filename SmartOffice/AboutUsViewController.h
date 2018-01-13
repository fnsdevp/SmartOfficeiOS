//
//  AboutUsViewController.h
//  SmartOffice
//
//  Created by FNSPL on 28/03/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "ViewController.h"

@class ViewController;

@interface AboutUsViewController : ViewController
{
    UIView *navView;
}

@property (weak, nonatomic) IBOutlet UITextView *aboutUsVw;

- (IBAction)btnDrawerMenuDidTap:(id)sender;

@end
