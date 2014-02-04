//
//  GestureRecognizerWithBlock.h
//  TD Launch
//
//  Created by Kent Anderson on 9/3/12.
//
//

#import "CCGestureRecognizer.h"

@interface GestureRecognizerWithBlock : CCGestureRecognizer
{
    void (^_block)(UIGestureRecognizer*, CCNode*);
}

+ (id) recognizer:(UIGestureRecognizer*)recognizer block:(void(^)(UIGestureRecognizer*,CCNode*))block;
- (id) initWithRecognizer:(UIGestureRecognizer*)recognizer block:(void(^)(UIGestureRecognizer*,CCNode*))block;
                                                          
@end
