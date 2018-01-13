//
//  SVPulsingAnnotationView.h
//  NavigineDemo
//
//  Created by FNSPL on 15/03/17.
//  Copyright © 2017 Navigine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVPulsingAnnotationView : UIImageView

@property (nonatomic, strong) UIColor *annotationColor; // default is same as MKUserLocationView
@property (nonatomic, strong) UIColor *outerColor; // default is white
@property (nonatomic, strong) UIColor *pulseColor; // default is same as annotationColor
@property (nonatomic, strong) UIImage *image; // default is nil
@property (nonatomic, strong) UIImage *headingImage; // default is nil

@property (nonatomic, readwrite) float outerDotAlpha; // default is 1
@property (nonatomic, readwrite) float pulseScaleFactor; // default is 5.3
@property (nonatomic, readwrite) NSTimeInterval pulseAnimationDuration; // default is 1s
@property (nonatomic, readwrite) NSTimeInterval outerPulseAnimationDuration; // default is 3s
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulseCycles; // default is 1s

@property (nonatomic, copy) void (^willMoveToSuperviewAnimationBlock)(SVPulsingAnnotationView *view, UIView *superview); // default is pop animation

@end
