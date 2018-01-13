//
//  ProductCell.h
//  SmartOffice
//
//  Created by FNSPL on 07/08/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemlbl;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;
@property (weak, nonatomic) IBOutlet UILabel *itemCount;
    
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingImg;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadinglbl;
    
@end
