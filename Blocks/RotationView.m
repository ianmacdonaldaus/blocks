//
//  RotationView.m
//  Blocks
//
//  Created by Ian MacDonald on 22/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import "RotationView.h"

@implementation RotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect holeRect = CGRectMake(self.bounds.size.width / 2 - 25, 25, 50, 50);
    
    CGContextSetFillColorWithColor( context, [UIColor grayColor].CGColor );
    CGContextFillEllipseInRect( context, rect );
    
    CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
    CGContextFillEllipseInRect( context, holeRect );
    
}

@end
