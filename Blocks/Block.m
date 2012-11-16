//
//  Block.m
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import "Block.h"

@implementation Block


-(id)initWithText:(NSString*)text {
    self = [super init];
    if (self) {
//        [self internalInitialize];
        self.text = text;
        self.x = 100.0;
        self.y = 100.0;
        //self.durationLength = 225.0;
        self.durationLength = (float)[text length];
    }
    return self;
}

/*- (void)internalInitialize
{
    // set default values for all properties
    self.x=100;
    self.y=100;
    self.durationLength = 100;
}
*/
+(id)newBlockWithText:(NSString*)text {
    return [[Block alloc] initWithText:text];
}

@end
