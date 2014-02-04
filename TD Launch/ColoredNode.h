//
//  ColoredNode.h
//  TD Launch
//
//  Created by Kent Anderson on 8/23/12.
//
//

#import "cocos2d.h"

@interface ColoredNode : CCSprite

@property ccColor3B fillColor;

- (void) resizeTo:(CGSize)size;
@end
