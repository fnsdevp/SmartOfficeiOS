//
//  DrawerSegue.m
//  SmartOffice
//
//  Created by FNSPL on 09/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "DrawerSegue.h"

@implementation DrawerSegue
-(void)perform{
    
    UIViewController *splashScreen = self.sourceViewController;
    UIViewController *mainScreen = self.destinationViewController;
    
    [splashScreen.view addSubview:mainScreen.view];
    
    mainScreen.view.center = CGPointMake(mainScreen.view.center.x, mainScreen.view.center.y-600);
    
    [UIView animateWithDuration:1
                     animations:^{
                         
                         mainScreen.view.center = CGPointMake(mainScreen.view.center.x, [[UIScreen mainScreen] bounds].size.height/2);
                         
                     }
                     completion:^(BOOL finished){
                         
                         [splashScreen presentViewController:mainScreen animated:NO completion:nil];
                         
                         [[splashScreen.view.subviews lastObject] removeFromSuperview];
                     }
     ];
}

@end
