//
//  BlocksCell.m
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import "BlocksCell.h"
#import "BlocksCellLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation BlocksCell {
    Block* _block;
    //CATextLayer* _textLayer;
    
}

@synthesize completedLayer;
@synthesize _textLayer;

- (id)init
{
    self = [super init];
    
    if (self) {

        
    
        
        //SET LAYER PROPERTIES
        self.backgroundColor = [[UIColor blueColor] CGColor];
        //self.opacity = 0.8;
        self.cornerRadius = 5;
        self.rasterizationScale = [[UIScreen mainScreen] scale];
        self.shouldRasterize = YES;
        
        //SET SHADOW PROPERTIES
        //self.shadowOpacity = 0.6;
        self.borderColor = [[UIColor blackColor] CGColor];
        self.borderWidth = 1;
        self.shadowOffset = CGSizeMake(2, 3);
        self.shadowRadius = 3;
        self.masksToBounds = YES;

        //SET LABEL PROPERTIES
        _textLayer = [CATextLayer layer];
        _textLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        _textLayer.font = CGFontCreateWithFontName(CFSTR("HelveticaNeue-Bold"));
        _textLayer.fontSize = 14;
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.wrapped = YES;
        _textLayer.frame = self.frame;
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
        _textLayer.hidden = YES;
        [self addSublayer:_textLayer];

        //ADD A COMPLETED LAYER
        completedLayer = [CALayer layer];
        completedLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        completedLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        completedLayer.opacity = 0.5;
        completedLayer.hidden = YES;
        [self addSublayer:completedLayer];
        
    }
    return self;
}


- (void)layoutSublayers
{
    [super layoutSublayers];
    _textLayer.frame = self.bounds;
}

-(void)setBlock:(Block *)block {
    _block = block;
    _textLayer.string = _block.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
 
}*/

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.block.text = textField.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [self.delegate cellDidBeginEditing:self];
}

+(id)newBlockCellWithBlock:(Block *)block {
    BlocksCell* blocksCell = [[BlocksCell alloc] init];
    blocksCell.block = block;
    return blocksCell;
}

@end
