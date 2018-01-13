//
//  HomeOptionsCollectionViewCell.h
//  SmartOffice
//
//  Created by FNSPL on 04/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//


@interface HomeOptionsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtiltle;
@property (weak, nonatomic) IBOutlet UIView *transView;

@property (weak, nonatomic) IBOutlet UIView *alertBackVw;
@property (weak, nonatomic) IBOutlet UILabel *alertlbl;

@end
