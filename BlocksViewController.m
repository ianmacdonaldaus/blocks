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
const float CELL_WIDTH_MINIMUM = 50.0f;

//const float SCROLLVIEW_WIDTH = 3000.0f;


@interface BlocksViewController () {
    NSMutableArray* _blocksArray;
    NSMutableArray* _blocksCellsArray;
    NSMutableArray* _arrayOfCenterPoints;
    UITextField* _frameTextField;
    UIScrollView* _mainView;
    UIView* _deleteBox;
    CAGradientLayer* _completedGradient;
    CGSize _mainViewContentSize;
    float _durationScale;
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

- (id)init
{
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    //Create a Scrollview
    _mainView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mainView.autoresizesSubviews = YES;
    _mainView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_mainView];
    _mainView.scrollEnabled = YES;
    
    // Position Scroll View
    _mainViewContentSize = CGSizeMake(3000.0f, _mainView.frame.size.height);
    _mainView.contentSize = _mainViewContentSize;
    _mainView.contentOffset = CGPointMake(_mainView.contentSize.width - _mainView.frame.size.width, 0);
    
    //Add Background
    /*UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subtle-pattern-2.jpg"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mainView addSubview:imageView];
    */
    [self drawCompletionSegment];
    [self drawDeleteBox];
    [_mainView.layer insertSublayer:_completedGradient atIndex:0];
    
    _blocksArray = [[NSMutableArray alloc] init];
    _blocksCellsArray = [[NSMutableArray alloc] init];
    
    [self setupDataModel];
 

 
    //DIAGNOSTICS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
    
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
}

-(void) viewDidAppear:(BOOL)animated {
    [self setupBlocksCells];
    [self updateDisplayLayout];
    
     //DIAGNOSTICS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    _frameTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 200, 20)];
    _frameTextField.text = NSStringFromCGSize(self.view.frame.size);
    [_mainView addSubview:_frameTextField];
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
        
        [_mainView addSubview:cell];
        
    }
}

-(void) updateDisplayLayout {
   
    [self UpdateScrollViewContent];
    
    [UIView animateWithDuration:0.2 animations:^{
      
        //Set up layout helper measures
        //float totalDuration = [self getTotalDuration];
        float mininumDuration = [self getMinimumDuration];
        mininumDuration = mininumDuration + 0;
        _durationScale = CELL_WIDTH_MINIMUM / mininumDuration;
      
        // xOffset counts up for each block size and positioned back the completion line
        // yOffset counts down for each cell
        float xOffset = 0;
        float yOffset = CELL_HEIGHT * _blocksCellsArray.count;
        NSEnumerator *enumerator = [_blocksCellsArray reverseObjectEnumerator];
         for (BlocksCell* cell in enumerator) {
            Block *block = cell.block;
            float blockWidth = _durationScale * block.durationLength;
            CGRect cellFrame = CGRectMake(_mainView.contentSize.width - DISPLAY_MARGIN - blockWidth - xOffset, DISPLAY_MARGIN + yOffset, blockWidth, CELL_HEIGHT);
            
            cell.frame = cellFrame;
            block.x = DISPLAY_MARGIN + xOffset;
            block.y = DISPLAY_MARGIN + yOffset;
            cell.block = block;                       //allocate Block to cell.block
            xOffset += blockWidth;
            yOffset -= CELL_HEIGHT;
           cell.backgroundColor = [self colorForIndex:[_blocksCellsArray indexOfObject:cell]];
         }
    } completion:^(BOOL finished) {
        
    }];
    }

-(void)UpdateScrollViewContent {
    float _mainViewContentWidth = MAX((_durationScale *[self getTotalDuration]) + DISPLAY_MARGIN, _mainView.frame.size.width);
    _mainViewContentSize = CGSizeMake(_mainViewContentWidth, _mainViewContentSize.height);
    _mainView.contentSize = _mainViewContentSize;
    _mainView.contentOffset = CGPointMake(_mainViewContentSize.width - _mainView.frame.size.width, 0);
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
    _completedGradient = [CAGradientLayer layer];
    _completedGradient.frame = CGRectMake(_mainView.contentSize.width - DISPLAY_MARGIN, 0, self.view.frame.size.width, _mainView.frame.size.height);
    _completedGradient.colors = @[
    (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor],
    (id)[[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor],
    (id)[[UIColor colorWithWhite:0.0f alpha:0.3f] CGColor]];
    _completedGradient.locations = @[@0.00f, @0.05f, @0.5f];
    _completedGradient.startPoint = CGPointMake(0.0, 0.5);
    _completedGradient.endPoint = CGPointMake(1.0, 0.5);
}

const float DELETE_BOX_WIDTH = 600;
const float DELETE_BOX_HEIGHT = 100;

-(void)drawDeleteBox {
    _deleteBox = [[UIView alloc] initWithFrame:CGRectMake((_mainView.frame.size.width - DELETE_BOX_WIDTH-DISPLAY_MARGIN)/2, _mainView.frame.size.height - DISPLAY_MARGIN - DELETE_BOX_HEIGHT, DELETE_BOX_WIDTH, DELETE_BOX_HEIGHT)];
    //view.backgroundColor = [UIColor blackColor];
    //view.layer.shadowOpacity = 0.5;
    
    
    _deleteBox.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 600, 100)];
    label.text = @"DRAG HERE TO DELETE";
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:42];
    label.textColor = [UIColor blackColor];
    label.alpha = 0.5;
    label.backgroundColor = [UIColor clearColor];
    label.shadowColor = [UIColor darkGrayColor];
    [_deleteBox addSubview:label];
    
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, _deleteBox.frame.size.width, _deleteBox.frame.size.height);

    layer.colors = @[
        (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor],
        (id)[[UIColor colorWithWhite:0.0f alpha:0.5f] CGColor],
        (id)[[UIColor colorWithWhite:0.0f alpha:0.3f] CGColor]];
    
    layer.locations = @[@0.0f, @0.01f, @0.03f];
    layer.startPoint = CGPointMake(0.0, 0.5);
    layer.endPoint = CGPointMake(1.0, 0.5);
    [_deleteBox.layer insertSublayer:layer atIndex:0];
    
    [self.view addSubview:_deleteBox];
}

#pragma mark -
#pragma mark Data Model methods

- (NSMutableArray*) getArrayOfBlockCells {
    NSMutableArray* arrayOfBlockCells = [[NSMutableArray alloc] init];
    for (UIView* view in _mainView.subviews) {
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
    
    [_mainView addSubview:blocksCell];
    [self updateDisplayLayout];
}

- (void)itemAddedAtIndex:(NSInteger)index {
    
}


-(NSInteger)getTotalDuration
{
    float totalDuration = 0;
    for (Block *block in _blocksArray) {
        totalDuration += block.durationLength;
    }
    return totalDuration;
}

-(NSInteger)getMinimumDuration
{
    float minimumDuration = INFINITY;
    for (Block *block in _blocksArray) {
        minimumDuration = (block.durationLength < minimumDuration) ? block.durationLength : minimumDuration;
    }
    return minimumDuration;
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
  
    BlocksCell* selectedCell = (BlocksCell*)[sender view];
    Block* block = selectedCell.block;

    if (sender.state == UIGestureRecognizerStateBegan) {
        [self arrayOfCenterPoints];
        
        //NOT WORKING  NEED A WAY TO RESIGN FIRST RESPONDER ON DRAG[self resignFirstResponder];
    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translate = [sender translationInView:_mainView];
        CGRect newFrame = sender.view.frame;
        newFrame.origin.x += translate.x;
        newFrame.origin.y += translate.y;
        
        sender.view.frame = newFrame;
        [sender setTranslation:CGPointMake(0, 0) inView:sender.view];
        
        // ACTION - need to bring sender.view above other cells
        
        for (BlocksCell *cell in _blocksCellsArray) {
            if (cell != selectedCell && CGRectContainsPoint(cell.frame, newFrame.origin)) {
                NSLog(@"hit %@ , %@",NSStringFromCGRect(cell.frame),NSStringFromCGPoint(newFrame.origin));
            }
        }
        
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
        
        if (CGRectContainsPoint(_deleteBox.frame, sender.view.center)) {
                [self deleteBlock:block];
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

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _frameTextField.text = NSStringFromCGSize(_mainView.frame.size);
    _mainView.contentSize = _mainViewContentSize;
    _mainView.contentOffset = CGPointMake(_mainView.contentSize.width - _mainView.frame.size.width, 0);
    [self updateDisplayLayout];
    [self drawCompletionSegment];
    
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



@end
