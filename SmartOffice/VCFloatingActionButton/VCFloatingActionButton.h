//
//  VCFloatingActionButton.h
//  starttrial
//
//  Created by Giridhar on 25/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "Constants.h"

@protocol VCFloatingDelegate;
@protocol VCFloatingActionButton;

@protocol VCFloatingDelegate <NSObject>

@optional

-(void)didremove:(BOOL)isRemove;

@end

@interface VCFloatingActionButton : UIView <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic)id<VCFloatingDelegate> delegate;
@property (nonatomic) BOOL hideWhileScrolling;
@property UIView       *buttonView;
@property (strong,nonatomic) UIView *bgView;
@property (strong,nonatomic) UIScrollView *bgScroller;
@property (strong,nonatomic) UIImageView *normalImageView,*pressedImageView;
@property (strong,nonatomic) UIWindow *mainWindow;
@property (strong,nonatomic) UIImage *pressedImage, *normalImage;
@property (strong,nonatomic) NSDictionary *menuItemSet;
@property UIView *windowView;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)passiveImage andPressedImage:(UIImage*)activeImage withScrollview:(UIScrollView*)scrView;


@end
