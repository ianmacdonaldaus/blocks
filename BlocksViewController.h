//
//  BlocksViewController.h
//  Blocks
//
//  Created by Ian MacDonald on 14/11/2012.
//  Copyright (c) 2012 Ian MacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlocksView.h"
#import "Block.h"
#import "OneFingerRotationGestureRecognizer.h"

@interface BlocksViewController : UIViewController <UIScrollViewDelegate, OneFingerRotationGestureRecognizerDelegate, UIGestureRecognizerDelegate>

//@property (strong, nonatomic) IBOutlet BlocksView *blocksView;


@end
