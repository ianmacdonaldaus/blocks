//
//  BlocksViewController.m
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.


/* to do
 - need to add a rotation for horizontal
 - add a gradient to the buttons
 - need to set minimum dimensions for the blocks
 - need to bring selected block to the foreground
 - need to add a scrollview
 - need to be able to set duration
 - need to reshuffle blocks based on moves
 - need to expand in editing mode
 - need to add additional gestures (ie. delete, move, extend, etc.)
 - need to animate the text label (or not change it) until the cell has animated (ie. so that it does not overhang the cell as it lengthens its text before fitting)
 - need to look at how to format the text
 */
//  

#import "BlocksViewController.h"
#import "BlocksCell.h"
#import "Block.h"
#import <QuartzCore/QuartzCore.h>

const float DISPLAY_MARGIN = 50.0f;
const float CELL_HEIGHT = 60.0f;


@interface BlocksViewController () {
    NSMutableArray* _blocksArray;
    NSMutableArray* _blocksCellsArray;
    NSMutableArray* _arrayOfCenterPoints;
}

@end

@implementation BlocksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    //CGRect rect = self.frame;
    //Add Background
    //UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subtle-pattern-2.jpg"]];
    //imageView.layer.opacity = 1.0;
    //imageView.frame = self.view.bounds;
    //[self.view addSubview:imageView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self drawCompletionSegment];
    [self drawTempDeleteBox];  //DIAGNOSTICS
    
    //Create Diagnostics button
    UIButton* showDiagnosticsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    showDiagnosticsButton.frame = CGRectMake(0, 0, 40, 40);
    //[button setTitle:@"Diagnostics" forState:UIControlStateNormal];
    [showDiagnosticsButton addTarget:self action:@selector(testBlockData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showDiagnosticsButton];

    //Create add button
    UIButton* addObjectButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addObjectButton.frame = CGRectMake(0, 40, 40, 40);
    [addObjectButton addTarget:self action:@selector(addBlock) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addObjectButton];
    
    _blocksArray = [[NSMutableArray alloc] init];
    _blocksCellsArray = [[NSMutableArray alloc] init];
    

    [self setupDataModel];
    [self setupBlocksCells];
    [self updateDisplayLayout];
}

-(void)setupDataModel {
    //Initialise data model - Create array of objects
    [_blocksArray addObject:[Block newBlockWithText:@"Cut Proscuitto into strips"]];
    [_blocksArray addObject:[Block newBlockWithText:@"Cook Garlic, Chillies and Capers"]];
    [_blocksArray addObject:[Block newBlockWithText:@"Boil Pasta"]];
    [_blocksArray addObject:[Block newBlockWithText:@"Add Proscuitto to the pan"]];
    [_blocksArray addObject:[Block newBlockWithText:@"Add Cooked pasta"]];
    [_blocksArray addObject:[Block newBlockWithText:@"Mix in Lime juice and pasta"]];
    [_blocksArray addObject:[Block newBlockWithText:@"Serve!"]];
    _arrayOfCenterPoints = [[NSMutableArray alloc] init];
}

-(void) setupBlocksCells {
    for (Block* block  in _blocksArray) {
        BlocksCell* cell = [[BlocksCell alloc] initWithFrame:CGRectMake(0, 0, 100, CELL_HEIGHT)];
        [_blocksCellsArray addObject:cell];
        cell.block = block;
        
        UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [cell addGestureRecognizer:gestureRecognizer];
        
        [self.view addSubview:cell];
        
    }
}

-(void) updateDisplayLayout {
    

    
    [UIView animateWithDuration:0.2 animations:^{
        //Set up layout helper measures
        float displayAreaWidth = self.view.bounds.size.width - 2 * DISPLAY_MARGIN;
        float totalDuration = [self getTotalDuration];
        float blockSizeScale = displayAreaWidth/totalDuration;
        float xOffset = 0;
        float yOffset = 0;
        
        for (BlocksCell* cell in _blocksCellsArray) {
            Block *block = cell.block;
            float blockSize = blockSizeScale * block.durationLength;
            CGRect cellFrame = CGRectMake(DISPLAY_MARGIN + xOffset, DISPLAY_MARGIN + yOffset, blockSize, CELL_HEIGHT);
            cell.frame = cellFrame;
            block.x = DISPLAY_MARGIN + xOffset;
            block.y = DISPLAY_MARGIN + yOffset;
            cell.block = block;                       //allocate Block to cell.block
            xOffset += blockSize;
            yOffset += CELL_HEIGHT;
            cell.backgroundColor = [self colorForIndex:[_blocksCellsArray indexOfObject:cell]];
        }

    } completion:^(BOOL finished) {
        nil;
    }];
    }
#pragma mark -
#pragma mark Diagnostics

-(void)testBlockData {
    for (Block* block in _blocksArray) {
        NSLog(@"%@, %f, %f",block.text, block.x, block.y);
    }
    [self arrayOfCenterPoints];
    NSLog(@"Total Duration: %d",[self getTotalDuration]);
    NSLog(@"array of center points: %@",_arrayOfCenterPoints);
}


#pragma mark -
#pragma mark Display Layout methods


- (UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = _blocksArray.count - 1;
    float val = ((float)index / (float)itemCount) * 1;
    return [UIColor colorWithRed:val green:0.5*(1-val) blue:0.0 alpha:1.0];
}

-(void)drawCompletionSegment {
    //    self.view.layer
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - DISPLAY_MARGIN, 0, DISPLAY_MARGIN, self.view.bounds.size.height)];
    CAGradientLayer* layer = [CAGradientLayer layer];
    
    layer.frame = CGRectMake(0, 0, DISPLAY_MARGIN, self.view.bounds.size.height);
    //layer.backgroundColor = [[UIColor redColor] CGColor];
    layer.colors = @[
    (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor],
    (id)[[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor],
    (id)[[UIColor colorWithWhite:0.0f alpha:0.3f] CGColor]];
    layer.locations = @[@0.00f, @0.01f, @0.5f];
    layer.startPoint = CGPointMake(0.0, 0.5);
    layer.endPoint = CGPointMake(1.0, 0.5);
    [view.layer insertSublayer:layer atIndex:0];
    [self.view addSubview:view];
    //    [self.view.layer insertSublayer:layer atIndex:0];
}

-(void)drawTempDeleteBox {
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(DISPLAY_MARGIN, 750, self.view.frame.size.width - DISPLAY_MARGIN * 3, 200)];
    //view.backgroundColor = [UIColor blackColor];
    //view.layer.shadowOpacity = 0.5;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 600, 100)];
    label.text = @"DRAG HERE TO DELETE";
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:42];
    label.textColor = [UIColor blackColor];
    label.alpha = 0.5;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor darkGrayColor];
    [view addSubview:label];
    
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    //layer.backgroundColor = [[UIColor redColor] CGColor];
    layer.colors = @[
        (id)[[UIColor colorWithWhite:1.0f alpha:0.0f] CGColor],
        (id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
        (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor],
        (id)[[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor],
        (id)[[UIColor colorWithWhite:0.0f alpha:0.3f] CGColor]];
    
    layer.locations = @[@0.0f,@0.02f, @0.04f, @0.06f,@0.10f];
    
    layer.startPoint = CGPointMake(0.0, 0.5);
    layer.endPoint = CGPointMake(1.0, 0.5);
    
    [view.layer insertSublayer:layer atIndex:0];
    
    [self.view addSubview:view];
}

#pragma mark -
#pragma mark Data Model methods
- (NSMutableArray*) getArrayOfBlockCells {
    NSMutableArray* arrayOfBlockCells = [[NSMutableArray alloc] init];
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[BlocksCell class]]) {
            [arrayOfBlockCells addObject:(BlocksCell*)view];
        }
    }
    return arrayOfBlockCells;
}
- (void) deleteBlock:(Block*)block{
//    NSMutableArray = [self getArrayOfBlockCells];
    for (BlocksCell* cell in _blocksCellsArray) {
        if (cell.block == block){
            NSLog(@"%@",block.text);
            
            [UIView animateWithDuration:0.15 animations:^{
                [cell setTransform:CGAffineTransformMakeScale(0.0, 1.0)];
            } completion:^(BOOL finished) {
                [cell removeFromSuperview];
                [_blocksCellsArray removeObject:cell];
                [_blocksArray removeObject:block];
                [self updateDisplayLayout];
            }];
            break;
        }
    }

}

- (void) addBlock {
    Block* block = [Block newBlockWithText:@"What is the task?"];
    BlocksCell* blocksCell = [BlocksCell newBlockCellWithBlock:block];
    [_blocksArray addObject:block];
    [_blocksCellsArray addObject:blocksCell];
    
    UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [blocksCell addGestureRecognizer:gestureRecognizer];
    
    [self.view addSubview:blocksCell];
    [self updateDisplayLayout];
}

- (void)itemAddedAtIndex:(NSInteger)index {
    
}


-(NSInteger)getTotalDuration
{
    float _totalDuration = 0;
    for (Block *block in _blocksArray) {
        _totalDuration += block.durationLength;
    }
    return _totalDuration;
}


// ACTION - NEED TO CHANGE THIS _ SHOULD NOT ALLOC/INIT AN EXISTING REFERENCE

- (void)arrayOfCenterPoints {
    int i= 0;
    for (Block* block in _blocksArray) {
        NSValue* point = [NSValue valueWithCGPoint:CGPointMake(block.x, block.y)];
        if (i >= _arrayOfCenterPoints.count) {
            [_arrayOfCenterPoints addObject:point];
        } else {
            [_arrayOfCenterPoints replaceObjectAtIndex:i withObject:point];
        } i++;
    }
}

#pragma mark -
#pragma mark Gesture Recognizers


// NEED TO IDENTIFY WHAT CELL MATCHES THE SENDER.VIEW TO GET AND SET BLOCK INFO

-(void)handlePan:(UIPanGestureRecognizer *)sender {
  
    BlocksCell* blocksCell = (BlocksCell*)[sender view];
    Block* block = blocksCell.block;

    if (sender.state == UIGestureRecognizerStateBegan) {
        [self arrayOfCenterPoints];
        //NOT WORKING  NEED A WAY TO RESIGN FIRST RESPONDER ON DRAG[self resignFirstResponder];
    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [sender translationInView:self.view];
        CGRect newFrame = sender.view.frame;
        newFrame.origin.x += translate.x;
        newFrame.origin.y += translate.y;
        
        sender.view.frame = newFrame;
        [sender setTranslation:CGPointMake(0, 0) inView:sender.view];
        
        // ACTION - need to bring sender.view above other cells
        
       /* for (NSValue *value in [self arrayOfCenterPoints]) {
            CGPoint pt = [value CGPointValue];
            NSLog(@"%f %f",pt.x, pt.y);
            
        }*/

    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Moved: %@",block.text);
        block.x = sender.view.frame.origin.x;
        block.y = sender.view.frame.origin.y;

//        [self updateDisplayLayout];
        
        if (sender.view.frame.origin.y > 750.0f && sender.view.frame.origin.y < 950.0f && sender.view.frame.origin.x > DISPLAY_MARGIN && sender.view.frame.origin.x < (self.view.frame.size.width - DISPLAY_MARGIN * 2)) {
            {
                [self deleteBlock:block];
            }
        }
    }
}

#pragma mark -
#pragma mark Miscellaneous

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
@end
