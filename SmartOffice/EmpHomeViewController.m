//
//  EmpHomeViewController.m
//  SmartOffice
//
//  Created by FNSPL on 24/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "EmpHomeViewController.h"
#import "HomeOptionsCollectionViewCell.h"
#import "UpcomingMeetingsCollectionViewCell.h"
#import "MessagesViewController.h"

@interface EmpHomeViewController (){
     NSArray *options;
    UIView *view;
    MessagesViewController *inbox;

}

@end

@implementation EmpHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:@"Schedule",@"title",@"MEETING",@"subtitle",@"schedule_meeting.png",@"image", nil];
    NSDictionary *dict1 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Order",@"title",@"FOOD",@"subtitle",@"food.png",@"image", nil];
    NSDictionary *dict2 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Inbox",@"title",@"MESSAGES",@"subtitle",@"inbox.png",@"image", nil];
    NSDictionary *dict3 = [[NSDictionary alloc]initWithObjectsAndKeys:@"Manage",@"title",@"MEETING",@"subtitle",@"calendar.png",@"image", nil];
    options = @[dict,dict1,dict2,dict3];
    [self.collectionViewOptions registerNib:[UINib nibWithNibName:@"HomeOptionsCollectionViewCell" bundle:[NSBundle mainBundle]]
                 forCellWithReuseIdentifier:@"HomeOptionsCollectionViewCell"];
    
    [self.collectionViewUpcoming registerNib:[UINib nibWithNibName:@"UpcomingMeetingsCollectionViewCell" bundle:[NSBundle mainBundle]]
                  forCellWithReuseIdentifier:@"UpcomingMeetingsCollectionViewCell"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 240, self.navigationController.navigationBar.frame.size.height)];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -30, 100, 100)];
    imgView.image = [UIImage imageNamed:@"logo.png"];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:imgView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.size.width-10, 0, view.frame.size.width-imgView.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    NSString *blueText = @"E";
    NSString *whiteText = @"ZAAP";
    NSString *text = [NSString stringWithFormat:@"%@ %@",
                      blueText,
                      whiteText];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: label.font
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    
    UIColor *blueColor = [UIColor colorWithRed:0/255.0 green:138/255.0 blue:210/255.0 alpha:1.0];
    NSRange blueTextRange = [text rangeOfString:blueText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    
    [attributedText setAttributes:@{NSForegroundColorAttributeName:blueColor}
                            range:blueTextRange];
    
    UIColor *whiteColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    NSRange whiteTextRange = [text rangeOfString:whiteText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    [attributedText setAttributes:@{NSForegroundColorAttributeName:whiteColor}
                            range:whiteTextRange];
    label.attributedText = attributedText;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    [view addSubview:label];
    
    [self.navigationController.navigationBar addSubview:view];
    self.pageControl.numberOfPages = 5;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [view removeFromSuperview];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == _collectionViewOptions){
        return [options count];
    }else{
        return 10;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == _collectionViewOptions){
        static NSString *identifier = @"HomeOptionsCollectionViewCell";
        
        HomeOptionsCollectionViewCell *cell = (HomeOptionsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        NSDictionary *dict = [options objectAtIndex:indexPath.row];
        cell.lblTitle.text = [dict objectForKey:@"title"];
        cell.lblSubtiltle.text = [dict objectForKey:@"subtitle"];
        cell.transView.layer.cornerRadius = 5.0;
        cell.imgView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
        
//        if([cell.lblTitle.text isEqualToString:@"Inbox"]){
//            cell.alertImage.hidden = NO;
//        }else if([cell.lblTitle.text isEqualToString:@"Manage"]){
//            cell.alertImage.hidden = YES;
//            cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, cell.imgView.frame.origin.y+10, cell.imgView.frame.size.width-30, cell.imgView.frame.size.height-30);
//            
//        }else if([cell.lblTitle.text isEqualToString:@"Order"]){
//            cell.alertImage.hidden = YES;
//            cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, 0, cell.imgView.frame.size.width+30, cell.imgView.frame.size.height+30);
//            
//        }else if([cell.lblTitle.text isEqualToString:@"Schedule"]){
//            cell.alertImage.hidden = YES;
//            cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, cell.imgView.frame.origin.y, cell.imgView.frame.size.width, cell.imgView.frame.size.height);
//            
//        }
        
        return cell;
        
    }else{
        static NSString *identifier = @"UpcomingMeetingsCollectionViewCell";
        
        UpcomingMeetingsCollectionViewCell *cell = (UpcomingMeetingsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        //        NSDictionary *dict = [options objectAtIndex:indexPath.row];
        //        cell.lblTitle.text = [dict objectForKey:@"title"];
        //        cell.lblSubtiltle.text = [dict objectForKey:@"subtitle"];
        //        cell.imgView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
        //        if([cell.lblTitle.text isEqualToString:@"Inbox"]){
        //            cell.alertImage.hidden = NO;
        //        }else if([cell.lblTitle.text isEqualToString:@"Manage"]){
        //            cell.alertImage.hidden = YES;
        //            cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, cell.imgView.frame.origin.y, cell.imgView.frame.size.width-30, cell.imgView.frame.size.height-30);
        //
        //        }else if([cell.lblTitle.text isEqualToString:@"Order"]){
        //            cell.alertImage.hidden = YES;
        //            cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, 0, cell.imgView.frame.size.width+30, cell.imgView.frame.size.height+30);
        //
        //        }else{
        //            cell.alertImage.hidden = YES;
        //            cell.imgView.frame = CGRectMake(cell.imgView.frame.origin.x, cell.imgView.frame.origin.y, cell.imgView.frame.size.width-30, cell.imgView.frame.size.height-30);
        //
        //        }
        
        
        
        return cell;
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _collectionViewUpcoming.frame.size.width;
    float currentPage = _collectionViewUpcoming.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f))
    {
        _pageControl.currentPage = currentPage + 1;
    }
    else
    {
        _pageControl.currentPage = currentPage;
    }
    
    NSLog(@"Page Number : %ld", (long)_pageControl.currentPage);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == _collectionViewOptions){
        return CGSizeMake((self.view.frame.size.width/2.25),110);
    }else{
        return CGSizeMake((self.collectionViewUpcoming.frame.size.width/2-1.5),110);
        
    }
}

- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView == _collectionViewOptions) {
        return 10.0f;
    }
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if(collectionView == _collectionViewOptions){
        return UIEdgeInsetsMake(10, 10,10,10);
        
    }
    return UIEdgeInsetsMake(0, 0,0,0);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == _collectionViewOptions){
        _collectionViewOptions.frame = CGRectMake(_collectionViewOptions.frame.origin.x, _collectionViewOptions.frame.origin.y, _collectionViewOptions.frame.size.width, _collectionViewOptions.contentSize.height);
        _midView.frame = CGRectMake(_midView.frame.origin.x, _collectionViewOptions.frame.size.height+5, _midView.frame.size.width, _midView.frame.size.height);
//        _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, _midView.frame.origin.y+_midView.frame.size.height + 8, _bottomView.frame.size.width, _bottomView.frame.size.height+5);
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _midView.frame.origin.y+_midView.frame.size.height+60);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Messages" bundle:[NSBundle mainBundle]];
    // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Messages" bundle:[NSBundle mainBundle]];
    
    switch (indexPath.row) {
        case 0:
            self.tabBarController.selectedIndex = 2;
            
            break;
        case 2:
            
            inbox = [storyboard instantiateViewControllerWithIdentifier:@"inbox"];
            [self.navigationController pushViewController:inbox animated:YES];
            break;
        case 3:
            
            self.tabBarController.selectedIndex = 1;
            
            break;
            
        default:
            break;
    }
    
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnMenuDidTap:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"OpenDrawer"
     object:self];
}
@end
