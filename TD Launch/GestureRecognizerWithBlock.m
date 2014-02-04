//
//  GestureRecognizerWithBlock.m
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import "GestureRecognizerWithBlock.h"

@implementation GestureRecognizerWithBlock

- (id) initWithRecognizer:(UIGestureRecognizer *)recognizer block:(void (^)(UIGestureRecognizer *, CCNode *))block
{
    if (self = [super initWithRecognizerTargetAction:recognizer target:nil action:nil])
    {
        _block = block;
    }
    return self;
}


+ (id) recognizer:(UIGestureRecognizer *)recognizer block:(void (^)(UIGestureRecognizer *, CCNode *))block
{
    return [[GestureRecognizerWithBlock alloc] initWithRecognizer:recognizer block:block];
}


- (void)callback:(UIGestureRecognizer*)recognizer
{
    if (_block != nil)
        _block(recognizer, node_);
    
    else if (target_ != nil && callback_ != nil)
        [super callback:recognizer];
}

@end
