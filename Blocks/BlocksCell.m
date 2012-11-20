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
    CATextLayer* _textLayer;
    
}

- (id)init
{
    self = [super init];
    
    if (self) {
        //Set Label
        
        _textLayer = [CATextLayer layer];
        _textLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        _textLayer.font = CGFontCreateWithFontName(CFSTR("HelveticaNeue-Bold"));
        _textLayer.fontSize = 14;
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.wrapped = YES;
        _textLayer.frame = self.frame;
        _textLayer.contentsScale = [[UIScreen mainScreen] scale];
        //[self addSublayer:_textLayer];
    
        self.backgroundColor = [[UIColor blueColor] CGColor];
        
        //Set Layer Properties
        
        self.opacity = 0.8;
        
        self.shadowOpacity = 0.6;
        self.borderColor = [[UIColor blackColor] CGColor];
        self.shadowOffset = CGSizeMake(2, 3);
        self.shadowRadius = 3;
        self.cornerRadius = 5;
        self.rasterizationScale = [[UIScreen mainScreen] scale];
        self.shouldRasterize = YES;
        
    }
    return self;
}


/*-(void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        
    }
    
    CGPoint translate = [sender translationInView:self];
    CGRect newFrame = sender.view.frame;
    newFrame.origin.x += translate.x;
    newFrame.origin.y += translate.y;
    
    sender.view.frame = newFrame;
    [sender setTranslation:CGPointMake(0, 0) inView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Moved: %@",_block.text);
        _block.x = sender.view.frame.origin.x;
        _block.y = sender.view.frame.origin.y;
    }
}
*/

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
