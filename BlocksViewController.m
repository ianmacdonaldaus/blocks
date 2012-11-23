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
#import "RotationView.h"
#import <QuartzCore/QuartzCore.h>

const float DISPLAY_MARGIN = 50.0f;
const float CELL_HEIGHT_MINIMUM = 60.0f;
const float CELL_WIDTH_MINIMUM = 50.0f;

@interface BlocksViewController () {
    NSMutableArray* _arrayOfBlocks;
    NSMutableArray* _arrayOfBlocksCells;
    NSMutableArray* _arrayOfCenterPoints;
    BlocksCell* _selectedCell;
    CGPoint _translatePoint;

    UIView* _mainView;
    float _durationScale;
    BOOL _layoutForwards;
    
    CALayer *_cellMarginLine;
    
    UIView *_rotationView;
    RotationView *_circleView;
    
    @private CGFloat imageAngle;
    @private OneFingerRotationGestureRecognizer *oneFingerGestureRecognizer;
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
    _arrayOfBlocks = [[NSMutableArray alloc] init];
    _arrayOfBlocksCells = [[NSMutableArray alloc] init];
    [self setupDataModel];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(20, 20,964,700)];
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.layer.shadowOpacity = 0.5;
    _mainView.layer.shadowRadius = 6;
    _mainView.layer.shadowOffset= CGSizeMake(10, 10);
    _mainView.layer.cornerRadius = 6;

    // ADD A BORDER LAYER
    CALayer* borderLayer = [CALayer layer];
    borderLayer.frame = _mainView.bounds;
    borderLayer.borderColor = [[UIColor darkGrayColor] CGColor];
    borderLayer.borderWidth = 1;
    [_mainView.layer addSublayer:borderLayer];

    [self.view addSubview:_mainView];

    //ADD GESTURE RECOGNIZERS
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_mainView addGestureRecognizer:panGestureRecognizer];
    
    UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [_mainView addGestureRecognizer:longPressGestureRecognizer];
    
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 2.0f;
    [_mainView addGestureRecognizer:tapGestureRecognizer];
    
    //ADD MARGIN LINE
    _cellMarginLine = [CALayer layer];
    _cellMarginLine.frame = CGRectMake(0,0,1,_mainView.frame.size.height);
    _cellMarginLine.borderWidth = 1;
    _cellMarginLine.borderColor = [[UIColor lightGrayColor] CGColor];
    _cellMarginLine.backgroundColor = [[UIColor whiteColor] CGColor];
    _cellMarginLine.shouldRasterize = YES;
    _cellMarginLine.rasterizationScale = [[UIScreen mainScreen] scale];
    //[_mainView.layer addSublayer:_cellMarginLine];
    
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
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Cut Proscuitto into strips"]];
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Cook Garlic, Chillies and Capers"]];
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Boil Pasta"]];
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Add Proscuitto to the pan"]];
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Add Cooked pasta"]];
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Mix in Lime juice and pasta"]];
    [_arrayOfBlocks addObject:[Block newBlockWithText:@"Serve!"]];
    _arrayOfCenterPoints = [[NSMutableArray alloc] init];
}

-(void) setupBlocksCells {
    for (Block* block  in _arrayOfBlocks) {
        BlocksCell* cell = [[BlocksCell alloc] init];       //Create a BlocksCell for every Block
        [_arrayOfBlocksCells addObject:cell];               //Create array of BlocksCell
        cell.block = block;                                 //link Cell to Block
        [_mainView.layer addSublayer:cell];                 //Add BlocksCell sublayer to _mainview
    }
}


-(void) updateDisplayLayout {
    for(BlocksCell* cell in _arrayOfBlocksCells) {
        CGPoint newPoint = [self returnBlocksCellPosition:cell];
        cell.bounds = CGRectMake(0, 0, cell.block.durationLength * durationScale, CELL_HEIGHT_MINIMUM);
        cell.position = newPoint;
        cell.backgroundColor = [[self colorForIndex:[_arrayOfBlocksCells indexOfObject:cell]] CGColor];

    }
}

-(void) updateDisplayLayoutWithTempIndex:(int)newTempIndex {
    int i=0;

    int oldIndex = [_arrayOfBlocksCells indexOfObject:_selectedCell];
    if (newTempIndex == oldIndex) {
        return;
    }
    
    for(BlocksCell* cell in _arrayOfBlocksCells) {
        
        if ((i == oldIndex) || (i < oldIndex && i < newTempIndex) ||  (i > oldIndex && i >  newTempIndex)) {
            //Do Nothing
        } else {
            if (newTempIndex > oldIndex) {
                CGPoint newPoint = [self returnBlocksCellPosition:cell];
                        newPoint.x = newPoint.x + _selectedCell.bounds.size.width;
                        newPoint.y = newPoint.y + _selectedCell.bounds.size.height;
                cell.bounds = CGRectMake(0, 0, cell.block.durationLength * durationScale, CELL_HEIGHT_MINIMUM);
                cell.position = newPoint;
                
            } else {
                CGPoint newPoint = [self returnBlocksCellPosition:cell];
                        newPoint.x = newPoint.x - _selectedCell.bounds.size.width;
                        newPoint.y = newPoint.y - _selectedCell.bounds.size.height;
                cell.bounds = CGRectMake(0, 0, cell.block.durationLength * durationScale, CELL_HEIGHT_MINIMUM);
                cell.position = newPoint;
        }
        }
        i += 1;
    }
}

float const durationScale = 5;

-(CGPoint) returnBlocksCellPosition:(BlocksCell*)blocksCell {
    
    //get total duration of previous BlocksCells
    float totalDurationOfPreviousBlocksCells = 0;
    BlocksCell* cell;
    for (int i=0; i<[_arrayOfBlocksCells indexOfObject:blocksCell]; i++) {
        cell = _arrayOfBlocksCells[i];
        totalDurationOfPreviousBlocksCells += cell.block.durationLength;
    }
    
    float timePlotWidth = _mainView.frame.size.width;
    float timePlotHeight = CELL_HEIGHT_MINIMUM * _arrayOfBlocksCells.count;
    
    CGPoint newPoint;
    newPoint.x = timePlotWidth - (totalDurationOfPreviousBlocksCells*durationScale) - (blocksCell.block.durationLength*durationScale) / 2;
    newPoint.y = timePlotHeight - CELL_HEIGHT_MINIMUM * [_arrayOfBlocksCells indexOfObject:blocksCell] - CELL_HEIGHT_MINIMUM / 2;
    
    return newPoint;
}



#pragma mark -
#pragma mark Display Layout methods


- (UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = _arrayOfBlocks.count - 1;
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


-(void) deleteBlocksCell:(BlocksCell*)cell {
    
}

- (void) deleteBlock:(Block*)block{

    for (BlocksCell* cell in _arrayOfBlocksCells) {
        if (cell.block == block){
            NSLog(@"Delete... %@",block.text);
            
/*            [UIView animateWithDuration:0.15 animations:^{
                [cell removeFromSuperview];
            } completion:^(BOOL finished) {
                [_arrayOfBlocksCells removeObject:cell];
                [_arrayOfBlocks removeObject:block];
                [self updateDisplayLayout];
            }];
            break;
        }
    }*/
        }
    }
}

- (void) addBlock {
    Block* block = [Block newBlockWithText:@"What is the task?"];
    BlocksCell* cell = [BlocksCell newBlockCellWithBlock:block];
    [_arrayOfBlocks addObject:block];
    [_arrayOfBlocksCells addObject:cell];
    [_mainView.layer addSublayer:cell];
    [self updateDisplayLayout];
}

- (void)itemAddedAtIndex:(NSInteger)index {
    
}

-(void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [_arrayOfBlocksCells objectAtIndex:from];
        //[obj retain];
        [_arrayOfBlocksCells removeObjectAtIndex:from];
        if (to >= [_arrayOfBlocksCells count]) {
            [_arrayOfBlocksCells addObject:obj];
        } else {
            [_arrayOfBlocksCells insertObject:obj atIndex:to];
        }
        //        [obj release];
    }
}

-(NSInteger)getTotalDuration
{
    float totalDuration = 0;
    for (Block *block in _arrayOfBlocks) {
        totalDuration += block.durationLength;
    }
    return totalDuration;
}

-(NSInteger)getMinimumDuration
{
    float minimumDuration = INFINITY;
    for (Block *block in _arrayOfBlocks) {
        minimumDuration = (block.durationLength < minimumDuration) ? block.durationLength : minimumDuration;
    }
    return minimumDuration;
}

// ACTION - NEED TO CHANGE THIS _ SHOULD NOT ALLOC/INIT AN EXISTING REFERENCE

- (void)arrayOfCenterPoints {
    int i= 0;
    for (Block* block in _arrayOfBlocks) {
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

- (BlocksCell*)layerAtPoint:(CGPoint)point
{
    for ( BlocksCell *layer in _arrayOfBlocksCells)
        if ( CGRectContainsPoint(layer.frame, point ) )
            return layer;
    
    return nil;
}

-(void)handlePan:(UIPanGestureRecognizer *)sender {
    _selectedCell = [self layerAtPoint:[sender locationInView:_mainView]];

    //is there a cell selected
    
    if (_selectedCell) {
        switch (sender.state) {
        
        case UIGestureRecognizerStateBegan:
            NSLog(@"started panning object: %@", _selectedCell);
            break;
        
        case UIGestureRecognizerStateChanged:
            if(_selectedCell) {
                
                _translatePoint = [sender translationInView:_mainView];
                BOOL isHorizontalSwipe = NO;
                if (fabs(_translatePoint.x) > fabs(_translatePoint.y)   ) {
                    isHorizontalSwipe = YES;
                }
                
                if (isHorizontalSwipe && _translatePoint.x > 0) {
                    //Swipe right
                    NSLog(@"Swipe right");
                    if (_translatePoint.x > _selectedCell.frame.size.width / 2) {
                        _selectedCell.completedLayer.frame = _selectedCell.bounds;
                        _selectedCell.completedLayer.hidden = NO;
                        _selectedCell.textLayer.hidden = NO;
                        //_selectedCell._textLayer.frame.size.width = _selectedCell.frame.size.width *  (_translatePoint.x  / _selectedCell.frame.size.width);
                    }
                
                } else if (isHorizontalSwipe && _translatePoint.x < 0) {
                    //Swipe left
                    NSLog(@"Swipe left");
                    if(fabs(_translatePoint.x) > _selectedCell.frame.size.width) {
                        [self deleteBlock:_selectedCell.block];
                    }
                
                }
                
                else if (!isHorizontalSwipe && _translatePoint.y > 0) {
                    //swipe down
                    NSLog(@"Swipe down");
                
                } else if (!isHorizontalSwipe && _translatePoint.y < 0) {
                    //swipe up
                    NSLog(@"Swipe up");
                
                }
                
            }
            break;
        
        case UIGestureRecognizerStateEnded:
            _selectedCell = nil;
            break;
        
        default:
            break;
        }
        }
}

    
-(void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _selectedCell = [self layerAtPoint:[sender locationInView:_mainView]];
        _selectedCell.transform = CATransform3DMakeScale(1.2f, 1.2f, 1.0f);
        CGSize shadowOffset = _selectedCell.shadowOffset;
        _selectedCell.shadowOffset = shadowOffset;
        _selectedCell.shadowOffset = CGSizeMake(10, 10);
        _selectedCell.shadowOpacity = 0.4;
        //_selectedCell.shouldRasterize = NO;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            [_selectedCell removeFromSuperlayer];
            [_mainView.layer addSublayer:_selectedCell];
        [CATransaction commit];
        
        _translatePoint.x = [sender locationInView:_mainView].x - _selectedCell.position.x;
        _translatePoint.y = [sender locationInView:_mainView].y - _selectedCell.position.y;
        
    }
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint newPosition = _selectedCell.position;
        newPosition.x = [sender locationInView:_mainView].x - _translatePoint.x;
        newPosition.y = [sender locationInView:_mainView].y - _translatePoint.y;
        
        // Keep selected cell within the mainView bounds
        newPosition.x = ((newPosition.x - _selectedCell.bounds.size.width / 2) < 0) ? _selectedCell.bounds.size.width / 2 : newPosition.x;
        newPosition.x = ((newPosition.x + _selectedCell.bounds.size.width / 2) > _mainView.frame.size.width) ? _mainView.frame.size.width - _selectedCell.bounds.size.width / 2 : newPosition.x;
        newPosition.y = ((newPosition.y - _selectedCell.bounds.size.height / 2) < 0) ? _selectedCell.bounds.size.height / 2 : newPosition.y;
        newPosition.y = ((newPosition.y + _selectedCell.bounds.size.height / 2) > _mainView.frame.size.height) ? _mainView.frame.size.height - _selectedCell.bounds.size.height / 2 : newPosition.y;
        
        //Move selected cell
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _selectedCell.position = newPosition;
                _cellMarginLine.position = CGPointMake(newPosition.x, _mainView.frame.size.height/2);
            [CATransaction commit];
        
        //Test for ordering of selected cell

        int oldCellIndex;
        int intersectionCellIndex;
        bool needToUpdateLayout = NO;
        for (BlocksCell *cell in _arrayOfBlocksCells) {
            if(cell != _selectedCell)
            {
                CGRect intersectionRectConvertedFromCell = [_mainView.layer convertRect:cell.insertionRect fromLayer:cell];
                if (CGRectContainsPoint(intersectionRectConvertedFromCell,_selectedCell.position)){
                    oldCellIndex = [_arrayOfBlocksCells indexOfObject:_selectedCell];
                    intersectionCellIndex = [_arrayOfBlocksCells indexOfObject:cell];
                    NSLog(@"Intersects with %d", intersectionCellIndex);
                    needToUpdateLayout = YES;
                    break;
                }
            }
        }
        if(needToUpdateLayout) {
            [self moveObjectFromIndex:oldCellIndex toIndex:intersectionCellIndex];
            [self updateDisplayLayout];
            needToUpdateLayout = NO;
        }
    }

    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self updateDisplayLayout];
        _selectedCell.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
        _selectedCell.shadowOffset = CGSizeMake(2,3);
        _selectedCell.shadowOpacity = 0.6;
        //_selectedCell.shouldRasterize = YES;
        _selectedCell.zPosition = 0;
        _selectedCell = nil;
    }
    
}

-(void)handleTap:(UITapGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {
        _selectedCell = [self layerAtPoint:[sender locationInView:_mainView]];
        if (_selectedCell) {
            CABasicAnimation *theAnimation;
            theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            theAnimation.duration = 0.1;
            theAnimation.repeatCount = 1;
            theAnimation.autoreverses = YES;
            theAnimation.toValue = [NSNumber numberWithFloat:1.3f];
            theAnimation.delegate = self;
            [_selectedCell addAnimation:theAnimation forKey:@"theAnimation"];
            [self createRotationScreen];
        }
    }
}

-(void)createRotationScreen {
    float circleRadius = 200.0f;
    //CREATE THE CONTAINER VIEW - THIS WILL INTERCEPT ALL OTHER GESTURES WHILE ROTATING
    _rotationView = [[UIView alloc] initWithFrame:_mainView.frame];
    _rotationView.backgroundColor = [UIColor clearColor];
    
    //CREATE THE CIRCLEVIEW - THIS WILL BE ROTATED WITH THE GESTURE
    _circleView = [[RotationView alloc] initWithFrame:CGRectMake(_mainView.bounds.size.width / 2 - circleRadius / 2, 3 * _mainView.bounds.size.height / 4 - circleRadius / 2, circleRadius, circleRadius)];
    _circleView.layer.cornerRadius = circleRadius / 2;
    _circleView.backgroundColor = [UIColor clearColor];
    _circleView.opaque = NO;
    _circleView.layer.opacity = 0.5;

    //ADD THE NEW VIEWS
    [_rotationView addSubview:_circleView];
    [self.view addSubview:_rotationView];
    
    //IMPLEMENT THE GESTURE RECOGNIZER
    CGPoint midPoint = CGPointMake(_circleView.bounds.size.width/2, _circleView.bounds.size.height / 2);
    CGFloat outRadius = _circleView.frame.size.width / 2;
    
    oneFingerGestureRecognizer = [[OneFingerRotationGestureRecognizer alloc] initWithMidPoint:midPoint innerRadius:outRadius / 4 outerRadius:outRadius * 2 target:self];
    [_circleView addGestureRecognizer:oneFingerGestureRecognizer];
    
    //IMPLEMENT THE DISMISS ROTATION SCREEN GESTURE RECOGNIZER
    UITapGestureRecognizer *oneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissRotationScreen:)];
    oneTapGestureRecognizer.numberOfTapsRequired = 1;
    [_rotationView addGestureRecognizer:oneTapGestureRecognizer];
       
}

#pragma mark - CircularGestureRecognizerDelegate protocol

- (void) rotation: (CGFloat) angle
{
    // calculate rotation angle
    float newDurationLength = _selectedCell.block.durationLength * (1 + angle/360);
    _selectedCell.block.durationLength = newDurationLength;
    [CATransaction commit];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self updateDisplayLayout];
    [CATransaction commit];
    
    //_rotationText.text = [NSString stringWithFormat:@"%f",_selectedCell.bounds.size.width];
    
    
    imageAngle += angle;
    if (imageAngle > 360)
        imageAngle -= 360;
    else if (imageAngle < -360)
        imageAngle += 360;
    
    // rotate image and update text field
    _circleView.transform = CGAffineTransformMakeRotation(imageAngle *  M_PI / 180);
}

- (void) finalAngle: (CGFloat) angle
{
    // circular gesture ended, update text field
    
}

-(void)dismissRotationScreen:(UITapGestureRecognizer*)sender {
    [_rotationView removeFromSuperview];
    _selectedCell = nil;

}

#pragma mark -
#pragma mark Miscellaneous

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Diagnostics

-(void)testBlockData {
    for (Block* block in _arrayOfBlocks) {
        NSLog(@"%@, %f, %f",block.text, block.x, block.y);
    }
    [self arrayOfCenterPoints];
    NSLog(@"Total Duration: %d",[self getTotalDuration]);
    NSLog(@"array of center points: %@",_arrayOfCenterPoints);
}

@end
