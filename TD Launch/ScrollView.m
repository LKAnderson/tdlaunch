//
//  ScrollView.m
//  TD Launch
//
//  Created by Kent Anderson on 8/25/12.
//
//

//
//  ItemScroller.m
//  TD Launch
//
//  Created by Kent Anderson on 8/22/12.
//
//

#import "ScrollView.h"
#import "ColoredNode.h"


#define CAN_VSCROLL (_content.contentSize.height * _content.scale > self.contentSize.height)
#define CAN_HSCROLL (_content.contentSize.width * _content.scale > self.contentSize.width)

@implementation ScrollView


+ (id) viewWithContent:(CCNode*) content
{
    return [[ScrollView alloc] initWithContent:content];
}

+ (id) viewWithContent:(CCNode*) content foreground:(CCNode *)foreground background:(CCNode *)background
{
    ScrollView* view = [[ScrollView alloc] initWithContent:content];
    [view setForeground:foreground];
    [view setBackground:background];
    return view;
}

+ (id) node
{
    return [[ScrollView alloc] init];
}

- (id) init
{
    if ( (self = [super init]) )
    {
        _content = nil;
        _background = nil;
        _foreground = nil;

        _scrollVelocity = ccp(0,0);
        _friction = 0.1;
        _clipContents = YES;
        
        self.isTouchEnabled = YES;
        
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] init];
        pan.delegate = self;
        
        CCGestureRecognizer* recognizer = [CCGestureRecognizer
                                           CCRecognizerWithRecognizerTargetAction:pan
                                           target:self action:@selector(pan:node:)];
        [self addGestureRecognizer:recognizer];

        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        
        _xPX = [[CCDirector sharedDirector] winSizeInPixels].width / [[CCDirector sharedDirector] winSize].width;
        _yPX = [[CCDirector sharedDirector] winSizeInPixels].height / [[CCDirector sharedDirector] winSize].height;
    }
    return self;
}

- (void) onExit
{
    [_content removeAllChildrenWithCleanup:YES];
    [_background removeAllChildrenWithCleanup:YES];
    [_foreground removeAllChildrenWithCleanup:YES];
}


- (id) initWithContent:(CCNode *)content
{
    if ((self = [self init]))
    {
        [self setContent:content];
    }
    return self;
}



- (CCNode*) content
{
    return _content;
}

- (void) setContent:(CCNode *)content
{
    if (_content != nil)
        [self removeChild:_content cleanup:YES];
    _content = content;
    if (_content != nil)
        [self addChild:content z:0];
}

- (CCNode*) foreground
{
    return _foreground;
}

- (void) setForeground:(CCNode *)foreground
{
    if (_foreground != nil)
        [self removeChild:_foreground cleanup:YES];
    _foreground = foreground;
    _foreground.anchorPoint = ccp(0,0);
    _foreground.position = ccp(0,0);
    if (_foreground != nil)
        [self addChild:_foreground z:1];
}


- (CCNode*) background
{
    return _background;
}


- (void) setBackground:(CCNode *)background
{
    if (_background != nil)
        [self removeChild:_background cleanup:YES];
    _background = background;
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    if (_background != nil)
        [self addChild:_background z:-1];
}



- (void) draw
{
    [super draw];
    if (_debug)
    {
        ccDrawColor4B(0x00, 0xff, 0x00, 0xff);
        ccDrawRect(ccp(0,0), ccp(self.contentSize.width,self.contentSize.height));
    }
}



- (void) visit
{
	if (!self.visible)
		return;

    if (_clipContents)
    {
        glEnable(GL_SCISSOR_TEST);
        
        CGRect box = self.boundingBox;
        CGPoint oldOrigin = box.origin;
        box.origin = [self convertToWorldSpace:box.origin];
        glScissor((box.origin.x-1) * _xPX, (box.origin.y-1) * _yPX,
                  (box.size.width-oldOrigin.x+2) * _xPX, (box.size.height-oldOrigin.y+2) * _yPX);
    }
    
	[super visit];
    
    if (_clipContents)
        glDisable(GL_SCISSOR_TEST);
}



- (void) update: (ccTime) dt
{
    if (abs((int)_scrollVelocity.x) < 1)
        _scrollVelocity.x = 0;
    
    if (abs((int)_scrollVelocity.y) < 1)
        _scrollVelocity.y = 0;
        
    bool doneScrolling = (_content.position.x >= 0 && _content.position.y >= 0) ||
                         (_content.position.x <= self.contentSize.width - _content.contentSize.width &&
                          _content.position.y <= self.contentSize.height - _content.contentSize.height);
    
    
    if (doneScrolling || _scrollVelocity.x == 0 || _scrollVelocity.y == 0)
    {
        _scrollVelocity = ccp(0,0);
        [self unscheduleUpdate];
        return; 
    }
    
    CGPoint distance = ccp(_scrollVelocity.x * dt, _scrollVelocity.y * dt);
    
    _content.position = [self setBoundedPosition:
                         ccp(CAN_HSCROLL ? _content.position.x + distance.x : _content.position.x,
                             CAN_VSCROLL ? _content.position.y - distance.y : _content.position.y)];
    
    _scrollVelocity.x *= (1.0 - _friction);
    _scrollVelocity.y *= (1.0 - _friction);
}




- (CGPoint) setBoundedPosition:(CGPoint) point
{
    if (CAN_HSCROLL)
    {
        if (point.x > 0)
            point.x = 0;
        if (point.x + (_content.contentSize.width * _content.scale) < self.contentSize.width)
            point.x = self.contentSize.width - (_content.contentSize.width * _content.scale);
    }
    
    if (CAN_VSCROLL)
    {
        if (point.y > 0)
            point.y = 0;
        if (point.y + (_content.contentSize.height * _content.scale) < self.contentSize.height)
            point.y = self.contentSize.height - (_content.contentSize.height * _content.scale);
    }
    return point;
}


- (void) scaleContent:(float)scale focalPoint:(CGPoint)focalPoint
{
    float scaleDiff = _content.scale - scale;
    if (scaleDiff != 0)
    {
        _content.scale = scale;
        float focalXPct = focalPoint.x / self.contentSize.width;
        float focalYPct = focalPoint.y / self.contentSize.height;
        float diffPx = _content.contentSize.width * scaleDiff * focalXPct;
        float diffPy = _content.contentSize.height * scaleDiff * focalYPct;
        _content.position = [self setBoundedPosition:ccp(_content.position.x + diffPx, _content.position.y + diffPy)]; // zooming out

    }


}


-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    _scrollVelocity = ccp(0,0);
	return YES;
}

- (void) forwardPanEvent:(UIGestureRecognizer *)recognizer node:(CCNode *)node
{
    [self pan:recognizer node:node];
}

- (void) pan:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
    if ( CAN_HSCROLL == NO && CAN_VSCROLL == NO )
        return;
    
    if (_inhibitPan)
        return;
        
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*) recognizer;
    
    CGPoint velocity = [pan velocityInView:pan.view];
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (ABS(velocity.x) > 300 || ABS(velocity.y) > 300)
        {
            _scrollVelocity = ccpAdd(_scrollVelocity,velocity);
            [self unscheduleUpdate];
            [self scheduleUpdate];
        }
        
        return;
    }
    
    CGPoint motion = [pan translationInView:pan.view];
    
    _content.position = [self setBoundedPosition:
                         ccp(CAN_HSCROLL ? _content.position.x + motion.x : _content.position.x,
                             CAN_VSCROLL ? _content.position.y - motion.y : _content.position.y)];
    
    [pan setTranslation:ccp(0,0) inView:pan.view];
}


- (CGPoint) keepNodeOnScreen:(CCNode *)node
{
    static CGSize zeroMargin = { 0, 0 };
    return [self keepNodeOnScreen:node withMargin:zeroMargin];
}

- (CGPoint) keepNodeOnScreen:(CCNode*) node withMargin:(CGSize)margin
{
    return [self keepNodeOnScreen:node withMargin:margin positionBased:NO];
}


- (CGPoint) keepNodeOnScreen:(CCNode*)node withMargin:(CGSize)margin positionBased:(bool) positionBased;
{
    if (CAN_HSCROLL == NO && CAN_VSCROLL == NO)
        return (CGPoint) { 0, 0 };
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
        
    CGPoint adjustment = ccp(0,0);
    
    if (positionBased)
    {
        CGPoint screenPos = [_content convertToWorldSpace:node.position];

        if (CAN_HSCROLL)
        {
            if (screenPos.x < margin.width)
                adjustment.x = screenPos.x - margin.width;
            else if (screenPos.x > screen.width - margin.width)
                adjustment.x = screenPos.x - (screen.width - margin.width);
        }
        
        if (CAN_VSCROLL)
        {
            if (screenPos.y < margin.height)
                adjustment.y = screenPos.y - margin.height;
            else if (screenPos.y > screen.height - margin.height)
                adjustment.y = screenPos.y - (screen.height - margin.height);
        }
    }
    else
    {
        CGPoint screenPos = [_content convertToWorldSpace:node.boundingBox.origin];
        CGRect absoluteBox = CGRectMake(screenPos.x, screenPos.y, node.contentSize.width, node.contentSize.height);
        
        if (CAN_HSCROLL)
        {
            if (absoluteBox.origin.x < margin.width)
                adjustment.x = absoluteBox.origin.x - margin.width;
            else if (absoluteBox.origin.x + absoluteBox.size.width > screen.width - margin.width)
                adjustment.x = (absoluteBox.origin.x + absoluteBox.size.width) - (screen.width - margin.width);
        }
        
        if (CAN_VSCROLL)
        {
            if (absoluteBox.origin.y < margin.height)
                adjustment.y = absoluteBox.origin.y - margin.height;
            else if (absoluteBox.origin.y + absoluteBox.size.height > screen.height - margin.height)
                adjustment.y = (absoluteBox.origin.y + absoluteBox.size.height) - (screen.height - margin.width);
        }
    }
    
    if (adjustment.x != 0 || adjustment.y != 0)
    {
        CGPoint newPosition = [self setBoundedPosition:ccpSub(_content.position, adjustment)];
        adjustment = ccpSub(_content.position, newPosition);
        _content.position = newPosition;
    }
    
    return adjustment;
}


- (BOOL) gestureRecognizer:(UIGestureRecognizer*) recognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [_content convertTouchToNodeSpace:touch];
    for (CCNode* child in _content.children)
    {
        if (child.gestureRecognizers.count > 0 && CGRectContainsPoint(child.boundingBox, touchPoint))
            return NO;
    }
    return YES;
}


- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
