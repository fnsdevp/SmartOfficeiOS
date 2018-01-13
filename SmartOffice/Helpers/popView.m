//
//  popView.m
//  NavigineDemo
//
//  Created by FNSPL on 08/03/17.
//  Copyright © 2017 Navigine. All rights reserved.
//

#import "popView.h"

@implementation popView

-(popView *) init{
    
    popView *result = nil;
    
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options: nil];
    
    for (id anObject in elements)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            result = anObject;
            
            break;
        }
    }
    
    return result;
}

- (void)drawRect:(CGRect)rect {
    
    self.backVw.frame = self.bounds;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake((SCREENWIDTH-180)/2, (SCREENHEIGHT-330)/2, 180, 330) style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.alpha = 1.0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView  = [self roundCornersOnTableView:self.tableView onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:7.5];
    
    [self addSubview:self.tableView];
    
    
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    
    tapPress.delaysTouchesBegan = NO;
    tapPress.cancelsTouchesInView = NO;
    
    [self.backVw addGestureRecognizer:tapPress];
    
}

- (void)tapPress:(UITapGestureRecognizer *)gesture {
    
    [self.delegate popView:self didTapOnBackground:YES];
}

-(void)ResizeandReloadViews
{
    self.tableView.frame = [self setdynamicFramewith:self.tableView.frame withHeight:([self.arrayName count]*30)];
}

-(CGRect)setdynamicFramewith:(CGRect)Frame withHeight:(float)Height
{
    CGRect PersonalFrame = Frame;
    
    
    PersonalFrame = CGRectMake(Frame.origin.x, (SCREENHEIGHT-Height)/2, Frame.size.width, Height);

    
    return PersonalFrame;
    
}

- (UITableView *)roundCornersOnTableView:(UITableView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius
{
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0;
        if (tl) corner = corner | UIRectCornerTopLeft;
        if (tr) corner = corner | UIRectCornerTopRight;
        if (bl) corner = corner | UIRectCornerBottomLeft;
        if (br) corner = corner | UIRectCornerBottomRight;
        
        UITableView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        
        return roundedView;
    }
    
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.arrayName count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.arrayName objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Destination Selected : %@",[self.arrayName objectAtIndex:indexPath.row]);
    
    Row = (int)indexPath.row;
    
    [self.delegate popView:self didTapOnCell:YES onIndex:Row];
    
}


@end
