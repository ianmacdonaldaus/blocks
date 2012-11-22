//
//  BlocksCell.h
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Block.h"
#import "BlocksCellLabel.h"

@interface BlocksCell : CALayer

@property (nonatomic) Block* block;

@property (nonatomic, retain) CALayer* selectedLayer;
@property (nonatomic, retain) CALayer* completedLayer;
@property (nonatomic, retain) CATextLayer* _textLayer;


+(id)newBlockCellWithBlock:(Block *)block;

@end
