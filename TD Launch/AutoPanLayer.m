//
//  AutoPanLayer.m
//  TD Launch
//
//  Created by Kent Anderson on 8/15/12.
//
//

#import "AutoPanLayer.h"

@implementation AutoPanLayer

-(id) init
{
    if ( self = [super init] )
    {
        _panTarget = nil;
        _panDuration = 0.5;
        panAction = nil;
    }
    
    return self;
}



- (void) update
{
    if (_panTarget == nil)
        return;
    
    if (panAction != nil && panAction.isDone == NO)
        return;
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CGPoint layerPos = self.position;  // will hold new coords
    CGSize layerSize = self.contentSize;
    
    if (_panTarget.position.x + layerPos.x < 0)
    {
        // Need to move the view to the left (layer to the right ++)
        layerPos.x += screen.width;
        if (layerPos.x > 0)
            layerPos.x = 0;
    }
    else if (_panTarget.position.x > layerPos.x + screen.width)
    {
        // Need to move the view to the right (layer to the left --)
        layerPos.x -= screen.width;
        if (layerPos.x + layerSize.width < screen.width)
            layerPos.x = screen.width - layerSize.width;
    }
    
    if (_panTarget.position.y > layerPos.y + screen.height)
    {
        // Need to move the view up (layer down --)
        layerPos.y -= screen.height;
        if (layerPos.y + layerSize.height < screen.height)
            layerPos.y = screen.height - layerSize.height;
    }
    else if (_panTarget.position.y + layerPos.y < 0)
    {
        // Need to move the view down (layer up ++)
        layerPos.y += screen.height;
        if (layerPos.y > 0)
            layerPos.y = 0;
    }
    
    // make the change, if needed
    if (layerPos.x != self.position.x || layerPos.y != self.position.y)
    {
        panAction = [CCMoveTo actionWithDuration:_panDuration position:layerPos];
        [self runAction:panAction];
    }
}

@end
