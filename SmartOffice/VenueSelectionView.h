//
//  VenueSelectionView.h
//  SmartOffice
//
//  Created by FNSPL on 27/02/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

@protocol VenueSelectionViewDelegate;
@class VenueSelectionView;

@protocol VenueSelectionViewDelegate <NSObject>
@required
-(void)VenueSelectionView:(VenueSelectionView*)obj didTapOnTableViewIndex:(long) index;
@end

@interface VenueSelectionView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewVenue;
@property (nonatomic)id<VenueSelectionViewDelegate> delegate;
@property (nonatomic) long index;

@end
