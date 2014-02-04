//
//  Drawer.m
//  TD Launch
//
//  Created by Kent Anderson on 8/28/12.
//
//

#import "Drawer.h"

@implementation Drawer



- (id) init
{
    if ( (self = [super init]) )
    {
        _clipContents = true;
        _clippingMargin = CGSizeMake(0,0);
        _openPosition = ccp(0,0);
        _closedPosition = ccp(0,0);
        
        _xPX = [[CCDirector sharedDirector] winSizeInPixels].width / [[CCDirector sharedDirector] winSize].width;
        _yPX = [[CCDirector sharedDirector] winSizeInPixels].height / [[CCDirector sharedDirector] winSize].height;
    }
    return self;
}

- (void) onExit
{
    [self removeAllChildrenWithCleanup:YES];
}

- (void) visit
{
	if (!self.visible)
		return;
    
    if (_clipContents)
    {
        glEnable(GL_SCISSOR_TEST);
        
        CGRect box = self.boundingBox;
        glScissor((box.origin.x+(_clippingMargin.width/2)) * _xPX, (box.origin.y+(_clippingMargin.height/2)) * _yPX,
                  (box.size.width-(_clippingMargin.width/2)+1) * _xPX, (box.size.height-(_clippingMargin.height/2)+1) * _yPX);
    }
    
	[super visit];
    
    if (_clipContents)
        glDisable(GL_SCISSOR_TEST);
}


- (void) open:(ccTime)animationTime
{
    // stop open and close
    [self stopActionByTag:1];
    [self stopActionByTag:2];
    
    if (animationTime == 0)
    {
        self.position = _openPosition;
    }
    else
    {
        CCAction* moveTo = [CCMoveTo actionWithDuration:animationTime position:_openPosition];
        moveTo.tag = 1;
        [self runAction:moveTo];
    }
    _isOpen = YES;
    
    
}


- (void) close:(ccTime)animationTime
{
    // stop open and close
    [self stopActionByTag:1];
    [self stopActionByTag:2];
    
    if (animationTime == 0)
    {
        self.position = _closedPosition;
    }
    else
    {
        CCAction* moveTo = [CCMoveTo actionWithDuration:animationTime position:_closedPosition];
        moveTo.tag = 2;
        [self runAction:moveTo];
    }
    
    _isOpen = NO;
}

@end
