//
//  ScrollView.h
//  TD Launch
//
//  Created by Kent Anderson on 8/25/12.
//
//


#import "cocos2d.h"
#import "Foundation/Foundation.h"

@interface ScrollView : CCNode <UIGestureRecognizerDelegate, CCTargetedTouchDelegate>
{
    bool    _debug;
    CCNode* _content;
    CCNode* _background;
    CCNode* _foreground;
    CGPoint _scrollVelocity;
    float   _xPX;
    float   _yPX;
}

@property CCNode* content;
@property CCNode* background;
@property CCNode* foreground;

@property bool inhibitPan;
@property bool clipContents;
@property float friction;

@property bool debug;

+ (id) viewWithContent:(CCNode*) content;
+ (id) viewWithContent:(CCNode *)content foreground:(CCNode*) foreground background:(CCNode*) background;

- (id) initWithContent:(CCNode*) content;

- (CGPoint) keepNodeOnScreen:(CCNode*)node;

- (CGPoint) keepNodeOnScreen:(CCNode *)node withMargin:(CGSize)margin;

- (CGPoint) keepNodeOnScreen:(CCNode*)node withMargin:(CGSize)margin positionBased:(bool) positionBased;

- (void) forwardPanEvent:(UIGestureRecognizer*)recognizer node:(CCNode*)node;

- (void) scaleContent:(float)scale focalPoint:(CGPoint)focalPoint;

@end
