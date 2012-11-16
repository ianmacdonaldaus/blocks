//
//  BlocksCell.h
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Block.h"
#import "BlocksCellLabel.h"

@interface BlocksCell : UIView <UITextFieldDelegate>

@property (nonatomic) Block* block;

+(id)newBlockCellWithBlock:(Block *)block;

@end
