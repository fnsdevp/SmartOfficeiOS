//
//  arrowVw.h
//  SmartOffice
//
//  Created by FNSPL on 19/03/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol arrowVwDelegate;
@class arrowVw;

@protocol arrowVwDelegate <NSObject>

@optional

-(void)arrowVw:(arrowVw *)obj isChangeState:(NSString *)state;

-(void)arrowVw:(arrowVw *)obj didTapOnUp:(BOOL)isTap;
-(void)arrowVw:(arrowVw *)obj didTapOnDown:(BOOL)isTap;

@end

IB_DESIGNABLE

@interface arrowVw : UIView

@property (nonatomic)id<arrowVwDelegate> delegate;

@property NSString *state;
@property (nonatomic, strong) IBOutlet IBInspectable UIImageView *imgUp;
@property (nonatomic, strong) IBOutlet IBInspectable UIImageView *imgDown;
@property (nonatomic, strong) IBOutlet IBInspectable UIButton *btnUp;
@property (nonatomic, strong) IBOutlet IBInspectable UIButton *btnDown;

@end
