//
//  VCFloatingActionButton.m
//  starttrial
//
//  Created by Giridhar on 25/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import "VCFloatingActionButton.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

CGFloat animationTime = 0.55;
CGFloat rowHeight = 60.f;
NSInteger noOfRows = 0;
NSInteger tappedRow;
CGFloat previousOffset;
CGFloat buttonToScreenHeight;

@implementation VCFloatingActionButton

@synthesize windowView;

@synthesize bgScroller;

-(id)initWithFrame:(CGRect)frame normalImage:(UIImage*)passiveImage andPressedImage:(UIImage*)activeImage withScrollview:(UIScrollView*)scrView
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        windowView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        
        _mainWindow = [UIApplication sharedApplication].keyWindow;
        
        _buttonView = [[UIView alloc]initWithFrame:frame];
        _buttonView.backgroundColor = [UIColor clearColor];
        _buttonView.userInteractionEnabled = YES;
        
        buttonToScreenHeight = SCREEN_HEIGHT - CGRectGetMaxY(self.frame);
        
        previousOffset = scrView.contentOffset.y;
        
        bgScroller = scrView;
        
        _pressedImage = activeImage;
        _normalImage = passiveImage;
        
        [self setupButton];
        
    }
    
    return self;
}


-(void)setHideWhileScrolling:(BOOL)hideWhileScrolling
{
    if (bgScroller!=nil)
    {
        _hideWhileScrolling = hideWhileScrolling;
        
        if (hideWhileScrolling)
        {
            [bgScroller addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}


-(void) setupButton
{
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [self addGestureRecognizer:buttonTap];
    
    
    UITapGestureRecognizer *buttonTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    [_buttonView addGestureRecognizer:buttonTap3];
    
    
    _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    _bgView.alpha = 0;
    _bgView.userInteractionEnabled = YES;
    
    _normalImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _normalImageView.userInteractionEnabled = YES;
    _normalImageView.contentMode = UIViewContentModeScaleAspectFit;
    _normalImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _normalImageView.layer.shadowRadius = 5.f;
    _normalImageView.layer.shadowOffset = CGSizeMake(-10, -10);
    
    
    
    _pressedImageView  = [[UIImageView alloc]initWithFrame:self.bounds];
    _pressedImageView.contentMode = UIViewContentModeScaleAspectFit;
    _pressedImageView.userInteractionEnabled = YES;
    
    
    _normalImageView.image = _normalImage;
    _pressedImageView.image = _pressedImage;

    
    [_buttonView addSubview:_pressedImageView];
    [_buttonView addSubview:_normalImageView];
    
    [self addSubview:_normalImageView];
    
}


-(void)handleTap:(id)sender
{
    [self.delegate didremove:YES];
}



#pragma mark ---- Scroll animations

-(void) showMenuDuringScroll:(BOOL) shouldShow
{
    if (_hideWhileScrolling)
    {
        
        if (!shouldShow)
        {
            [UIView animateWithDuration:animationTime animations:^
             {
                 self.transform = CGAffineTransformMakeTranslation(0, buttonToScreenHeight*6);
             } completion:nil];
        }
        else
        {
            [UIView animateWithDuration:animationTime/2 animations:^
             {
                 self.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
        
    }
}



#pragma mark -- Observer for scrolling
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        
        NSLog(@"%f",bgScroller.contentOffset.y);
        
        CGFloat diff = previousOffset - bgScroller.contentOffset.y;
        
        if (ABS(diff) > 15)
        {
            if (bgScroller.contentOffset.y > 0)
            {
                [self showMenuDuringScroll:(previousOffset > bgScroller.contentOffset.y)];
                previousOffset = bgScroller.contentOffset.y;
            }
            else
            {
                [self showMenuDuringScroll:YES];
            }
            
            
        }
        
    }
}




@end
