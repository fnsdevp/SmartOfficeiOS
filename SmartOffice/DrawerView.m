//
//  DrawerView.m
//  SmartOffice
//
//  Created by FNSPL on 09/01/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "DrawerView.h"

@implementation DrawerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(DrawerView *) init{
    DrawerView *result = nil;
    
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

@end
