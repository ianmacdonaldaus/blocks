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
const float CELL_HEIGHT_MINIMUM = 60.0f;
const float CELL_WIDTH_MINIMUM = 50.0f;

@interface BlocksViewController () {
    NSMutableArray* _blocksArray;
    NSMutableArray* _blocksCellsArray;
    NSMutableArray* _arrayOfCenterPoints;

    UIView* _mainView;
    float _durationScale;
    BOOL _layoutForwards;
}

@end

@implementation BlocksViewController

- (id)init
{
    self = [super init];
    return self;
}

#pragma mark -
#pragma mark Setup methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //Setup Arrays and data
    _blocksArray = [[NSMutableArray alloc] init];
    _blocksCellsArray = [[NSMutableArray alloc] init];
    [self setupDataModel];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 10,1000,700)];
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _mainView.layer.shadowOpacity = 0.5;
    _mainView.layer.shadowRadius = 6;
    _mainView.layer.shadowOffset= CGSizeMake(10, 10);
    _mainView.layer.cornerRadius = 6;
    _mainView.layer.borderWidth = 1;
    
    [self.view addSubview:_mainView];
    
    //DIAGNOSTICS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
       
    [UIView animateWithDuration:0.2 animations:^{
      
        //Set up layout helper measures
        float totalDuration = [self getTotalDuration];
        float mainViewWidth = _mainView.frame.size.width;
        float mainViewHeight = _mainView.frame.size.height;
        float durationScale = mainViewWidth / totalDuration;
        // xOffset counts up for each block size and positioned back the completion line
        // yOffset counts down for each cell
        float xOffset = 0;
        float yOffset = CELL_HEIGHT * _blocksCellsArray.count;
        NSEnumerator *enumerator = [_blocksCellsArray reverseObjectEnumerator];
         for (BlocksCell* cell in enumerator) {
            Block *block = cell.block;
            float blockWidth = durationScale * block.durationLength;
            CGRect cellFrame = CGRectMake(_mainView.frame.size.width - blockWidth - xOffset, yOffset, blockWidth, CELL_HEIGHT);
            
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




#pragma mark -
#pragma mark Display Layout methods


- (UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = _blocksArray.count - 1;
    float val = ((float)index / (float)itemCount) * 1;
    return [UIColor colorWithRed:val green:0.5*(1-val) blue:0.0 alpha:1.0];
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
        
        //if (CGRectContainsPoint(_deleteBox.frame, sender.view.center)) {
        //       [self deleteBlock:block];
        //}
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
    [self updateDisplayLayout];
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

-(CGPoint)cellPositionForIndex:(NSInteger)index withDuration:(float)duration withTime:(float)time
{
    CGPoint cellPosition = CGPointZero;
    
    float mainViewWidth = _mainView.frame.size.width;
    float mainViewHeight = _mainView.frame.size.height;

    //Determine X position
    float totalHorizontal = [self getTotalDuration];                //Replace with a local variable to remove calculation
    float horizontalScale = mainViewWidth / totalHorizontal;
    float cellWidth = MAX(CELL_WIDTH_MINIMUM,duration * horizontalScale);

    //Determine Y position
    float totalVertical = _blocksCellsArray.count;
    float verticalScale = mainViewHeight / totalVertical;
    float cellHeight = MIN(CELL_HEIGHT_MINIMUM, verticalScale);
    
    return cellPosition;
}

-(BOOL)

@end
