//
//  arrowVw.m
//  SmartOffice
//
//  Created by FNSPL on 19/03/17.
//  Copyright © 2017 FNSPL. All rights reserved.
//

#import "arrowVw.h"

@implementation arrowVw

-(arrowVw *) init{
    
    arrowVw *result = nil;
    
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
   
    self.backgroundColor = [UIColor redColor];
}

-(IBAction)btnUpPressed:(UIButton *)sender
{
    [self.delegate arrowVw:self didTapOnUp:YES];
}

-(IBAction)btnDownPressed:(UIButton *)sender
{
    [self.delegate arrowVw:self didTapOnDown:YES];
}

@end
