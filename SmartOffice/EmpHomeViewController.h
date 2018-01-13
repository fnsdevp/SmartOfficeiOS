//
//  EmpHomeViewController.h
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmpHomeViewController : UIViewController
- (IBAction)btnMenuDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewOptions;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewUpcoming;
@property (weak, nonatomic) IBOutlet UIView *midView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
