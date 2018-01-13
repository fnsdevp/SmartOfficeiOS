//
//  SplashViewController.h
//  SmartOffice
//
//  Created by FNSPL on 11/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ViewController.h"

@interface SplashViewController : ViewController<CAAnimationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLogo;

@end
