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
    BlocksCellLabel* _label;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Set Label
        _label = [[BlocksCellLabel alloc] initWithFrame:CGRectNull];
        _label.textColor = [UIColor whiteColor];
        //_label.delegate = self;
        _label.font = [UIFont boldSystemFontOfSize:12];
        _label.clipsToBounds = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.scrollEnabled = NO;
        //_label.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:_label];
        
       self.backgroundColor = [UIColor whiteColor];
        
        //Set Layer
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowOffset = CGSizeMake(2, 3);
        self.layer.shadowRadius = 3;
        self.layer.cornerRadius = 4;
        
        //Gesture Recognizers
        //UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        //[self addGestureRecognizer:gestureRecognizer];
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
-(void) layoutSubviews {
    [super layoutSubviews];
    _label.frame = self.bounds;
}
-(void)setBlock:(Block *)block {
    _block = block;
    _label.text = _block.text;
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
    BlocksCell* blocksCell = [[BlocksCell alloc] initWithFrame:CGRectNull];
    blocksCell.block = block;
    return blocksCell;
}

@end
