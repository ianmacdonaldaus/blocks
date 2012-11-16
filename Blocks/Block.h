//
//  Block.h
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Block : NSObject

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic, copy) NSString* text;
@property (nonatomic) float durationLength;

-(id)initWithText:(NSString*)text;

+(id)newBlockWithText:(NSString*)text;

@end
