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
    CATextLayer* _durationTextLayer;
}

@synthesize completedLayer;
@synthesize textLayer;
@synthesize insertionRect;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        //SET LAYER PROPERTIES
        self.backgroundColor = [[UIColor blueColor] CGColor];
        //self.opacity = 0.8;
        self.cornerRadius = 5;
        self.borderColor = [[UIColor blackColor] CGColor];
        self.borderWidth = 1;
        self.rasterizationScale = [[UIScreen mainScreen] scale];
        self.shouldRasterize = YES;
        
        //SET SHADOW PROPERTIES
        self.shadowOpacity = 0.6;
        self.shadowOffset = CGSizeMake(2, 3);
        self.shadowRadius = 3;
        self.shadowColor = [[UIColor blackColor] CGColor];
//        self.masksToBounds = YES;

        //SET MAIN LABEL PROPERTIES
        textLayer = [CATextLayer layer];
        textLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        textLayer.font = CGFontCreateWithFontName(CFSTR("HelveticaNeue-Bold"));
        textLayer.fontSize = 12;
        textLayer.alignmentMode = kCAAlignmentLeft;
        textLayer.wrapped = YES;
        textLayer.frame = self.frame;
        textLayer.contentsScale = [[UIScreen mainScreen] scale];
        textLayer.hidden = YES;
        [self addSublayer:textLayer];
        
        //SET DURATION LABEL PROPERTIES
        _durationTextLayer = [CATextLayer layer];
        _durationTextLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        _durationTextLayer.fontSize = 10;
        _durationTextLayer.font = CGFontCreateWithFontName(CFSTR("HelveticaNeue-Bold"));
        _durationTextLayer.alignmentMode = kCAAlignmentRight;
        _durationTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self addSublayer:_durationTextLayer];

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
    //PERFORMANCE?
    [super layoutSublayers];
    textLayer.frame = self.bounds;
    _durationTextLayer.frame = CGRectMake(0, self.bounds.size.height - (textLayer.fontSize) - 2, self.bounds.size.width - 3, textLayer.fontSize * 2);
    _durationTextLayer.string = [NSString stringWithFormat:@"%0.0f",self.block.durationLength];
    insertionRect = CGRectMake(self.bounds.size.width - 20, 0, 40, self.bounds.size.height * 2);
    
}

-(void)setBlock:(Block *)block {
    _block = block;
    textLayer.string = _block.text;
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
