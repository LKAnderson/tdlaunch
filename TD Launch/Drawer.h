//
//  Drawer.h
//  TD Launch
//
//  Created by Kent Anderson on 8/28/12.
//
//

#import "cocos2d.h"

@interface Drawer : CCNode
{
    float _xPX, _yPX;
}


@property bool clipContents;
@property CGSize clippingMargin;
@property CGPoint openPosition;
@property CGPoint closedPosition;
@property (readonly) bool isOpen;



- (void) open:(ccTime) animationTime;
- (void) close:(ccTime) animationTime;

@end
