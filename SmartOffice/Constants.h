//
//  Constants.h
//  SmartOffice
//
//  Created by FNSPL on 12/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define allTrim(string) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

//#define APPDELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]

#define Userdefaults  [NSUserDefaults standardUserDefaults]



//#define BASE_URL @"http://eegrab.com/ezapp/"      //distribution


#define BASE_URL @"http://eegrab.com/ezapp/beta/"   //development


#define API_KEY @"AIzaSyAiijckXY2p5AnVAg2nU4w1VPyobVQGBaY"

#define CMX_URL_LOCAL @"https://192.168.1.11/"

#define CMX_URL_GLOBAL @"https://223.30.206.130/"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREENWIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREENHEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#endif /* Constants_h */
