//
//  AutoPanLayer.h
//  TD Launch
//
//  Created by Kent Anderson on 8/15/12.
//
//

#import "cocos2d.h"



@interface AutoPanLayer : CCLayer
{
    CCMoveTo* panAction;
}

@property CCNode* panTarget;
@property float panDuration;



- (void) update;
@end
